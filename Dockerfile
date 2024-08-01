# Start with the base Alpine image
FROM alpine:latest

# Install required packages for building NGINX and the module
RUN apk add --no-cache \
    build-base \
    pcre-dev \
    zlib-dev \
    openssl-dev \
    wget \
    tar \
    gzip \
    bash \
    unzip

# Set environment variable for NGINX version
ENV NGINX_VERSION 1.25.5

# Download and extract NGINX
RUN wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz && \
    tar -zxvf nginx-$NGINX_VERSION.tar.gz

# Download and extract the substitutions filter module
RUN wget https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/refs/heads/master.zip && \
    unzip master.zip && \
    mv ngx_http_substitutions_filter_module-master ngx_http_substitutions_filter_module

# Build and install NGINX with the module
RUN cd nginx-$NGINX_VERSION && \
    ./configure --with-compat --add-dynamic-module=../ngx_http_substitutions_filter_module && \
    make && \
    make install

# Clean up unnecessary packages and files
RUN apk del build-base wget tar gzip unzip && \
    rm -rf /var/cache/apk/* /nginx-$NGINX_VERSION /nginx-$NGINX_VERSION.tar.gz /master.zip

# Default command
CMD ["nginx", "-g", "daemon off;"]