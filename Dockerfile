FROM quay.io/vouch/vouch-proxy:0.37

COPY ./sharpnet/nginx.conf /sharpnet/nginx.conf
COPY ./buildfiles/start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 9090
ENTRYPOINT ["/start.sh"]
HEALTHCHECK --interval=1m --timeout=5s CMD [ "/vouch-proxy", "-healthcheck" ]
