# mysql backup image
FROM alpine:3.9
MAINTAINER Avi Deitcher <https://github.com/deitch>

# install the necessary client
# the mysql-client must be 10.3.15 or later
RUN apk add --no-cache --update 'mariadb-client>10.3.15' mariadb-connector-c bash python3 py3-pip py3-cffi py3-cryptography samba-client shadow openssl coreutils && \
    apk add --no-cache --virtual build-deps gcc libffi-dev python3-dev linux-headers musl-dev openssl-dev && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir awscli gsutil && \
    apk del build-deps && \
    rm -rf /var/cache/apk/* && \
    touch /etc/samba/smb.conf

# set us up to run as non-root user
RUN groupadd -g 1005 appuser && \
    useradd -r -u 1005 -g appuser appuser
# ensure smb stuff works correctly
RUN mkdir -p /var/cache/samba && chmod 0755 /var/cache/samba && chown appuser /var/cache/samba
USER appuser

# install the entrypoint
COPY functions.sh /
COPY entrypoint /entrypoint
COPY --chown=appuser files/.boto /home/appuser/.boto
COPY --chown=appuser scripts.d/post-backup/*.sh /scripts.d/post-backup/
RUN chmod +x scripts.d/post-backup/*.sh

# start
ENTRYPOINT ["/entrypoint"]
