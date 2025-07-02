# Custom Images v2

This directory contains iPXE scripts for the new version of Latitude.sh custom images, with support for DHCP and improved boot process.

Use these scripts if you are gated in to the new custom images feature. Alternatively, refer to the <strong>custom-images</strong> directory for the old version of custom images.

## Overview

Custom images allow you to deploy servers with pre-configured operating systems and applications.

Reference: [Latitude.sh Custom Images Documentation](https://www.latitude.sh/docs/servers/custom-images)

## Usage

Each image directory contains:

- `boot.ipxe`: iPXE boot script for network boot
- `README.md`: Specific instructions and configuration details

To use these custom images:

1. Choose the desired image you want to deploy
2. Create a new server and choose Custom Image, then place the contents of the `boot.ipxe` file into the Custom Image field
3. Click Create Server

For API users, refer to the [Deploy Server](https://docs.latitude.sh/reference/create-server) endpoint.