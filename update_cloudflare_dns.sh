#!/bin/bash


########        ################        ##############
# v1.1 #        # Guillaume B. #        # 2019.11.04 #
########        ################        ##############

######################### Update Cloudflare DNS Records with API ############################
# 
# This script is a "DynDns like" and has been made to auto update all DNS "A" records 
#   of ONE cloudflare dns zone when your public ip change.
# It uses the Cloudflare API V4
# It will compare your existing public IP address with your new public IP address.
# If old and new public IP are different, it will GET the name, the content (ip address), 
#   and the dns record ID of every single "A" record of ONE cloudflare DNS Zone allready set.
# Then it will PUT the new content (new public IP) on each single "A" record.
# When DNS record is updated, I personally set it Proxied with Auto TTL (set to 1)
# Feel free to adapt
#
# Requirements : 
#   - have jq installed : sudo yum install jq
#   - have wget installed : sudo yum install wget
#   - have a cloudflare acount and get : 
#       - your DNS zone ID
#       - your auth email 
#       - your API token ID 
#   (I dont know how to use api bearer authentication for now, so feel free to adapt the 
#   script and share your result in comments.)
#
#
# v1.2 will log results and comment/describe 
#
############################################################################################


#================================ Variables =====================================
# Adapt with your personal values
cloudflare_dns_zone_id="changeme"
cloudflare_auth_email="change@me.com"
cloudflare_auth_api_key="changeme"
#================================================================================


if [ $old_ip = NULL ]
  old_ip=$(wget -qO- http://ipecho.net/plain)
fi

new_ip=$(wget -qO- http://ipecho.net/plain)

if [ $new_ip != $old_ip ]
    (curl -X GET "https://api.cloudflare.com/client/v4/zones/${cloudflare_dns_zone_id}/dns_records?type=A&content=${old_ip}&per_page=100" \
    -H 'X-Auth-Email: '$cloudflare_auth_email'' \
    -H 'X-Auth-Key: '$cloudflare_auth_api_key'' \
    -H "Content-Type: application/json" \
    | jq -r '.result[] | "\(.id) \(.name)"') \
    |   while read CLOUDFLARE_DNS_RECORD_ID CLOUDFLARE_DNS_NAME; \
            do \
                (curl -X PUT "https://api.cloudflare.com/client/v4/zones/${cloudflare_dns_zone_id}/dns_records/${CLOUDFLARE_DNS_RECORD_ID}" \
                -H 'Content-Type: application/json' \
                -H 'X-Auth-Email: '$cloudflare_auth_email'' \
                -H 'X-Auth-Key: '$cloudflare_auth_api_key'' \
                -d '{
                "type":"A",
                "name":"'$CLOUDFLARE_DNS_NAME'",
                "content":"'$new_ip'",
                "ttl":1,
                "proxied":true
                }'); \
            
        done

old_ip=$new_IP

fi


###### one lined version #####
#(curl -X GET "https://api.cloudflare.com/client/v4/zones/${cloudflare_dns_zone_id}/dns_records?type=A&content=${old_ip}&per_page=100" -H 'X-Auth-Email: '$cloudflare_auth_email'' -H 'X-Auth-Key: '$cloudflare_auth_api_key'' -H "Content-Type: application/json" | jq -r '.result[] | "\(.id) \(.name)"') | while read CLOUDFLARE_DNS_RECORD_ID CLOUDFLARE_DNS_NAME; do (curl -X PUT "https://api.cloudflare.com/client/v4/zones/${cloudflare_dns_zone_id}/dns_records/${CLOUDFLARE_DNS_RECORD_ID}" -H 'Content-Type: application/json' -H 'X-Auth-Email: '$cloudflare_auth_email'' -H 'X-Auth-Key: '$cloudflare_auth_api_key'' -d '{"type":"A","name":"'$CLOUDFLARE_DNS_NAME'","content":"'$new_ip'","ttl":1,"proxied":true}'); done
##############################


######### to get the total count of dns "A" records ##########
#    total_count=$(curl -X GET "https://api.cloudflare.com/client/v4/zones/${cloudflare_dns_zone_id}/dns_records?type=A&content=${old_ip}&per_page=100" \
#    -H 'X-Auth-Email: '$cloudflare_auth_email'' \
#    -H 'X-Auth-Key: '$cloudflare_auth_api_key'' \
#    -H "Content-Type: application/json" \
#    | jq '.result_info.total_count')
##############################################################
