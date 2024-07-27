FROM docker.io/python:3.9.19-bookworm

LABEL Maintainer="Mark Taguiad <marktaguiad@tagsdev.xyz>"
LABEL Description="Ansible Alpine"

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /ansible

RUN pip install --upgrade pip
RUN pip install ansible ansible-core argcomplete 

RUN apt update -y && \
    apt install -y sshpass

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    cp kubectl /usr/bin/kubectl

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && \
    chmod +x get_helm.sh && \
    ./get_helm.sh

RUN mkdir -p /app
COPY ./docker/entrypoint.sh /app
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]