# curl --request POST \
#      --url "https://api.latitude.sh/servers/$SERVER_ID/actions" \
#      --header "Authorization: $LATITUDESH_AUTH_TOKEN" \
#      --header 'accept: application/vnd.api+json' \
#      --header 'content-type: application/vnd.api+json' \
#      --data '
# {
#   "data": {
#     "type": "actions",
#     "attributes": {
#       "action": "reboot"
#     }
#   }
# }
# '

curl --request GET \
     --url "https://api.latitude.sh/servers/$SERVER_ID" \
     --header "Authorization: $LATITUDESH_AUTH_TOKEN" \
     --header 'accept: application/vnd.api+json'