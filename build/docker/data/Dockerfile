FROM nhsd/postgres:latest

COPY assets/ /

RUN set -ex && \
    \
    find /sql -type d -exec chmod 777 {} \; && \
    find /sql -type f -exec chmod 666 {} \; && \
    find /script -type d -exec chmod 777 {} \; && \
    find /script -type f -exec chmod 666 {} \;
