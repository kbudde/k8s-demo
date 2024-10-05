FROM gitpod/openvscode-server:latest

USER root
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
USER openvscode-server 

ENV OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
ENV OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"

SHELL ["/bin/bash", "-c"]
RUN \
    exts=(\
        # From https://open-vsx.org/ registry directly
        ms-python.python \
        # unsupported: ms-ceintl.vscode-language-pack-de \
    )\
    # Install the $exts
    && for ext in "${exts[@]}"; do ${OPENVSCODE} --install-extension "${ext}"; done \
    && mkdir -p /home/workspace/.openvscode-server/data/User \
    && mkdir -p /home/workspace/projects
