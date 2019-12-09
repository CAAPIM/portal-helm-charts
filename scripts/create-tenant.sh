#!/bin/bash

USER_CONFIG=${PORTAL_USER_CONFIG:-../values.yaml}
CERT_FILE=${CERT_FILE:-../files/apim-tps.crt}
KEY_FILE=${APIM_KEY_FILE:-../files/apim-tps.key}
values=(adminEmail auditLogLevel multiclusterEnabled noReplyEmail performanceLogLevel portalLogLevel portalName subdomain tenantId tenantType termOfUse)

CURLVERSION=7.29.0

function usage() {
  >&2 echo "
  usage: $0 [OPTIONS]

  Create a tenant in the portal database. This scripts completes the first step of an external tenant enrollment.

  OPTIONS:
    -h | --help: Show help message
    -D | --DEBUG: Turn on the debug mode
    -d | --data: The json payload file
  "
}

function validate_payload {
	for i in "${!values[@]}"; do
		key="${values[i]}"
		grep -q ${key} ${data} || error=missing
		if [ -n "$error" ]; then
			echo "${key} is missing from your payload"
			exit 1
		fi
		if [ "$key" == tenantId ]; then
			#Regex match to grab correct tenantID
			re="\"tenantId\" ?: ?\"([^\"]*)\""
			json=`cat ${data}`	
			TENANTID=${key}
			if [[ ${json} =~ ${re} ]]; then
				TENANTID=${BASH_REMATCH[1]}
			fi
		fi
	done
}

function generate_post_data {
	cat <<eof
{
		"adminEmail": "$ADMINEMAIL",
		"auditLogLevel": "TRACE",
		"multiclusterEnabled": true,
		"noReplyEmail":"$NOREPLYEMAIL",
		"performanceLogLevel": "ERROR",
		"portalLogLevel": "ERROR",
		"portalName": "$PORTALNAME",
		"subdomain": "$DOMAIN",
		"tenantId": "$TENANTID",
		"tenantType": "ON-PREM",
		"termOfUse": "$EULA"
}
eof
}

function ask_for_input {
  read -p "Ingress host: " -e -i $DEFAULTINGRESSHOST INGRESS_HOST
  read -p "Ingress port: " -e -i 443 INGRESS_PORT
	read -p "Tenant ID: " -e -i tenant2 TENANTID
	read -p "Portal name: " -e PORTALNAME
	read -p "Admin email: " -e ADMINEMAIL
	read -p "'No Reply' email: " -e NOREPLYEMAIL
	read -p "Terms of use (EULA): " -e -i Eula EULA
}

function ask_for_key {
	read -p "Path to your key: " -e -i ../files/apim-tps.key KEY_FILE
	read -p "Path to your cert: " -e -i ../files/apim-tps.crt CERT_FILE
}

function print_steps {
	tenant_id=${TENANTID:-"tenantId"}
	sub_domain=${DOMAIN:-"PORTAL_DOMAIN"}

	echo "

	The tenant has been added to the database. The tenant info can be found in the tenant_info file in the current directory.
	Please follow the rest of the instructions at techdocs.broadcom.com to enroll your gateway with the portal.
			
	1. You will need to navigate to the portal at https://${tenant_id}.${sub_domain} and create a new API PROXY. 
	2. Copy the enrollment URL
	3. Open your tenant gateway and enroll this gateway with the portal using the URL from step 2.
	"
}

function get_conf {
  yq r ${USER_CONFIG} ${1}
}

function hostname_resolves {
	if ! ping -c 2 ${INGRESS_HOST} &> /dev/null; then
		echo "${INGRESS_HOST} is not resolvable. Please make sure this points to your portal IP address."
		exit 1
	fi
}

function create_tenant {
	if [ -z "$data" ]; then
		STATUSCODE=$(curl --silent --output ./tenant_info --write-out "%{http_code}" \
				-X POST -k https://${INGRESS_HOST}:${INGRESS_PORT}/provision/tenants \
				--cert ${CERT_FILE} --key ${KEY_FILE} -H "Accept: application/json" \
				-H "Content-Type: application/json" -d "$(generate_post_data)")
		if test $STATUSCODE -ne 201; then
			echo "There was an error while creating the tenant. Please check your connection to the servers and/or your json payload."
			exit 1
		else
			print_steps
		fi
	elif [ -f "$data" ]; then
		STATUSCODE=$(curl --silent --output ./tenant_info --write-out "%{http_code}" \
				-X POST -k https://${INGRESS_HOST}:${INGRESS_PORT}/provision/tenants \
				--cert ${CERT_FILE} --key ${KEY_FILE} -H "Accept: application/json" \
				-H "Content-Type: application/json" -d @${data})
		if test $STATUSCODE -ne 201; then
			echo "There was an error while creating the tenant. Please check your connection to the servers and/or your json payload."
			exit 1
		else
			print_steps
		fi
	else
		echo "${data} Does not exist"
	fi
}

function verlt {
	[ "$1" = $(echo -e "$1\n$2" | sort -V | head -n1) ]
}

function verlte {
	[ "$1" = "$2" ] && return 1 || verlt $1 $2
}

function check_curl_version {
	V=$(curl --version | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
	verlte $V $CURLVERSION && UPGRADE=$((UPGRADE | 1 ))
	if [[ ! $UPGRADE -eq 0 ]]; then
		echo "Your curl version is ${V} but it must be higher than ${CURLVERSION}"
		exit 1
	fi
}

function check_yq_installed {
  V=$(command -v yq)
  if [[ -z "$V" ]]; then
    echo "Please install yq (command-line YAML processor) first: https://mikefarah.github.io/yq/"
    exit 1
  fi
}

function main {
	data=""

	check_curl_version
	check_yq_installed

	# Parse parameters
	while true; do
		case "${1:-}" in
			-D | --DEBUG		) set -x; shift		;;
			-h | --help		) usage ; exit 1	;;
			-d | --data		) shift; data="$1"; shift; ;;
			-- ) shift; break ;;
			"" ) break ;;
			* ) echo "Invalid parameter '$1'"; usage ; exit 1 ;;
		esac
	done

	if [ ! -f "$USER_CONFIG" ]; then
		echo "${USER_CONFIG} does not exist"
		exit 1
	fi

	DOMAIN=$(get_conf 'user.domain')
	KUBENAMESPACE=$(get_conf 'user.kubeNamespace')
	DEFAULTTENANTID=$(get_conf 'user.defaultTenantId')
	DEFAULTINGRESSHOST=$(echo "${KUBENAMESPACE}-ssg.${DOMAIN}")

	if [ -z "$data" ]; then
		ask_for_input
		ask_for_key
		generate_post_data
		create_tenant
	else
		validate_payload
		ask_for_key
		create_tenant
	fi
}

main "$@"

