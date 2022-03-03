FROM debian:buster


# Steps done in one RUN layer:
# - Install packages
# - OpenSSH needs /var/run/sshd to run
# - Remove generic host keys, entrypoint generates unique key
RUN apt-get upgrade && \
    apt-get update && \
    apt-get -y install openssh-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/sshd && \
    mkdir -p /home/int-etlcolombia-co/fs  \
             /home/int-etlpanama-pa/fs  \
             /home/int-etlperu-pe/fs  \
             /home/int-etlchile-cl/fs  \
             /home/ext-oracleerp-global/fs && \
    rm -f /etc/ssh/ssh_host_*key* && \
    addgroup --gid 10001 sftp-ext && \
    addgroup --gid 10002 sftp-int && \
    chown root /home/int-etlcolombia-co && \
    chmod go-w /home/int-etlcolombia-co && \
    chown root /home/int-etlpanama-pa && \
    chmod go-w /home/int-etlpanama-pa && \
    chown root /home/int-etlchile-cl && \
    chmod go-w /home/int-etlchile-cl && \
    chown root /home/int-etlperu-pe && \
    chmod go-w /home/int-etlperu-pe && \
    chown root /home/ext-oracleerp-global && \
    chmod go-w /home/ext-oracleerp-global && \
    chown -R 10001:10001 /home/ext-oracleerp-global/fs && \
    chown -R 10002:10002 /home/int-etlcolombia-co/fs && \
    chown -R 10003:10002 /home/int-etlpanama-pa/fs && \
    chown -R 10004:10002 /home/int-etlperu-pe/fs && \
    chown -R 10005:10002 /home/int-etlchile-cl/fs && \
    chmod -R 770 /home/ext-oracleerp-global/fs && \
    chmod -R 770 /home/int-etlcolombia-co/fs && \
    chmod -R 770 /home/int-etlpanama-pa/fs && \
    chmod -R 770 /home/int-etlperu-pe/fs && \
    chmod -R 770 /home/int-etlchile-cl/fs

RUN mkdir -p /home/int-sapetl-interno-pan/fs \
            /home/int-sapetl-interno-cl/fs \
            /home/int-sapetl-interno-pe/fs \
            /home/int-sapetl-interno-col/fs

RUN chown -R 10006:10002 /home/int-sapetl-interno-pan/fs && \
    chown -R 10007:10002 /home/int-sapetl-interno-cl/fs && \
    chown -R 10008:10002 /home/int-sapetl-interno-pe/fs && \
    chown -R 10009:10002 /home/int-sapetl-interno-col/fs

RUN chmod -R 770 /home/int-sapetl-interno-pan/fs && \
    chmod -R 770 /home/int-sapetl-interno-cl/fs && \
    chmod -R 770 /home/int-sapetl-interno-pe/fs && \
    chmod -R 770 /home/int-sapetl-interno-col/fs

COPY files/sshd_config /etc/ssh/sshd_config
COPY files/users.conf /etc/sftp/users.conf
COPY files/create-sftp-user /usr/local/bin/
COPY files/entrypoint /entrypoint

RUN chmod 770 /entrypoint
RUN chmod 770 /etc/ssh/sshd_config
RUN chmod 770 /etc/sftp/users.conf
RUN chmod 770 /usr/local/bin/create-sftp-user

RUN apt autoclean

EXPOSE 22

ENTRYPOINT ["/entrypoint"]
