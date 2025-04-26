FROM dart:stable AS benchmark

# Install dependencies
WORKDIR /app
COPY pubspec.* .
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN ls -la
RUN dart run

FROM node:23-slim as build_docs

WORKDIR /app/docs

COPY /docs/package.json .

RUN npm install

RUN ls -la

COPY ./docs/. .

RUN ls -la /app/docs/data

COPY --from=benchmark /app/docs/data ./data

RUN ls -la

RUN npm run docs:build

FROM nginx:alpine

COPY --from=build_docs /app/docs/.vitepress/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]