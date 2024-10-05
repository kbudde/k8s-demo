
Just a quickfix:

    docker build -f python.Dockerfile . -t kbudde/tmp:openvscode-python
    docker push kbudde/tmp:openvscode-python

TODO: Proper build
TODO: Display Language support: https://github.com/gitpod-io/openvscode-server/issues/574