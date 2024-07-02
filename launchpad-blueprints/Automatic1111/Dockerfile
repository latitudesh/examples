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
# Add inswapper model for the ReActor extension
RUN aria2c --console-log-level=error -c -x 16 -s 16 -k 1M "https://github.com/facefusion/facefusion-assets/releases/download/models/inswapper_128.onnx" -d " /models/insightface" -o "inswapper_128.onnx"

# -------------------------------------------------------------------Final---------------------------------------------------------------------
FROM $BASE_IMAGE as final

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so.4

RUN apt update -y && apt install git wget libgl1 libglib2.0-0 google-perftools -y

ARG WEBUI_VERSION
WORKDIR /temp/a1111

RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui .
RUN git checkout v${WEBUI_VERSION}

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install --upgrade pip && \
    pip install -r requirements.txt && \
    deactivate

# Clone extensions
RUN git clone --depth=1 https://github.com/Mikubill/sd-webui-controlnet.git extensions/sd-webui-controlnet && \
    git clone --depth=1 https://github.com/deforum-art/sd-webui-deforum.git extensions/deforum && \
    git clone --depth=1 https://github.com/Bing-su/adetailer.git extensions/adetailer && \
    git clone --depth=1 https://github.com/Uminosachi/sd-webui-inpaint-anything.git extensions/inpaint-anything && \
    git clone --depth=1 https://github.com/Gourieff/sd-webui-reactor.git extensions/sd-webui-reactor

# Install extension dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    python -c 'from modules import launch_utils; launch_utils.prepare_environment()' --skip-torch-cuda-test && \
    deactivate

# Configure ReActor to use the GPU instead of the CPU
RUN echo "CUDA" > extensions/sd-webui-reactor/last_device.txt

# Copy models
COPY --from=sd-models /models/Stable-diffusion ./models/Stable-diffusion
COPY --from=sd15-controlnet-models /models/ControlNet ./models/ControlNet
COPY --from=other-models /models/VAE ./models/VAE
COPY --from=other-models /models/Lora ./models/Lora
COPY --from=other-models /models/insightface ./models/insightface

RUN apt install gcc g++ -y

# Final setup
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install insightface && \
    python -c 'from modules import shared_init, initialize; shared_init.initialize(); initialize.initialize()' --opt-sdp-attention && \
    deactivate

# Jupyterlab
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install jupyterlab && \
    deactivate

COPY --chmod=755 scripts/* .

CMD ["./start.sh"]