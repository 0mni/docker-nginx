FROM nginx:alpine

COPY nginx.conf /etc/nginx/
COPY dhparam.pem /etc/nginx/

RUN apk update \
    && apk upgrade \
    && apk --update add logrotate \
    && apk add --no-cache openssl \
    && apk add --no-cache bash

ARG PUID=33

ENV PUID ${PUID}

ARG PGID=33

ENV PGID ${PGID}

RUN set -x \
    && deluser xfs \
    && delgroup www-data \
    && addgroup -g ${PGID} -S www-data \
    && adduser -u ${PUID} -D -S -G www-data www-data && exit 0 ; exit 1

ARG PHP_UPSTREAM_CONTAINER=php-fpm
ARG PHP_UPSTREAM_PORT=9000

# Set upstream conf and remove the default conf
RUN echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf \
    && rm /var/log/nginx/access.log \
    && touch /var/log/nginx/access.log \
    && chmod -R +r /var/log/nginx

EXPOSE 80 443

CMD ["nginx"]
