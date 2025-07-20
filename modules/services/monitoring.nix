# modules/services/monitoring-stack.nix
{ config, pkgs, lib, ... }:

{
  # 1. Prometheus Node Exporter (Metrics Agent)
  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
    # You can enable specific collectors if needed, e.g.:
    # enabledCollectors = [ "systemd" "diskstats" "netdev" ];
  };

  # 2. Prometheus Server (Metrics Database and Scraper)
  services.prometheus.server = {
    enable = true;
    port = 9090; # Default Prometheus UI port
    extraFlags = [ "--web.listen-address=:9090" ]; # Ensure it listens on all interfaces

    # Configure Prometheus to scrape the local Node Exporter
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
            labels = { instance = config.networking.hostName; }; # Use hostname for instance label
          }
        ];
      }
      # Add other scrape configs here if you later decide to monitor other things
      # For example, if you run other applications with /metrics endpoints.
    ];
  };

  # 3. Loki (Log Aggregation System)
  # Note: services.loki is still marked as 'experimental' as of Nixpkgs 24.05,
  # but it's generally stable for single-node setups.
  services.loki = {
    enable = true;
    listenAddress = "0.0.0.0"; # Listen on all interfaces
    port = 3100; # Default Loki port
    configuration = {
      auth_enabled = false; # Good for local setup, use true for production with authentication
      server.http_listen_port = config.services.loki.port; # Link to the defined port

      common = {
        path_prefix = "/var/lib/loki"; # Base directory for Loki data
        storage = {
          filesystem = {
            directory = "/var/lib/loki/data"; # Storage for chunks
          };
        };
        replication_factor = 1; # For single node
        ring = {
          instance_addr = "127.0.0.1"; # Or "::1" for IPv6 if preferred
          kvstore = {
            store = "inmemory"; # For single node, in-memory is fine for ring.
          };
        };
      };

      schema_config.configs = [
        {
          from = "2020-10-24"; # Date when this schema version was introduced
          store = "boltdb-shipper"; # Efficient storage engine for chunks
          object_store = "filesystem"; # Store objects (chunks) on filesystem
          schema = "v11"; # Latest recommended schema
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
    };
  };

  # 4. Grafana Agent (Log Collector - replaces Promtail)
  # The Grafana Agent can collect both metrics and logs. Here, we'll configure it for logs.
  services.grafana-agent = {
    enable = true;
    settings = {
      logs = {
        configs = [
          {
            name = "default"; # A name for this log configuration
            clients = [
              {
                url = "http://localhost:${toString config.services.loki.port}/loki/api/v1/push"; # Push logs to local Loki
              }
            ];
            # Scrape configurations for various log sources
            scrape_configs = [
              # Systemd Journal logs (covers syslog, dmesg, journalctl entries)
              {
                job_name = "journal";
                journal = {
                  path = "/run/log/journal"; # Standard path for journal logs
                  max_age = "12h"; # Only collect logs from the last 12 hours initially
                  # Also needs access to /etc/machine-id for proper identification
                  # This is handled by the Grafana Agent service unit's permissions.
                };
                relabel_configs = [
                  # Relabel __journal_syslog_identifier to systemd_unit for better filtering
                  {
                    source_labels = [ "__journal_syslog_identifier" ];
                    target_label = "systemd_unit";
                  }
                  # Relabel __journal_priority to log_level for common filtering
                  {
                    source_labels = [ "__journal_priority" ];
                    target_label = "log_level";
                    regex = "([0-7])"; # Priorities 0-7, mapping to emergency to debug
                    action = "replace";
                    # You could map these to human-readable names if you prefer
                  }
                ];
              }
              # You can add other file-based log scraping if needed, e.g., for Nginx access logs
              # {
              #   job_name = "nginx";
              #   static_configs = [
              #     {
              #       targets = [ "localhost" ];
              #       labels = { job = "nginx_access"; __path__ = "/var/log/nginx/access.log"; };
              #     }
              #   ];
              # }
            ];
          }
        ];
      };
      # If you also want to use Grafana Agent for metrics (can be an alternative to Node Exporter)
      # metrics = {
      #   configs = [
      #     {
      #       name = "agent";
      #       scrape_configs = [
      #         {
      #           job_name = "agent";
      #           static_configs = [{ targets = [ "127.0.0.1:${toString config.services.grafana-agent.listenPort}" ]; }];
      #         }
      #       ];
      #     }
      #   ];
      #   wal_directory = "/var/lib/grafana-agent/wal";
      # };
    };
  };

  # 5. Grafana (Visualization and Dashboarding)
  services.grafana = {
    enable = true;
    port = 3000; # Default Grafana UI port
    # Set admin credentials (change these!)
    adminUser = "admin";
    adminPasswordFile = pkgs.writeText "grafana-admin-password" "your-secure-grafana-admin-password"; # CHANGE THIS!
    # Optional: Automatically provision data sources and dashboards
    settings = {
      server.http_port = config.services.grafana.port; # Link to the defined port
      users.allow_sign_up = false; # Generally recommended to disable public signup
    };

    # Provisioning data sources for Prometheus and Loki
    provision.datasources.datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        access = "proxy";
        url = "http://localhost:${toString config.services.prometheus.server.port}";
        isDefault = true; # Make Prometheus the default data source
      }
      {
        name = "Loki";
        type = "loki";
        access = "proxy";
        url = "http://localhost:${toString config.services.loki.port}";
      }
    ];

    # Optional: Provision dashboards from a file or directory
    # provision.dashboards.dashboards = [
    #   {
    #     name = "nixos-node-exporter";
    #     path = ./dashboards/node-exporter-full.json; # Assuming you place a dashboard JSON here
    #     type = "file";
    #     options = {
    #       folder = "NixOS Monitoring";
    #     };
    #   }
    # ];
  };

  # Firewall rules for the exposed services
  networking.firewall.allowedTCPPorts = [
    config.services.prometheus.exporters.node.port # 9100 (Node Exporter)
    config.services.prometheus.server.port         # 9090 (Prometheus)
    config.services.loki.port                      # 3100 (Loki)
    config.services.grafana.port                   # 3000 (Grafana)
    # Grafana agent also has a port for internal metrics/debug (default 12345 for HTTP_LISTEN_PORT)
    # but it's typically not exposed to the outside.
  ];

  # Set timezone for consistent logging/metrics timestamps
  time.timeZone = "Europe/Stockholm";

  # Ensure systemd journal is persisted (often default on NixOS, but good to ensure)
  services.journald.extraConfig = "Storage=persistent";
}