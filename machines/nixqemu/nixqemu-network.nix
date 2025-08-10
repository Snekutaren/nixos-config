# networking.nix
# This file defines the networking configuration for your NixOS system.

{ config, pkgs, lib, ... }:

{
  # -------------------------------------------------------------------------
  # General Networking Configuration
  # -------------------------------------------------------------------------

  # Set your hostname. This is a crucial first step for network identification.
  networking.hostName = "nixqemu"; # Set the hostname

  # Configure your network interfaces.
  # This example assumes a wired connection (Ethernet).
  # If you have Wi-Fi, you'll need additional configuration (see notes below).
  networking.networkmanager.enable = true; # Recommended for desktop/laptop users for easy network management

  # If you prefer systemd-networkd for server environments or static IPs:
  # networking.networkd.enable = true;
  # networking.networkd.networks = {
  #   "10-eth0" = {
  #     matchConfig.Name = "eth0"; # Replace eth0 with your actual interface name (e.g., enpXsY)
  #     networkConfig = {
  #       DHCP = "yes";
  #     };
  #   };
  # };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp11s0.useDHCP = lib.mkDefault true;

  # Resolve DNS queries via systemd-resolved (generally recommended)
  # Set specific DNS servers if needed, otherwise DHCP usually handles this.
  #networking.resolvconf.enable = true; # Use resolvconf for DNS management
  #networking.nameservers = [ "1.1.1.1" "8.8.8.8" ]; # Example public DNS servers
  
  # -------------------------------------------------------------------------
  # Firewall Configuration (Using nftables)
  # -------------------------------------------------------------------------

  # CRITICAL: Disable the default iptables-based firewall module
  # when you enable nftables. They conflict if both try to manage the primary ruleset.
  networking.firewall.enable = false;

  # Enable nftables as the primary firewall
  networking.nftables.enable = true;

  # Define your nftables ruleset directly here.
  # This is a basic, secure-by-default (drop policy) ruleset.
  # YOU MUST CUSTOMIZE THIS FOR YOUR SPECIFIC NEEDS!
  networking.nftables.ruleset = ''
    # Define a table for IPv4, IPv6, or mixed (inet) rules
    # 'inet' table applies to both IPv4 and IPv6
    table inet filter {
      # Input chain: Handles incoming traffic destined for the host
      chain input {
        type filter hook input priority 0; policy drop; # Default drop policy for security

        # Allow loopback traffic (essential for many services)
        ip saddr 127.0.0.1 accept
        ip6 saddr ::1 accept

        # Allow established and related connections (e.g., for replies to your outbound requests)
        ct state { established, related } accept

        # --- Open specific ports for services you run on this host ---
        # Example: Allow SSH (port 6622) from anywhere
        tcp dport 6622 accept

        # Example: Allow HTTP (port 80) if you run a web server
        # tcp dport 80 accept

        # Example: Allow HTTPS (port 443) if you run a web server
        # tcp dport 443 accept

        # Example: Allow ICMP (ping) - often useful for diagnostics, but can be dropped for more security
        # icmp type echo-request accept
        # icmpv6 type echo-request accept

        # Add more rules here as needed, e.g.,
        # tcp dport { 3000, 8000 } accept # Example: Allow multiple ports
        # ip saddr 192.168.1.0/24 tcp dport 5432 accept # Example: Allow PostgreSQL from local network

        # Log and drop anything else (if you want to see what's being dropped)
        # log prefix "nft-input-drop: " group 0 counter drop
      }

      # Forward chain: Handles traffic passing through the host (e.g., for routing or NAT)
      # Not typically needed unless your NixOS machine acts as a router.
      chain forward {
        type filter hook forward priority 0; policy drop; # Default drop
        # Add rules here if you need to forward traffic (e.g., for VPNs, containers)
        # For Docker/Podman, NAT rules usually go in the 'nat' table.
      }

      # Output chain: Handles outgoing traffic originating from the host
      # Default policy is usually 'accept' for outbound connections
      chain output {
        type filter hook output priority 0; policy accept;
      }
    }

    # Define a separate 'nat' table for Network Address Translation (e.g., for containers)
    table ip nat {
      # Postrouting chain: Modifies source IP of outgoing packets (e.g., masquerading for internet access)
      chain postrouting {
        type nat hook postrouting priority 100; policy accept;
        # Example: Masquerade traffic from a Podman bridge network
        # This rule assumes 'podman0' is your Podman bridge interface.
        # Replace 10.88.0.0/16 with your actual Podman bridge IP range if different.
        # Be careful: This is a generic example, Podman's netavark might create more complex rules.
        # oifname != "podman0" ip saddr 10.88.0.0/16 masquerade
        # You would typically enable IP forwarding below for this to work.
      }
    }
  '';

  # Enable IP forwarding if your system needs to route traffic between networks
  # (e.g., for containers, VPNs, or if acting as a router)
  # networking.ipForwarding = true;
  # networking.ipv6.extraSysctls = { "net.ipv6.conf.all.forwarding" = 1; }; # For IPv6 forwarding

  # -------------------------------------------------------------------------
  # Containerization (Podman Recommended with nftables)
  # -------------------------------------------------------------------------

  # Enable Podman
  # virtualisation.podman.enable = true;
  # Allow non-root users to run Podman containers
  # virtualisation.podman.enableRootless = true;

  # Notes for Podman and nftables:
  # Podman (especially with its default 'netavark' CNI plugin) is generally more
  # nftables-friendly than Docker. It aims to generate nftables rules directly
  # or use its own internal mechanisms that play better with an nftables-only host.
  # You might still need to add custom nftables rules for complex scenarios,
  # but it's much less likely to conflict than Docker.

  # -------------------------------------------------------------------------
  # Docker (If you insist, but be aware of the challenges with nftables)
  # -------------------------------------------------------------------------
  # If you absolutely need Docker:
  # virtualisation.docker.enable = true;

  # CRITICAL FOR DOCKER WITH Nftables:
  # Setting iptables = false means Docker will NOT create ANY firewall rules.
  # You must then manually create ALL necessary nftables rules for Docker's NAT,
  # port forwarding, and inter-container communication. This is highly complex.
  # virtualisation.docker.daemon.settings = {
  #   iptables = false;
  # };
  # If you enable Docker, you'd also need to enable IP forwarding (networking.ipForwarding = true;).

  # It's generally recommended to stick with the default NixOS firewall (networking.firewall.enable = true;)
  # if you use Docker with its default settings, as it leverages iptables-nft for compatibility.
  # Or, better yet, use Podman with nftables.

  # -------------------------------------------------------------------------
  # Other Networking Options (Uncomment/Add as needed)
  # -------------------------------------------------------------------------

  # For wireless networking (if you use Wi-Fi):
  # networking.wireless.enable = true;
  # services.networkmanager.enable = true; # NetworkManager is great for Wi-Fi management

  # For opening ports for services defined in other modules:
  # Many NixOS service modules have 'openFirewall = true' options.
  # When using `networking.nftables.enable = true;`, these `openFirewall` options
  # *should* generate appropriate nftables rules automatically.
  # Example: services.openssh.openFirewall = true;

  # If you need to specify static IP addresses:
  # networking.interfaces.eth0.useDHCP = false;
  # networking.interfaces.eth0.ipv4.addresses = [
  #   {
  #     address = "192.168.1.100";
  #     prefixLength = 24;
  #   }
  # ];
  # networking.defaultGateway = "192.168.1.1";
}