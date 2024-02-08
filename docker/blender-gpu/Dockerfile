FROM nvidia/cuda:12.0.0-base-ubuntu22.04

## GPU DOCKERFILE


ARG BLENDER_VERSION=${BLENDER_VERSION}
ARG BLENDER_VERSION_MAJOR=${BLENDER_VERSION_MAJOR}
ENV BLENDER_URL https://mirror.clarkson.edu/blender/release/Blender${BLENDER_VERSION}/blender-${BLENDER_VERSION_MAJOR}-linux-x64.tar.xz

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y \
    sudo \
    curl \
    ca-certificates \
    zip \
    xz-utils \
    python3 \
    python3-pip 


# Download and install Blender
RUN curl "${BLENDER_URL}" -o "blender.tar.xz" && \
    tar -xvf blender.tar.xz --strip-components=1 -C /bin && \
    rm -rf blender.tar.xz && \
    rm -rf blender

# # Copy FFmpeg to the root of the container and unzip it
# RUN curl "https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz" -o "ffmpeg.tar.xz" && \
#     tar -xvf ffmpeg.tar.xz --strip-components=1 -C /bin && \
#     rm -rf ffmpeg.tar.xz && \
#     rm -rf ffmpeg

RUN apt-get update -y && \
    apt-get install -y \
    libx11-dev \
    libxi-dev \
    libxxf86vm-dev \
    libfontconfig1 \
    libxrender1 \
    libgl1-mesa-glx \
    libxkbcommon-x11-0 \
    libsm6

# Copy the script to the root of the container and give it permission to be executed
COPY ./app.py /
RUN chmod +x /app.py

ENTRYPOINT ["python3", "/app.py"]
