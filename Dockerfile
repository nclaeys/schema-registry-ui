FROM alpine
WORKDIR /
RUN apk add --no-cache ca-certificates nodejs-npm \
    && echo "progress = dot:giga" | tee /etc/wgetrc
RUN npm i npm@latest -g; \
    npm install -g bower

WORKDIR /build

ADD src src
ADD *.js ./
ADD package.json ./

RUN npm install
RUN npm run-script build-prod


FROM alpine
WORKDIR /
RUN apk add --no-cache ca-certificates wget \
    && echo "progress = dot:giga" | tee /etc/wgetrc
RUN wget "https://github.com/mholt/caddy/releases/download/v0.10.11/caddy_v0.10.11_linux_amd64.tar.gz" -O /caddy.tgz \
    && mkdir caddy \
    && tar xzf caddy.tgz -C /caddy --no-same-owner \
    && rm -f /caddy.tgz

COPY --from=0 /build/dist/ /schema-registry-ui/

RUN rm -f /schema-registry-ui/env.js \
    && ln -s /tmp/env.js /schema-registry-ui/env.js

ADD docker/Caddyfile /caddy/Caddyfile.template
ADD docker/run.sh /
RUN chmod +x /run.sh

EXPOSE 8000
ENTRYPOINT ["/run.sh"]
