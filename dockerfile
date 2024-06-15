# Use Ubuntu as base image
FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update apt and install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    apache2 \
    php \
    libapache2-mod-php \
    unzip

# Install MySQL
RUN apt-get update && apt-get install -y mysql-server

# Install PostgreSQL
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && apt-get install -y postgresql postgresql-contrib

# Install phpMyAdmin
RUN apt-get update && apt-get install -y phpmyadmin

# Install pgAdmin
RUN curl https://www.pgadmin.org/static/packages_pgadmin_org.pub | apt-key add && \
    sh -c 'echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list && apt update' && \
    apt install -y pgadmin4-web && \
    /usr/pgadmin4/bin/setup-web.sh

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs

# Install Java 21
RUN wget -O /tmp/jdk-21_linux-x64_bin.deb https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.deb && \
    apt-get install -y /tmp/jdk-21_linux-x64_bin.deb && \
    rm /tmp/jdk-21_linux-x64_bin.deb

# Clean up
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Create script to start all services
RUN echo '#!/bin/bash\n\
service mysql start\n\
service postgresql start\n\
service apache2 start\n\
# Configure phpMyAdmin\n\
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin\n\
# Configure pgAdmin\n\
sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf\n\
service apache2 restart\n\
# Keep the container running\n\
tail -f /dev/null' > /start-services.sh \
&& chmod +x /start-services.sh

# Expose MySQL port
EXPOSE 3306

# Expose PostgreSQL port
EXPOSE 5432

# Expose phpMyAdmin port
EXPOSE 80

# Expose pgAdmin port
EXPOSE 8080

# Default command
CMD ["/start-services.sh"]
