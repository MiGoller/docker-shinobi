#
# Builds a custom docker image for ShinobiCCTV Pro MySQL database
#
#
#   WARNING:
#   When using docker-compose you will have to run docker-compose two times,
#   otherwise Shinobi will not be able to access the database!
#   See "No connections until MySQL init completes" at the MySQL Docker Hub
#   page https://hub.docker.com/_/mysql/ .
#

FROM mysql:latest

LABEL Author="MiGoller"

# Set environment variables to default values for Shinobi
ENV MYSQL_USER=majesticflame \
    MYSQL_PASSWORD=password \
    MYSQL_HOST=127.0.0.1 \
    MYSQL_DATABASE=ccio

# Set environment variables to default values for MySQL
ENV MYSQL_ROOT_PASSWORD= 

# Create the /docker-entrypoint-initdb.d directory
# See https://hub.docker.com/_/mysql/ "Initializing a fresh instance"
RUN mkdir -p /docker-entrypoint-initdb.d

# Copy code
COPY ./framework.sql /docker-entrypoint-initdb.d/001_framework.sql
COPY ./default_data.sql /docker-entrypoint-initdb.d/002_default_data.sql

# Set database name from environment variable for initial tasks ...
RUN sed -i -e "s/ccio/${MYSQL_DATABASE}/g" "/docker-entrypoint-initdb.d/001_framework.sql"
RUN sed -i -e "s/ccio/${MYSQL_DATABASE}/g" "/docker-entrypoint-initdb.d/002_default_data.sql"

# Permit execution rights on shell files in /docker-entrypoint-initdb.d
RUN chmod -f +x /docker-entrypoint-initdb.d/*.sh || true
