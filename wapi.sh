#!/bin/bash

# Set your Wedos API credentials
LOGIN='<WEDOS-ACCOUNT-MAIL>'
WPASS='<WAPI-PASSWORD>'

# Function to send XML request
send_request() {
    local COMMAND=$1
    local DOMAIN=$2
    local TXT_RECORD=$3
    local CLTRID=$4

    local AUTH=$(echo -n "$LOGIN$(echo -n "$WPASS" | sha1sum | cut -d ' ' -f 1)$(date +'%H')" | sha1sum | cut -d ' ' -f 1)
    local URL='https://api.wedos.com/wapi/xml'

    case "$COMMAND" in
        "dns-rows-list")
            local REQUEST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<request>
 <user>$LOGIN</user>
 <auth>$AUTH</auth>
 <command>$COMMAND</command>
 <clTRID>$CLTRID</clTRID>
 <data>
  <domain>$DOMAIN</domain>
 </data>
</request>"
            ;;
        "dns-row-delete")
            local REQUEST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<request>
 <user>$LOGIN</user>
 <auth>$AUTH</auth>
 <command>$COMMAND</command>
 <clTRID>$CLTRID</clTRID>
 <data>
  <domain>$DOMAIN</domain>
  <row_id>$TXT_RECORD</row_id>
 </data>
</request>"
            ;;
        "dns-row-add")
            local REQUEST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<request>
 <user>$LOGIN</user>
 <auth>$AUTH</auth>
 <command>$COMMAND</command>
 <clTRID>$CLTRID</clTRID>
 <data>
  <domain>$DOMAIN</domain>
  <name>_acme-challenge</name>
  <ttl>300</ttl>
  <type>TXT</type>
  <rdata>$TXT_RECORD</rdata>
 </data>
</request>"
            ;;
        *)
            echo "Unknown command"
            exit 1
            ;;
    esac

    local POST="request=$(echo "$REQUEST" | sed 's/"/\\\"/g')"
    local RESPONSE=$(curl -s -X POST -d "$POST" "$URL")

    # Extract content of <result> tag from XML response
    local RESULT=$(echo "$RESPONSE" | grep -oPm1 "(?<=<result>)[^<]+")

    echo "Command executed: $RESULT"
}

# Function to add TXT record
add_record() {
    local DOMAIN=$1
    local TXT_RECORD=$2
    local CLTRID=$3

    # Retrieve existing TXT records
    local EXISTING_RECORDS=$(send_request "dns-rows-list" "$DOMAIN" "" "$CLTRID")

    # Extract IDs of TXT records
    local TXT_IDS=$(echo "$EXISTING_RECORDS" | grep -E '<rdtype>TXT</rdtype>' | grep -oP '<ID>\K[^<]+')

    # Remove each existing TXT record
    for ID in $TXT_IDS; do
        send_request "dns-row-delete" "$DOMAIN" "$ID" "$CLTRID"
    done

    # Add the new TXT record
    send_request "dns-row-add" "$DOMAIN" "$TXT_RECORD" "$CLTRID"
}

# Function to send commit request
send_commit() {
    local DOMAIN=$1
    local CLTRID=$2

    local AUTH=$(echo -n "$LOGIN$(echo -n "$WPASS" | sha1sum | cut -d ' ' -f 1)$(date +'%H')" | sha1sum | cut -d ' ' -f 1)
    local URL='https://api.wedos.com/wapi/xml'
    local REQUEST="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<request>
 <user>$LOGIN</user>
 <auth>$AUTH</auth>
 <command>dns-domain-commit</command>
 <clTRID>$CLTRID</clTRID>
 <data>
  <name>$DOMAIN</name>
 </data>
</request>"

    local POST="request=$(echo "$REQUEST" | sed 's/"/\\\"/g')"
    local RESPONSE=$(curl -s -X POST -d "$POST" "$URL")

    # Extract content of <result> tag from XML response
    local RESULT=$(echo "$RESPONSE" | grep -oPm1 "(?<=<result>)[^<]+")

    echo "Command commited: $RESULT"
}

# Main function
main() {
    local DOMAIN="$CERTBOT_DOMAIN"
    local TXT_RECORD="$CERTBOT_VALIDATION"
    local CLTRID="custom_id_here"

    case "$CERTBOT_REMAINING_CHALLENGES" in
        [1-9]*)
            add_record "$DOMAIN" "$TXT_RECORD" "$CLTRID"
            send_commit "$DOMAIN" "$CLTRID"
            sleep 300
            ;;
        0)
            add_record "$DOMAIN" "$TXT_RECORD" "$CLTRID"
            send_commit "$DOMAIN" "$CLTRID"
            sleep 300
            ;;
        *)
            echo "Unknown CERTBOT_REMAINING_CHALLENGES value"
            exit 1
            ;;
    esac
}

# Execute main function
main
