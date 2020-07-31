FROM golang:1.14.6-alpine3.12 AS builder

RUN apk add --no-cache gcc musl-dev git
RUN mkdir -p /src/mailboxer 
COPY mailboxer.go /src/mailboxer/main.go
RUN git clone https://blitiri.com.ar/repos/chasquid /src/chasquid
WORKDIR /src/chasquid
RUN git checkout v1.4
RUN go build
RUN cd cmd/chasquid-util && go build
RUN cd cmd/smtp-check && go build

WORKDIR /src/mailboxer
RUN go get github.com/amalfra/maildir && go build

FROM alpine:3.12

RUN apk add --no-cache libcap lua
COPY --from=builder /src/chasquid/chasquid /usr/bin/
RUN /usr/sbin/setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/chasquid
COPY --from=builder /src/chasquid/cmd/chasquid-util/chasquid-util /usr/bin/
COPY --from=builder /src/chasquid/cmd/smtp-check/smtp-check /usr/bin/
COPY --from=builder /src/mailboxer/mailboxer /usr/bin/
RUN mkdir -p /etc/chasquid/domains /etc/chasquid/certs && chown -R mail /etc/chasquid
COPY generate-alias-files.lua /usr/local/bin/
COPY entrypoint.sh /
USER mail
WORKDIR /etc/chasquid
ENTRYPOINT ["/entrypoint.sh"]
