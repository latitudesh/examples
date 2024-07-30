<div align="center">

# Docker image for Fooocus

[![python](https://img.shields.io/badge/python-3.10-green)](https://www.python.org/downloads/)
[![cuda](https://img.shields.io/badge/cuda-12.4-green)](https://developer.nvidia.com/cuda-downloads)
[![GPL-3.0](https://img.shields.io/badge/license-GPLv3-blue)](https://www.gnu.org/licenses/gpl-3.0.en.html#license-text)
</div>

## Tags
| Tag    | Description                      | Size      |
| ------ | -------------------------------- | --------- |
| latest | python 3.10, Fooocus 2.4.3 | ~ 14.5 GB |

## Models
- [juggernautXL_v8Rundiffusion](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_offset_example-lora_1.0.safetensors)	
- [fooocus_expansion](https://huggingface.co/lllyasviel/misc/resolve/main/fooocus_expansion.bin)	

## Ports

| Connect Port | Internal Port | Description   |
| ------------ | ------------- | ------------- |
| 22           | 22            | SSH Server    |
| 7860         | 7860          | Fooocus Webui |
| 8888         | 8888          | Jupyter Lab   |

## Environment Variables

Each of the following environment variable is optional, set either `PUBLIC_KEY` for ssh access

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| PUBLIC_KEY   | Public Key for ssh access               |
| SSH_USER     | Username for ssh access (default: root) |


## License
GPL-3.0

## Credits

This blueprint was developed by our partner researcher **Yuvraj Seegolam**:
- [Github](https://github.com/yuvraj108c)

Original Repository
- [Automatic1111 Repository](https://github.com/yuvraj108c/Fooocus-docker)