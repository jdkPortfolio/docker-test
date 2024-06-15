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
    php-mysql \
    unzip

# Install MySQL
RUN apt-get update && apt-get install -y mysql-server

# Install phpMyAdmin
RUN apt-get update && apt-get install -y phpmyadmin

# Configure MySQL
RUN service mysql start && \
    mysql -e "CREATE USER 'root_ac'@'localhost' IDENTIFIED BY 'mypassword';" && \
    mysql -e "GRANT ALL PRIVILEGES ON *.* TO 'root_ac'@'localhost' WITH GRANT OPTION;" && \
    mysql -e "FLUSH PRIVILEGES;"

# Configure phpMyAdmin
RUN ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Create a script to start all services
RUN echo '#!/bin/bash\n\
service mysql start\n\
service apache2 start\n\
tail -f /dev/null' > /start-services.sh \
&& chmod +x /start-services.sh

# Expose MySQL port
EXPOSE 3306

# Expose Apache (phpMyAdmin) port
EXPOSE 80

# Default command
CMD ["/start-services.sh"]
