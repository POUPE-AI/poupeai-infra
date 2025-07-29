FROM kong:3.9.1

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 \
        curl \
        python3-cryptography \
        python3-requests && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/kong && chown -R kong:kong /opt/kong

COPY ./generate_pem.py /scripts/generate_pem.py
COPY ./entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /docker-entrypoint.sh

USER kong