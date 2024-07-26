ARG BASE_IMAGE

FROM $BASE_IMAGE

WORKDIR /temp/fooocus

RUN apt update -y && apt install git wget curl libgl1 libglib2.0-0 -y

ARG FOOOCUS_VERSION
RUN git clone https://github.com/lllyasviel/Fooocus .
RUN git checkout v${FOOOCUS_VERSION}

# Install dependencies
RUN --mount=type=cache,target=/root/.cache/pip \
    python -m venv ./venv && \
    . ./venv/bin/activate && \
    pip install -r requirements_versions.txt && \
    pip install jupyterlab xformers
    
RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    sed '$d' launch.py > setup.py && \
    python setup.py

COPY --chmod=755 scripts/* .

CMD ["./start.sh"]