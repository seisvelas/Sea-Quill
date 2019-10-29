# Using 'latest' like this is a little foolish. A newer version
# release could break our whole build.
FROM debian:latest

# Move files into Docker
COPY . /root
WORKDIR /root
RUN cp ./SQL/* "./Source Code"

# Install Racket & libraries
RUN apt-get update
RUN apt-get install software-properties-common -y
RUN apt-get install gpg -y
RUN add-apt-repository ppa:plt/racket -y
RUN apt-get install racket -y
RUN raco pkg install --auto beautiful-racket
RUN raco pkg install --auto threading

# Useful for debugging
RUN apt install vim -y
RUN apt install curl -y

# Install Postgres
RUN apt-get install postgresql postgresql-client -y

# Install & run Apache
RUN apt install apache2 -y
RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_balancer
RUN a2enmod lbmethod_byrequests
RUN . /etc/apache2/envvars

# Add reverse proxying for multiple apps
CMD ["./Scripts/sql-proxies.sh", ">", "docker.log"]

