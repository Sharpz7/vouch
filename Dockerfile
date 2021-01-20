FROM voucher/vouch-proxy:latest as builder

COPY ./sharpnet/nginx.conf /sharpnet/nginx.conf

FROM bash:latest

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder templates/ templates/
COPY --from=builder .defaults.yml .defaults.yml 
COPY --from=builder static /static
COPY --from=builder /go/bin/vouch-proxy /vouch-proxy

EXPOSE 9090
ENTRYPOINT ["/vouch-proxy"]
HEALTHCHECK --interval=1m --timeout=5s CMD [ "/vouch-proxy", "-healthcheck" ]
