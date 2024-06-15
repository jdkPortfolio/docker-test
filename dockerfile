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
    unzip \
    expect

# Install MySQL
RUN apt-get update && apt-get install -y mysql-server

# Install phpMyAdmin
RUN apt-get update && apt-get install -y phpmyadmin

# Configure phpMyAdmin
RUN ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Create MySQL setup script
RUN echo '#!/bin/bash\n\
# Wait for MySQL to fully start\n\
until mysqladmin ping -h localhost --silent; do\n\
    echo "Waiting for MySQL to start..."\n\
    sleep 2\n\
done\n\
# Create MySQL user and grant privileges\n\
mysql -e "CREATE USER '\''myuser'\''@'\''localhost'\'' IDENTIFIED BY '\''mypassword'\'';"\n\
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '\''myuser'\''@'\''localhost'\'' WITH GRANT OPTION;"\n\
mysql -e "FLUSH PRIVILEGES;"\n\
# Allow remote connections (optional, remove if not needed)\n\
mysql -e "CREATE USER '\''myuser'\''@'\''%'\'' IDENTIFIED BY '\''mypassword'\'';"\n\
mysql -e "GRANT ALL PRIVILEGES ON *.* TO '\''myuser'\''@'\''%'\'' WITH GRANT OPTION;"\n\
mysql -e "FLUSH PRIVILEGES;"' > /setup_mysql.sh \
&& chmod +x /setup_mysql.sh

# Create a script to start all services
RUN echo '#!/bin/bash\n\
service mysql start\n\
/setup_mysql.sh\n\
service apache2 start\n\
tail -f /dev/null' > /start-services.sh \
&& chmod +x /start-services.sh

# Expose MySQL port
EXPOSE 3306

# Expose Apache (phpMyAdmin) port
EXPOSE 80

# Default command
CMD ["/start-services.sh"]
