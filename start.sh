#!/bin/sh

UUID=8f91b6a0-e8ee-11ea-adc1-0242ac120002
V2RAYPATH=/v2raypath
PORT=80
# config caddy
mkdir -p /usr/share/caddy
wget -O /usr/share/caddy/index.html https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html
cat << EOF > /etc/caddy/Caddyfile
:$PORT
root * /usr/share/caddy
file_server

@websocket_v2ray {
header Connection *Upgrade*
header Upgrade    websocket
path $V2RAYPATH
}
reverse_proxy @websocket_v2ray 127.0.0.1:4234
EOF

# config v2ray
cat << EOF > /v2ray.json
{
    "inbounds": 
    [
        {
            "port": 4234,"listen": "127.0.0.1","protocol": "vless",
            "settings": {"clients": [{"id": "$UUID"}],"decryption": "none"},
            "streamSettings": {"network": "ws","wsSettings": {"path": "$V2RAYPATH"}}
        }
    ],
    "outbounds": [{"protocol": "freedom"}]
}	
EOF

# start
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &

/v2ray -config /v2ray.json
