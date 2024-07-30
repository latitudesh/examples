<div align="center">

# Docker image for Bark

[![python](https://img.shields.io/badge/python-3.8-green)](https://www.python.org/downloads/)
[![cuda](https://img.shields.io/badge/cuda-12.4-green)](https://developer.nvidia.com/cuda-downloads)

</div>

## Tags
| Tag    | Description              | Size      |
| ------ | ------------------------ | --------- |
| latest | python 3.8, bark | ~ 19.2 GB |


## Ports

| Connect Port | Internal Port | Description   |
| ------------ | ------------- | ------------- |
| 22           | 22            | SSH Server    |
| 7860         | 7860          | Bark Webui    |
| 8888         | 8888          | Jupyter Lab   |

## Environment Variables

Each of the following environment variable is optional, set either `PUBLIC_KEY` for ssh access

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| PUBLIC_KEY   | Public Key for ssh access               |
| SSH_USER     | Username for ssh access (default: root) |

## Credits

This blueprint was developed by our partner researcher **Yuvraj Seegolam**:
- [Github](https://github.com/yuvraj108c)

Original Repository
- [Bark Repository](https://github.com/yuvraj108c/bark-docker)


