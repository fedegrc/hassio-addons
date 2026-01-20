# Home Assistant Networking Add-ons

Collection of custom add-ons for Home Assistant.

This repository was originally developed for personal use, but is shared publicly in case it might be useful for the community.

## Available Add-ons

### WireGuard Client

WireGuard client for Home Assistant that allows connection to an external WireGuard server.

This add-on was developed to fill a gap in the Home Assistant ecosystem, as there is only one add-on that works as a WireGuard server, not as a client.

**Features:**
- Connect as a client to external WireGuard servers
- Simple configuration through Home Assistant interface
- Automatic VPN connection management

For more details and installation instructions, see the documentation inside the `wireguard-client` directory.

## Repository Installation

To add this repository to your Home Assistant instance:

1. Go to **Supervisor** → **Add-on Store**
2. Click on the three-dot menu (⋮) in the top right corner
3. Select **Repositories**
4. Add the following URL:
   ```
   https://github.com/fedegrc/hassio-addons
   ```
5. The add-ons from this repository will appear in your Add-on Store

## Contributions

If you find any issues or have suggestions, please open an issue in this repository.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.

## Disclaimer

These add-ons are provided "as is", without warranties of any kind. Use them at your own risk.

