ARG BASE_IMAGE

FROM $BASE_IMAGE

WORKDIR /workspace/bark

RUN apt-get update && apt-get install git wget -y

COPY requirements.txt .

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install wheel && \
    pip install -r requirements.txt

# Download models
RUN . ./venv/bin/activate && \
    python -c "from bark import preload_models; preload_models()"

# Install other dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install gradio==3.50.2 jupyterlab

COPY --chmod=755 scripts/* ./

CMD ["/workspace/bark/start.sh"]