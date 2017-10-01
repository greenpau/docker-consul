# Consul Services

This repository contains Docker files for `consul` service.
The KV (key-value) store functionality of Consul is necessary for
the Docker remote LibNetwork drivers to work.

## Getting Started

First, validate `consul` configuration file:

```
consul validate consul/config
```

Next, start the service with `systemd`.

Once the service is working, check existing members:

```
docker exec -it consul /bin/consul members
```

The expected result is:

```
Node          Address          Status  Type    Build  Protocol  DC   Segment
9a9226b51cec  172.21.0.2:8301  alive   server  0.9.3  2         net  <all>
```

Alternatively, a user may get detailed view:

```
docker exec -it consul /bin/consul members -detailed
docker exec -it consul /bin/consul operator raft -list-peers
```

The expected result is:

```
9a9226b51cec  172.21.0.2:8301  alive   bootstrap=1,build=0.9.3:112c060,dc=net,id=b182a4c7-a17e-c943-541e-ecff8798f940,port=8300,raft_vsn=2,role=consul,segment=<all>,vsn=2,vsn_max=3,vsn_min=2,wan_join_port=8302
```

A user may perform the following queries:

```
docker exec -it consul /bin/consul kv get -keys
docker exec -it consul /bin/consul kv get -recurse docker/
docker exec -it consul /bin/consul kv get -recurse docker/network/v1.0/network/
docker exec -it consul /bin/consul kv get -recurse docker/network/v1.0/endpoint_count/
```

A user may query a Consul server remotely:

```
consul kv get -http-addr=10.1.1.1:8500 -recurse docker/
```

A user may browse to Consul UI: `http://10.1.1.1:8500/ui/`

If necessary review Consul logs:

```
docker logs consul
journalctl -u consul -r
```

## Systemd Service

The following commands help to set up DNS as a service in `systemd`:

```
cd /usr/local/share
cp consul/systemd/consul.service /etc/systemd/system/consul.service
systemctl enable consul
systemctl daemon-reload
systemctl start consul
systemctl status consul
```

If the build did not work, use the following commands for cleanup:

```
systemctl stop consul
docker rm consul
docker rmi greenpau/consul
docker network prune -f
```

If necessary, transfer files to the remote host:

```
scp -i ~/.ssh/id_rsa -r ../consul root@remotehost:/usr/local/share/consul
```

## Firewall

Typically, `/etc/sysconfig/iptables` configuration file holds firewall
configuration on RHEL/CentOS.

First, backup existing firewall configuration:

```
iptables-save > ~/`hostname -s`.`date +%Y%m%d.%H%M%S`.iptables.conf
```

Add the following lines to the file:

```
-A INPUT -p udp --dport 8600 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8300 -j ACCEPT
-A INPUT -p tcp -m state --state NEW -m tcp --dport 8500 -j ACCEPT
```

Reference: [Consul Used Ports](https://www.consul.io/docs/agent/options.html#ports-used)

Verify existing rules:

```
iptables -L -n --line-numbers
```

If necessary, insert entries to `iptables` runtime:

```
iptables -I INPUT 13 -p udp --dport 8600 -j ACCEPT
iptables -I INPUT 13 -p tcp -m state --state NEW -m tcp --dport 8300 -j ACCEPT
iptables -I INPUT 13 -p tcp -m state --state NEW -m tcp --dport 8500 -j ACCEPT
```

Please note, the `13` is the rule number with `REJECT`.

## Docker and Libnetwork

Execute the following command to make Docker utilize Consul K/V store:

```
cat << EOF > /etc/sysconfig/docker-keystore
DOCKER_KEYSTORE_OPTIONS = --cluster-store="consul://consul:8500"
EOF
```
