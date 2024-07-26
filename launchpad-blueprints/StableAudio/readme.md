<div align="center">

# Docker image for Stable Audio Open 1

[![python](https://img.shields.io/badge/python-3.10-green)](https://www.python.org/downloads/)
[![cuda](https://img.shields.io/badge/cuda-12.4-green)](https://developer.nvidia.com/cuda-downloads)

</div>

## Tags
| Tag    | Description              | Size      |
| ------ | ------------------------ | --------- |
| latest | python 3.10, stable audio 1 | ~ 11.6 GB |

## Ports

| Connect Port | Internal Port | Description |
| ------------ | ------------- | ----------- |
| 7860         | 7860          | Stable Audio Webui  |
| 8888         | 8888          | Jupyter Lab  |

## Environment Variables

Each of the following environment variable is optional, set either `PUBLIC_KEY` for ssh access

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| PUBLIC_KEY   | Public Key for ssh access               |
| SSH_USER     | Username for ssh access (default: root) |

## Building the docker image
```bash
git clone https://github.com/latitudesh/examples
cd examples/launchpad-blueprints/StableAudio

mkdir models
# download models from https://huggingface.co/stabilityai/stable-audio-open-1.0/tree/main into ./models
# model.safetensors
# model_config.json

# build image
docker-compose build latest
```

## Credits

This blueprint was developed by our partner researcher **Yuvraj Seegolam**:
- [Github](https://github.com/yuvraj108c)

Original Repository
- [Automatic1111 Repository](https://github.com/yuvraj108c/Fooocus-docker)