FROM voucher/vouch-proxy:0.19.2 as builder

FROM bash:latest

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=builder templates/ templates/
COPY --from=builder .defaults.yml .defaults.yml 
COPY --from=builder static /static
COPY --from=builder /vouch-proxy /vouch-proxy

COPY ./sharpnet/nginx.conf /sharpnet/nginx.conf
COPY ./buildfiles/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 9090
ENTRYPOINT ["/start.sh"]
HEALTHCHECK --interval=1m --timeout=5s CMD [ "/vouch-proxy", "-healthcheck" ]
