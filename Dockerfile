FROM debian:jessie-slim

LABEL maintainer="david@itarverne.fr"

RUN apt-get -y update 
RUN apt-get -y install nginx-extras libpcre3-dev build-essential libssl-dev wget gettext-base

RUN  cd /tmp && wget https://nginx.org/download/nginx-1.15.5.tar.gz && tar zxvf nginx-1.15.5.tar.gz

RUN rm -rf *.tar.gz

RUN cd /tmp && wget --no-check-certificate https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz && tar zxvf v0.33.tar.gz

RUN cd /tmp && ls -l

RUN cd /tmp/nginx-1.15.5 && \
            ./configure \
            --prefix=/etc/nginx \
            --sbin-path=/usr/sbin/nginx \
            --conf-path=/etc/nginx/nginx.conf \
            --with-http_gunzip_module \
            --with-http_ssl_module \
            --with-http_v2_module \
            --add-module=/tmp/headers-more-nginx-module-0.33 

RUN cd /tmp/nginx-1.15.5 && \
        make && \
        make install

RUN rm -r /tmp

RUN rm -rf /etc/nginx/sites-enabled/default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /etc/nginx/ssl
RUN chmod 600 -R /etc/nginx/ssl
RUN chown -R root:root /etc/nginx/ssl

CMD ["nginx", "-g", "daemon off;"]