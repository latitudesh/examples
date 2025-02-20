scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null *.nix "$1:/home/ubuntu/"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null *.json "$1:/home/ubuntu/"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null *.lock "$1:/home/ubuntu/"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null *.sh "$1:/home/ubuntu/"