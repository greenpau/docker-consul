FROM alpine:3.3
EXPOSE 8600/udp
EXPOSE 8300
EXPOSE 8500
ADD init.sh /init.sh
ADD consul /bin/consul
VOLUME ["/consul/config", "/consul/data"]
CMD ["/init.sh"]
