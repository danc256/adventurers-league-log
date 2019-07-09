FROM postgres:alpine

COPY ./allow_remote_connections.sh /docker-entrypoint-initdb.d/allow_remote_connections.sh
RUN chmod +x /docker-entrypoint-initdb.d/allow_remote_connections.sh
