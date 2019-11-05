# cloudflare-dns-api

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
# v1.2 will log results...
#
############################################################################################
