#!/command/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: WireGuard Client
# Creates the interface configuration for client mode
# ==============================================================================
declare addresses
declare allowed_ips
declare client_private_key
declare config
declare dns
declare endpoint
declare fwmark
declare interface
declare keep_alive
declare mtu
declare post_down
declare post_up
declare pre_down
declare pre_shared_key
declare pre_up
declare server_public_key
declare table

if ! bashio::fs.directory_exists '/ssl/wireguard'; then
    mkdir -p /ssl/wireguard ||
        bashio::exit.nok "Could not create wireguard storage folder!"
fi

# Get interface and config file location
interface="wg0"
if bashio::config.has_value "client.interface"; then
    interface=$(bashio::config "client.interface")
fi
config="/etc/wireguard/${interface}.conf"

# Start creation of configuration
echo "[Interface]" > "${config}"

# Check if at least 1 address is specified for client
if ! bashio::config.has_value 'client.addresses'; then
    bashio::exit.nok 'You need at least 1 address configured for the client'
fi

# Add all client addresses to the configuration
for address in $(bashio::config 'client.addresses'); do
    [[ "${address}" == *"/"* ]] || address="${address}/24"
    echo "Address = ${address}" >> "${config}"
done

# Add DNS addresses to the configuration (optional)
if bashio::config.has_value 'client.dns'; then
    dns_list=$(bashio::config 'client.dns')
    if [[ "${dns_list}" != "[]" && -n "${dns_list}" ]]; then
        for dns in $(bashio::config 'client.dns'); do
            echo "DNS = ${dns}" >> "${config}"
        done
    fi
fi

# Get the client's private key
if ! bashio::config.has_value 'client.private_key'; then
    bashio::exit.nok 'You need to configure the client private key'
fi
client_private_key=$(bashio::config 'client.private_key')

# Get configuration values
fwmark=$(bashio::config "client.fwmark")
mtu=$(bashio::config "client.mtu")
pre_down=$(bashio::config "client.pre_down")
pre_up=$(bashio::config "client.pre_up")
table=$(bashio::config "client.table")

# Pre Up & Down handling
if [[ "${pre_up}" = "off" ]]; then
    pre_up=""
fi
if [[ "${pre_down}" = "off" ]]; then
    pre_down=""
fi

# Post Up & Down defaults (client routing)
post_up=""
post_down=""
if bashio::config.has_value 'client.post_up'; then
    post_up=$(bashio::config 'client.post_up')
    if [[ "${post_up}" = "off" ]]; then
        post_up=""
    fi
fi

if bashio::config.has_value 'client.post_down'; then
    post_down=$(bashio::config 'client.post_down')
    if [[ "${post_down}" = "off" ]]; then
        post_down=""
    fi
fi

# Finish up the main client configuration
{
    echo "PrivateKey = ${client_private_key}"

    # Custom routing table
    bashio::config.has_value "client.table" && echo "Table = ${table}"

    # Pre up & down
    bashio::config.has_value "client.pre_up" && echo "PreUp = ${pre_up}"
    bashio::config.has_value "client.pre_down" && echo "PreDown = ${pre_down}"

    # Post up & down
    bashio::var.has_value "${post_up}" && echo "PostUp = ${post_up}"
    bashio::var.has_value "${post_down}" && echo "PostDown = ${post_down}"

    # fwmark for outgoing packages
    bashio::config.has_value "client.fwmark" && echo "FwMark = ${fwmark}"

    # Custom MTU setting
    bashio::config.has_value "client.mtu" && echo "MTU = ${mtu}"

    # End interface section with an empty line
    echo ""
} >> "${config}"

# Configure server peer
if ! bashio::config.has_value 'server.public_key'; then
    bashio::exit.nok 'You need to configure the server public key'
fi

if ! bashio::config.has_value 'server.endpoint'; then
    bashio::exit.nok 'You need to configure the server endpoint'
fi

server_public_key=$(bashio::config 'server.public_key')
endpoint=$(bashio::config 'server.endpoint')
pre_shared_key=$(bashio::config 'server.pre_shared_key')

# Get allowed IPs for server
if bashio::config.has_value 'server.allowed_ips'; then
    allowed_ips=$(bashio::config "server.allowed_ips | join(\", \")")
else
    allowed_ips="0.0.0.0/0, ::/0"  # Default: route all traffic through VPN
fi

# Get persistent keep alive
keep_alive=25
if bashio::config.has_value 'server.persistent_keep_alive'; then
    keep_alive=$(bashio::config 'server.persistent_keep_alive')
fi

# Write server peer configuration
{
    echo "[Peer]"
    echo "PublicKey = ${server_public_key}"
    echo "Endpoint = ${endpoint}"
    echo "AllowedIPs = ${allowed_ips}"
    echo "PersistentKeepalive = ${keep_alive}"
    bashio::config.has_value "server.pre_shared_key" \
        && echo "PreSharedKey = ${pre_shared_key}"
    echo ""
} >> "${config}"

# Store client public key for the status API
client_public_key=$(wg pubkey <<< "${client_private_key}")
filename=$(sha1sum <<< "${client_public_key}" | awk '{ print $1 }')
echo -n "client" > "/ssl/wireguard/${filename}"

bashio::log.info "WireGuard client configuration created successfully"