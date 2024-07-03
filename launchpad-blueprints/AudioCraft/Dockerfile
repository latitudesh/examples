ARG BASE_IMAGE
FROM $BASE_IMAGE

# Install OpenSSH Server
RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd

WORKDIR /workspace/audiocraft

RUN apt update -y && apt install git wget ffmpeg -y

ARG AUDIOCRAFT_VERSION
RUN git clone https://github.com/GrandaddyShmax/audiocraft_plus . && \
    git checkout tags/${AUDIOCRAFT_VERSION}

RUN python -m venv venv

RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install torch==2.3.0 torchvision torchaudio xformers==0.0.26.post1 jupyterlab

RUN --mount=type=cache,target=/root/.cache/pip \
    . ./venv/bin/activate && \
    pip install -r requirements.txt

COPY --chmod=755 scripts/* .

CMD ["./start.sh"]