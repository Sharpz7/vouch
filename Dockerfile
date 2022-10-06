FROM quay.io/vouch/vouch-proxy:0.37 as builder

FROM bash:latest

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /vouch-proxy /vouch-proxy

COPY ./sharpnet/nginx.conf /sharpnet/nginx.conf
COPY ./buildfiles/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 9090
ENTRYPOINT ["/start.sh"]
HEALTHCHECK --interval=1m --timeout=5s CMD [ "/vouch-proxy", "-healthcheck" ]
