- Install nix with flakes and commands enabled.
- Run `tofu apply`

Will create http2/3 server with caddy hello world endpoints.

Setups securend fully determinstic declarative server end to end,
available
with full keys support (several NTP NTS and name servers),
with RAID-1

will setup to monitor hardware status

https://docs.latitude.sh/reference/create-server-action



curl --request POST \
     --url https://api.latitude.sh/servers/server_id/actions \
     --header 'Authorization: asdsadasdad' \
     --header 'accept: application/vnd.api+json' \
     --header 'content-type: application/vnd.api+json' \
     --data '
{
  "data": {
    "type": "actions",
    "attributes": {
      "action": "reboot"
    }
  }
}
'