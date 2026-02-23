FROM dart:stable AS benchmark

# Install dependencies
WORKDIR /app
COPY pubspec.* .
RUN dart pub get

# Install pinned oha for HTTP benchmarks
RUN apt-get update && apt-get install -y curl ca-certificates \
	&& curl -L https://github.com/hatoo/oha/releases/download/v0.6.4/oha-linux-amd64 -o /usr/local/bin/oha \
	&& chmod +x /usr/local/bin/oha \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

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