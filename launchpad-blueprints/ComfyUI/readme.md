<div align="center">

# Docker image for ComfyUI

[![python](https://img.shields.io/badge/python-3.12-green)](https://www.python.org/downloads/)
[![cuda](https://img.shields.io/badge/cuda-12.4-green)](https://developer.nvidia.com/cuda-downloads)
[![mit](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

<img src="assets/comfyui.PNG" />
</div>

## Tags
| Tag    | Description                                                                                   | Size      |
| ------ | --------------------------------------------------------------------------------------------- | --------- |
| lite   | ComfyUI + Manager, Jupyter Lab, 1 sd1.5 model                                                 | ~ 8.3 GB  |
| latest | ComfyUI + Manager, Jupyter Lab, custom nodes, models for controlnets, ipadpapter, animatediff | ~ 32.5 GB |


## Custom Nodes
- [ComfyUI-Manager](https://github.com/ltdrdata/ComfyUI-Manager.git)
- [ComfyUI-VideoHelperSuite](https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git)
- [ComfyUI-Advanced-ControlNet](https://github.com/Kosinkadink/ComfyUI-Advanced-ControlNet.git)
- [ComfyUI-AnimateDiff-Evolved](https://github.com/Kosinkadink/ComfyUI-AnimateDiff-Evolved)
- [comfyui_controlnet_aux](https://github.com/Fannovel16/comfyui_controlnet_aux.git)
- [ComfyUI-Frame-Interpolation](https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git)
- [efficiency-nodes-comfyui](https://github.com/jags111/efficiency-nodes-comfyui.git)
- [ComfyUI-KJNodes](https://github.com/kijai/ComfyUI-KJNodes.git)
- [ComfyUI_IPAdapter_plus](https://github.com/cubiq/ComfyUI_IPAdapter_plus.git)
- [ComfyUI_essentials](https://github.com/cubiq/ComfyUI_essentials.git)
- [ComfyUI_FizzNodes](https://github.com/FizzleDorf/ComfyUI_FizzNodes.git)

## Models
### Checkpoints
- [DreamShaper-8](https://huggingface.co/jzli/DreamShaper-8/tree/main)
- [stable-diffusion-xl-base-1.0](https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/tree/main)

### Vae
- [vae-ft-mse-840000-ema-pruned](https://huggingface.co/stabilityai/sd-vae-ft-mse-original/tree/main)

### Loras
- [lcm_sd15](https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/tree/main)

### Controlnets
- [control_v11p_sd15_openpose](https://huggingface.co/lllyasviel/ControlNet-v1-1/tree/main)
- [control_v11f1p_sd15_depth](https://huggingface.co/lllyasviel/ControlNet-v1-1/tree/main)
- [control_v11p_sd15_lineart](https://huggingface.co/lllyasviel/ControlNet-v1-1/tree/main)


### AnimateDiff
- [AnimateLCM_sd15_t2v](https://huggingface.co/wangfuyun/AnimateLCM/tree/main)
- [v3_sd15_mm](https://huggingface.co/guoyww/animatediff/tree/main)


### Clip Vision
- [CLIP-ViT-H-14-laion2B-s32B-b79K](https://huggingface.co/h94/IP-Adapter/tree/main/models/image_encoder)
- [CLIP-ViT-bigG-14-laion2B-39B-b160k](https://huggingface.co/h94/IP-Adapter/tree/main/sdxl_models/image_encoder)

### Ipadapter
- [ip-adapter-plus_sd15](https://huggingface.co/h94/IP-Adapter/tree/main/models)
- [ip-adapter-plus_sdxl_vit-h](https://huggingface.co/h94/IP-Adapter/tree/main/sdxl_models)



## Ports

| Connect Port | Internal Port | Description |
| ------------ | ------------- | ----------- |
| 22           | 22            | SSH Server  |
| 8188         | 8188          | ComfyUI     |
| 8888         | 8888          | Jupyter Lab |

## Environment Variables

Each of the following environment variable is optional, set either `PUBLIC_KEY` for ssh access

| Variable     | Description                             |
| ------------ | --------------------------------------- |
| SSH_PASSWORD | Password for ssh access                 |
| PUBLIC_KEY   | Public Key for ssh access               |
| SSH_USER     | Username for ssh access (default: root) |


## Credits

This blueprint was developed by our partner researcher **Yuvraj Seegolam**:
- [Github](https://github.com/yuvraj108c)

Original Repository
- [ComfyUI Docker Repository](https://github.com/yuvraj108c/ComfyUI-Docker)