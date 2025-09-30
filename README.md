# Introduction

This repository provides a ready-to-use Docker configuration for deploying strongSwan VPN using `docker-compose.yml`. For comprehensive details about strongSwan configuration, please refer to the [strongSwan official documentation](https://docs.strongswan.org/).

## Repository Contents

This repository includes:

- **Docker Compose File**: A `docker-compose.yml` file that configures the strongSwan VPN container. Highlights of this setup include:
  - **Privileged Mode**: Required for IPSec kernel modules access.
  - **Host Network Mode**: Ensures VPN traffic is properly handled without NAT issues.
  - **Persistent Configuration**: Configures multiple volumes:
    - `volumes/ipsec.conf` for VPN connection configuration.
    - `volumes/ipsec.secrets` for pre-shared keys (PSK) authentication.
    - `volumes/config/` for additional IPSec configurations.

    This setup ensures that your VPN configurations are preserved when the container is restarted.

- **Configuration Templates**: Example configuration files for setting up site-to-site VPN connections with customizable parameters.

## Getting Started

### Important Preliminary Steps

Before starting the quick setup, please note the following adjustments:

1. **Network Mode**: The `docker-compose.yml` file uses `network_mode: host`, which means the container shares the host's network stack. This is necessary for IPSec to function properly. The container will listen on the host's UDP ports 500 (IKE) and 4500 (NAT-T).

2. **Security Considerations**:
   - Change the default PSK in `volumes/ipsec.secrets` before production use.
   - Use strong encryption: `aes256-sha256-modp2048!`
   - Set proper file permissions: `chmod 600 volumes/ipsec.secrets`

### Quick Setup

1. **Clone the Repository**:
   Clone this repository to your local machine using the following Git command:
   ```bash
   git clone https://github.com/ramuyk/docker-strongswan.git
   cd docker-strongswan
   ```

2. **Configure VPN Connection**:
   Edit `volumes/ipsec.conf` and replace the placeholders:
   - `<remote-ip>`: Remote peer's public IP address 
   - `<remote-range>`: Remote network CIDR 
   - `<range-to-expose>`: Local network to expose through the tunnel

   Edit `volumes/ipsec.secrets` and replace:
   - `<remote-ip>`: Same as in ipsec.conf
   - `change-me-to-a-strong-secret`: Your pre-shared key (generate with `openssl rand -base64 32`)

3. **Start strongSwan**:
   Use the following command to start the VPN service:
   ```bash
   docker compose up -d
   ```

4. **Verify VPN Status**:
   Check the VPN connection status with:
   ```bash
   docker exec strongswan-vpn ipsec status
   ```

## Firewall Configuration

### setup-iptables.sh

The `setup-iptables.sh` script configures iptables rules to allow VPN traffic forwarding and NAT for site-to-site connections.

**Configuration**: Edit the script variables before running:
- `REMOTE_PEER`: Remote peer's IP address
- `LOCAL_NET`: Local network CIDR that should be accessible through the VPN
- `INTERFACE`: Network interface for NAT (e.g., eth0, ens18)

**Usage**:
```bash
sudo bash setup-iptables.sh
```

The script will:
- Allow forwarding between the remote peer and your local network through the IPSec tunnel
- Configure NAT/MASQUERADE so traffic from the remote peer appears to come from your VPN server

## Security Notes

- Always use strong, randomly-generated pre-shared keys
- Keep the strongSwan container image updated: `docker compose pull && docker compose up -d`
- Monitor logs for failed authentication attempts
- Use firewall rules to restrict access to VPN ports from trusted IPs only
- Regularly review and rotate PSK credentials
