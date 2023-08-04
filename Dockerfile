FROM node:20-alpine3.17 as builder

WORKDIR build-your-own-radar

COPY package.json ./
COPY package-lock.json ./
RUN npm ci

COPY . ./
RUN npm run build:prod


FROM nginx:1.23.0
RUN apt-get update && apt-get upgrade -y

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

RUN                                                                       \
  apt-get install -y                                                      \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3    \
  libxss1 libasound2 libxtst6 xauth xvfb g++ make

RUN mkdir -p /opt/build-your-own-radar/files
COPY --from=builder build-your-own-radar/dist/* /opt/build-your-own-radar
COPY --from=builder build-your-own-radar/files/* /opt/build-your-own-radar/files
COPY --from=builder build-your-own-radar/default.template /etc/nginx/conf.d/default.conf

ENV SERVER_NAMES=localhost
