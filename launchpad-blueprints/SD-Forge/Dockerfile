ARG BASE_IMAGE

FROM debian:12-slim as base-model-downloader
RUN apt update && apt install aria2 -y

# -------------------------------------------------------------------SD1.5 CONTROLNETS----------------------------------------------------------------
FROM base-model-downloader as sd15-controlnet-models
ARG SAVE_DIR="/models/ControlNet"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_openpose.pth" -d ${SAVE_DIR} -o "control_v11p_sd15_openpose.pth"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11f1p_sd15_depth.pth" -d ${SAVE_DIR} -o "control_v11f1p_sd15_depth.pth"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/lllyasviel/ControlNet-v1-1/resolve/main/control_v11p_sd15_lineart.pth" -d ${SAVE_DIR} -o "control_v11p_sd15_lineart.pth"

# -------------------------------------------------------------------SD Models---------------------------------------------------------------------
FROM base-model-downloader as sd-models
ARG SAVE_DIR="/models/Stable-diffusion"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/jzli/DreamShaper-8/resolve/main/dreamshaper_8.safetensors" -d ${SAVE_DIR} -o "dreamshaper_8.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors" -d ${SAVE_DIR} -o "sd_xl_base_1.0.safetensors"
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors" -d ${SAVE_DIR} -o "sd_xl_refiner_1.0.safetensors"

# -------------------------------------------------------------------Other Models---------------------------------------------------------------------
FROM base-model-downloader as other-models
# vae
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.ckpt" -d "/models/VAE" -o "vae-ft-mse-840000-ema-pruned.ckpt"
# lora
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://huggingface.co/latent-consistency/lcm-lora-sdv1-5/resolve/main/pytorch_lora_weights.safetensors" -d "/models/Lora" -o "lcm_sd15.safetensors"


# -------------------------------------------------------------------Final Setup---------------------------------------------------------------------
FROM $BASE_IMAGE as final

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4

RUN apt update -y && apt install git wget libgl1 libglib2.0-0 google-perftools -y

WORKDIR /temp/stable-diffusion-webui-forge

ARG FORGE_SHA
RUN git clone https://github.com/lllyasviel/stable-diffusion-webui-forge.git .
RUN git checkout ${FORGE_SHA}

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt

# Clone extensions
RUN git clone --depth=1 https://github.com/deforum-art/sd-forge-deforum.git extensions/deforum

# Copy models
COPY --from=sd-models /models/Stable-diffusion ./models/Stable-diffusion
COPY --from=sd15-controlnet-models /models/ControlNet ./models/ControlNet
COPY --from=other-models /models/VAE ./models/VAE
COPY --from=other-models /models/Lora ./models/Lora

RUN apt install gcc g++ -y

# Install insightface + jupyterlab
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install insightface jupyterlab

# Install extensions dependencies + final setup
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    python3 -c "from launch import prepare_environment; prepare_environment()" --skip-torch-cuda-test

COPY --chmod=755 scripts/* ./

CMD ["./start.sh"]
