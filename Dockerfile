FROM node:12.16.3

WORKDIR /src
ADD . /src

RUN npm install
RUN npm run compile
