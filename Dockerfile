FROM centos:8

#version defined
ENV SWOOLE_VERSION 4.2.12

#install libs
RUN yum install -y curl zip unzip  wget openssl-devel gcc-c++ make autoconf
#install php
RUN yum install -y php-xml  php-devel php-openssl php-mbstring php-json



# hiredis ext
RUN wget https://github.com/redis/hiredis/archive/v0.14.1.tar.gz -O hiredis.tar.gz \
    && mkdir -p hiredis \
    && tar -xf hiredis.tar.gz -C hiredis \
    && rm hiredis.tar.gz \
    && ( \
    cd hiredis/hiredis-0.14.1 \
    && make \
    && make install \
    && ldconfig \
    ) \
    && rm -r hiredis

# composer
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/bin/composer
# use aliyun composer
RUN composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/

# swoole ext
RUN wget https://github.com/swoole/swoole-src/archive/v${SWOOLE_VERSION}.tar.gz -O swoole.tar.gz \
    && mkdir -p swoole \
    && tar -xf swoole.tar.gz -C swoole --strip-components=1 \
    && rm swoole.tar.gz \
    && ( \
    cd swoole \
    && phpize \
    && ./configure --enable-openssl --enable-async-redis \
    && make \
    && make install \
    ) \
    && sed -i "2i extension=swoole.so" /etc/php.ini \
    && rm -r swoole

# Dir
WORKDIR /easyswoole

EXPOSE 9501
