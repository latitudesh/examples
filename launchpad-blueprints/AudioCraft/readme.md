<div align="center">

# Docker image for Audiocraft

[![python](https://img.shields.io/badge/python-3.10-green)](https://www.python.org/downloads/)
[![cuda](https://img.shields.io/badge/cuda-12.4-green)](https://developer.nvidia.com/cuda-downloads)

<p align="center">
  <img src="assets/banner.PNG" />
</p>
</div>

## Tags

| Tag    | Description              | Size      |
| ------ | ------------------------ | --------- |
| latest | python 3.10, audiocraft 2.0.1 | ~ 7.7 GB |

## Ports

| Connect Port | Internal Port | Description |
| ------------ | ------------- | ----------- |
| 7860         | 7860          | Audiocraft  |
| 8888         | 8888          | Jupyter Lab  |

## Environment Variables

Each of the following environment variable is optional, set either `PUBLIC_KEY` for ssh access

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| PUBLIC_KEY   | Public Key for ssh access               |
| SSH_USER     | Username for ssh access (default: root) |


## License

CC BY-NC-SA 4.0

## Credits

This blueprint was developed by our partner researcher **Yuvraj Seegolam**:
- [Github](https://github.com/yuvraj108c)

Original Repository
- [Audiocraft Repository](https://github.com/yuvraj108c/audiocraft-plus-docker)