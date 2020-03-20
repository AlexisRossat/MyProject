FROM composer as composer
FROM node:12.13 as node
FROM php:7.2-apache

# On envoie le nom du serveur à apache, c'est avec ça que l'on appelera nos pages
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

RUN apt-get update && \
    apt-get install -y git zip tar libpq-dev libicu-dev &&\
    apt-get install libldap2-dev -y &&\
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-install ldap && \
    docker-php-ext-configure intl && \
    docker-php-ext-install intl

RUN docker-php-ext-install pdo_mysql \
    mysqli

COPY --from=composer /usr/bin/composer /usr/local/bin/composer

COPY --from=node /opt/yarn-v1.19.1/bin/yarn /usr/local/bin/yarn
COPY --from=node /opt/yarn-v1.19.1/bin/yarn.js /usr/local/bin/yarn.js
COPY --from=node /opt/yarn-v1.19.1/lib/cli* /usr/local/lib/cli
COPY --from=node /usr/local/bin/nodejs /usr/local/bin/node

RUN chmod +x /usr/local/bin/composer

# On créé un utilisateur avec le même gid/uid que votre local
# cela va permettre que les fichiers qui sont créés dans le contenaire auront vos droits
RUN addgroup --system {user} --gid 1000 && adduser --system {user} --uid 1000 --ingroup {user}
