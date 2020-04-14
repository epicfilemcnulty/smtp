FROM golang:1.14.1-alpine3.11 AS builder

RUN apk add --no-cache gcc musl-dev git
RUN mkdir -p /src/mailboxer 
COPY mailboxer.go /src/mailboxer/main.go
RUN git clone https://blitiri.com.ar/repos/chasquid /src/chasquid
WORKDIR /src/chasquid
RUN git checkout v1.3
RUN go get -d ./...
RUN go install ./...

WORKDIR /src/mailboxer
RUN go get github.com/amalfra/maildir && go build

FROM alpine:3.11

RUN apk add --no-cache libcap
COPY --from=builder /go/bin/chasquid /usr/bin/
RUN /usr/sbin/setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/chasquid
COPY --from=builder /go/bin/chasquid-util /usr/bin/
COPY --from=builder /go/bin/smtp-check /usr/bin/
COPY --from=builder /src/mailboxer /usr/bin/
RUN mkdir -p /etc/chasquid/domains /etc/chasquid/certs && chown -R mail /etc/chasquid
USER mail
ENTRYPOINT ["/usr/bin/chasquid"]
