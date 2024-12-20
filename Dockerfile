FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libreadline-dev \
    libsqlite3-dev \
    libgdbm-dev \
    libdb5.3-dev \
    libbz2-dev \
    libexpat1-dev \
    liblzma-dev \
    tk-dev \
    uuid-dev \
    libffi-dev \
    ca-certificates \
    device-tree-compiler \
    cmake \
    gperf \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Download and build Python 3.12.4
RUN wget https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz \
    && tar xvf Python-3.12.4.tgz \
    && cd Python-3.12.4 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. \
    && rm -rf Python-3.12.4 Python-3.12.4.tgz

# Ensure Python 3.12 is the default version
RUN update-alternatives --install /usr/bin/python3 python3 /usr/local/bin/python3.12 1 \
    && update-alternatives --config python3 \
    && python3 --version

# Install West 1.2.0
RUN pip install west==1.2.0

# Install Zephyr SDK 0.17.0
RUN wget https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.17.0/zephyr-sdk-0.17.0-linux-x86_64-setup.run \
    && chmod +x zephyr-sdk-0.17.0-linux-x86_64-setup.run \
    && ./zephyr-sdk-0.17.0-linux-x86_64-setup.run --quiet -- -d /opt/zephyr-sdk \
    && rm zephyr-sdk-0.17.0-linux-x86_64-setup.run

# Add Zephyr SDK to the PATH
ENV PATH="/opt/zephyr-sdk/bin:$PATH"

# Download nrfutil
RUN wget -O nrfutil https://files.nordicsemi.com/ui/api/v1/download?repoKey=swtools&path=external/nrfutil/executables/x86_64-unknown-linux-gnu/nrfutil&isNativeBrowsing=false && chmod +x nrfutil

# Download nrf command line tools
RUN wget https://nsscprodmedia.blob.core.windows.net/prod/software-and-other-downloads/desktop-software/nrf-command-line-tools/sw/versions-10-x-x/10-24-2/nrf-command-line-tools_10.24.2_amd64.deb -O nrfclt.deb
RUN dpkg -i ./nrfclt.deb


ENV PATH="$PATH:$(pwd)"

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

CMD ["/bin/bash"]
