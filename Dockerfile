FROM alpine:3.7
RUN apk update \
  && apk add --no-cache ghc su-exec dumb-init
RUN addgroup pmchs \
  && adduser -S -G pmchs pmchs
RUN mkdir -p /pmchs \
  && chown -R pmchs:pmchs /pmchs
COPY main.hs /pmchs
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh
ENTRYPOINT ["docker-entrypoint.sh"]
