FROM sdal/ldap-ssh-c7
MAINTAINER Aaron D. Schroeder <dads2busy@gmail.com>

ENV PGDATA=/var/lib/pgsql/9.6/data/

RUN yum -y update; yum clean all
RUN yum -y install http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-redhat96-9.6-3.noarch.rpm
RUN yum -y groupinstall "PostgreSQL Database Server 9.6 PGDG"

USER postgres
RUN /usr/pgsql-9.6/bin/pg_ctl initdb -D /var/lib/pgsql/9.6/data/

USER root
RUN systemctl enable postgresql-9.6

COPY create_db_users.sh /usr/bin/create_db_users.sh
RUN chmod +x /usr/bin/create_db_users.sh
#COPY create_db_users.service /etc/systemd/system/custom.target.wants/create_db_users.service

COPY create_db_groups.sh /usr/bin/create_db_groups.sh
RUN chmod +x /usr/bin/create_db_groups.sh
#COPY create_db_groups.service /etc/systemd/system/custom.target.wants/create_db_groups.service

COPY enable_postgis.sh /usr/bin/enable_postgis.sh
RUN chmod +x /usr/bin/enable_postgis.sh
#COPY enable_postgis.service /etc/systemd/system/custom.target.wants/enable_postgis.service

COPY config_db.sh /usr/bin/config_db.sh
RUN chmod +x /usr/bin/config_db.sh
COPY config_db.service /etc/systemd/system/custom.target.wants/config_db.service

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
COPY pg_hba.conf /var/lib/pgsql/9.6/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/9.6/data/postgresql.conf

# Allow auto-creation of roles
RUN groupadd shadow
RUN chown root:shadow /etc/shadow
RUN chown root:shadow /sbin/unix_chkpwd
RUN chmod g+s /sbin/unix_chkpwd

# Add PostGIS
RUN yum -y install postgis2_96

# TCP/IP port
RUN mkdir -p /var/lib/pgsql/data/  && \
    echo "tcpip_socket = true" >> /var/lib/pgsql/data/postgresql.conf

# Add VOLUMEs to allow backup of config, logs and databases
#VOLUME  ["/etc/pgsql", "/var/log/pgsql", "/var/lib/pgsql"]

EXPOSE 5432

CMD ["/lib/systemd/systemd"]

