FROM redis:5.0
WORKDIR /data

RUN apt-get update && apt-get -y install curl
ENV k8sversion v1.9.2
RUN curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$k8sversion/bin/linux/amd64/kubectl \
&& chmod +x /tmp/kubectl \
&& mv /tmp/kubectl /usr/local/bin/
