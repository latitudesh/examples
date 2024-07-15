### Configure Private Networks

This example demonstrates how to add a server to a previously configured [private network](https://www.latitude.sh/docs/networking/private-networks) as soon as it boots for the first time.

This is helpful for automating the process of adding servers to a private network without the need for a custom setup.

### Requirements:
* Create a VLAN by going to Networking -> Private networks. Write down the VID value.
* Replace the `<VID>` variable in the script with the VID of the VLAN to which you want the server to be added.
* Replace `<IP_ADDRESS>` variable with a private IP for internal communication.