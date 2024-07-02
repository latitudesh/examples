ARG BASE_IMAGE

FROM $BASE_IMAGE

WORKDIR /workspace/stable-diffusion-3-medium

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install torch diffusers transformers accelerate sentencepiece gradio protobuf jupyterlab

# Copy HF models
COPY ./cache ./cache

COPY --chmod=755 scripts/* ./

RUN ./setup-ssh.sh

CMD ["./start.sh"]
