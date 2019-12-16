#!/bin/bash

# Script to generate self-signed certs for APIM portal Helm install process 
# Self-signed Certs to be generated: 
# apim, datalake dispatcher, dssg, pssg, smtp-internal,solr, tps 
# Certs types: # internal_cert | internal_p8_key | internal_p12_key | internal_smtp_cert
# To run the script:  create_self_signed_certs.sh 
# No need to specify any parameters
#
# You need to give password to protect the certs and the file location to store the certs
# Usually, the self-signed certs location is under files folder of your api portal Helm packages, 
# Make sure bash is at least 4.x, so that I can use associated array

# Set the defaults up
DEFAULT_CERTPWD="certpass"
SCRIPT_LOCATION="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
HELM_CHARTS_ROOT=$( echo "${SCRIPT_LOCATION}" | awk -F'scripts' '{ printf $1 }')
DEFAULT_HELM_CHARTS_LOCATION="${HELM_CHARTS_ROOT}files"
DEFAULT_SUBDOMAIN="example.com"
DEFAULT_EXTERNAL_STMP="yes"

# Check parameters
while getopts "l:s:p:e:" OPTION; do
  case $OPTION in
    l)
	  HELM_CHARTS_LOCATION=$OPTARG
      ;;
    s)
      SUBDOMAIN=$OPTARG;
      if ! [[ "$SUBDOMAIN" =~ ^[.a-zA-Z0-9\-]+\.[a-z]+$ ]]; then
        echo "$SUBDOMAIN is not a valid domain"
        exit 1;
	  fi
      ;;
    p)
      CERTPWD=$OPTARG
      ;;
    e)
      EXTERNAL_STMP=$OPTARG;
      if ! [[ "$EXTERNAL_STMP" == "yes" || "$EXTERNAL_STMP" == "no" ]]; then
        echo "'$EXTERNAL_STMP' is not a yes or no value"
        exit 1;
      fi
      ;;
  esac
done


function check_installed {
  V=$(command -v ${1})
  if [[ -z "$V" ]]; then
    echo "Please install ${1}"
    exit 1
  fi
}

###############################################
# Function to generate APIM portal certs

function gen_certificate {
	local key_name="$1"
	local pass="$2"
	local host="$3"
	local cert_type="$4"
	local path="$5"

	if [[ ${4} == "internal_smtp_cert" && ${EXTERNAL_STMP} == "yes" ]]; then
	  return
	fi

	echo "Generating certificate: $cert_key_name"

  openssl req -x509 -sha256 -nodes \
    -days $((365 * 3)) \
    -newkey rsa:2048 \
    -keyout "$path/${key_name}.key" \
    -out "$path/${key_name}.crt" \
    -subj "/CN=${host}" \
    -passin pass:"$pass" \
    -passout pass:"$pass"

  openssl pkcs12 -export \
    -out "$path/${key_name}.p12" \
    -inkey "$path/${key_name}.key" \
    -in "$path/${key_name}.crt" \
    -passin pass:"$pass" \
    -passout pass:"$pass"

  if [[ ${4} == "internal_smtp_cert" ]]; then
	  openssl req -new -nodes -x509 \
	    -extensions v3_ca \
	    -keyout $path/cakey.pem \
	    -subj "/CN=${host}" \
	    -out "$path/${key_name}-ca.pem" \
	    -days $((365 * 3))

	  if [[ $? -eq 1 ]]; then
	    echo "[ERROR] Failed to generate internal CA certificate"
	    exit 1
	  fi
	  rm $path/cakey.pem
  fi
  chmod 600 "$path/${key_name}".*
  retval=0
}

check_installed openssl

# Generate all the self-signed certs

if [ -z "${HELM_CHARTS_LOCATION}" ]; then
	echo "Generating self-signed certs for APIM portal"
	echo -n "Enter location of the APIM Helm Charts you downloaded: [$DEFAULT_HELM_CHARTS_LOCATION]"
	read REPLY
	if test $REPLY ; then 
		HELM_CHARTS_LOCATION=$REPLY ; 
	else
		HELM_CHARTS_LOCATION=$DEFAULT_HELM_CHARTS_LOCATION ;
	fi
	echo "$HELM_CHARTS_LOCATION"
	if [ ! -d "$HELM_CHARTS_LOCATION" ]; then 
		echo "$HELM_CHARTS_LOCATION is not a valid directory" 
		exit 1; 
	fi
fi

if [ -z "${EXTERNAL_STMP}" ]; then
  echo -n "Will you use an external SMTP server: [$DEFAULT_EXTERNAL_STMP]"
  read REPLY
  REPLY=$(echo $REPLY | tr '[:upper:]' '[:lower:]')
  if test $REPLY ; then
    EXTERNAL_STMP=$REPLY;
  else
    EXTERNAL_STMP=$DEFAULT_EXTERNAL_STMP;
  fi
  echo "$EXTERNAL_STMP"
  if ! [[ "$EXTERNAL_STMP" == "yes" || "$EXTERNAL_STMP" == "no" ]]; then
    echo "$REPLY is not a yes/no response"
    exit 1
  fi
  if [ "$EXTERNAL_STMP" == "yes" ]; then
    echo "Certificates for an internal SMTP server will not be generated."
  fi
fi

if [ -z "${SUBDOMAIN}" ]; then
	echo -n "Enter subdomain for the Portal: [$DEFAULT_SUBDOMAIN]"
	read REPLY
	if test $REPLY ; then 
		SUBDOMAIN=$REPLY ; 
	else
		SUBDOMAIN=$DEFAULT_SUBDOMAIN ;
	fi
	echo "$SUBDOMAIN"
	if ! [[ "$SUBDOMAIN" =~ ^[.a-zA-Z0-9\-]+\.[a-z]+$ ]]; then
		echo "$SUBDOMAIN is not a valid domain"
		exit 1;
	fi
fi

if [ -z "${CERTPWD}" ]; then
	echo -n "Enter password for self-signed certs: [$DEFAULT_CERTPWD]"
	read REPLY
	if test $REPLY ; then 
		CERTPWD=$REPLY ; 
	else
		CERTPWD=$DEFAULT_CERTPWD ;
	fi
	echo "$CERTPWD"
fi

# hash name::type::hostname
cert_hash=(
	"apim-ssl::internal_generic::tssg"
	"apim-datalake::internal_generic::portalssg-datalakessg"
	"dispatcher-ssl::internal_generic::*.${SUBDOMAIN}"
	"apim-dssg::internal_generic::dssg"
	"pssg-ssl::internal_generic::pssg"
	"apim-solr::internal_generic::apim-solr"
	"tps::internal_generic::tenant-provisioner"
	"apim-tps::internal_cert::apim-tps"
	"smtp-internal::internal_smtp_cert::smtp"
)

for i in "${!cert_hash[@]}"
do
  my_array=($(echo ${cert_hash[$i]} | tr "::" "\n"))
  cert_key_name=${my_array[0]}
  cert_type=${my_array[1]}
  hostname=${my_array[2]}
	gen_certificate $cert_key_name $CERTPWD $hostname $cert_type $HELM_CHARTS_LOCATION
done
