# modules/services/monitoring-stack.nix

{ config, pkgs, lib, ... }:

let
  lokiPort = 3100;
  grafanaPort = 3000;
  prometheusPort = 9090;
  nodeExporterPort = 9100;

  grafanaDatasourcesConfig = pkgs.writeText "grafana-datasources.yaml" ''
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        access: proxy
        url: http://localhost:${toString prometheusPort}
        isDefault: true
      - name: Loki
        type: loki
        access: proxy
        url: http://localhost:${toString lokiPort}
  '';

  grafanaDatasourcesDir = pkgs.runCommand "grafana-datasources-dir" {} ''
    mkdir -p $out
    cp ${grafanaDatasourcesConfig} $out/datasources.yaml
  '';

  alloyConfig = pkgs.writeText "config.alloy" ''
    logging {
      level = "info"
      format = "logfmt"
    }

    loki.source.journal "journal" {
      path = "/run/log/journal"
      max_age = "12h"
      forward_to = [loki.write.http.default.receiver]
    }

    loki.relabel "journal_relabel" {
      forward_to = [loki.write.http.default.receiver]
      rules = [
        {
          source_labels = ["__journal_syslog_identifier"], // <-- KOMMA HÄR
          target_label = "systemd_unit", // <-- KOMMA HÄR
        }, // Komma efter avslutande klammer för första regeln
        {
          source_labels = ["__journal_priority"], // <-- KOMMA HÄR
          target_label = "log_level", // <-- KOMMA HÄR
          regex = "([0-7])", // <-- KOMMA HÄR
        } // Inget komma efter sista regeln i listan
      ]
    }

    loki.write.http "default" {
      client {
        url = "http://localhost:${toString lokiPort}/loki/api/v1/push"
      }
    }
  '';

  alloyConfigDir = pkgs.runCommand "alloy-config-dir" {} ''
    mkdir -p $out
    cp ${alloyConfig} $out/config.alloy
  '';

  grafanaAdminPasswordFile = "/etc/grafana/admin-password";

in {
  # Create the password file in /etc/grafana
  environment.etc."grafana/admin-password" = {
    text = "your-actual-secure-password-here"; # ÄNDRA DETTA
    mode = "0600";
  };

  # Prometheus Server & Node Exporter
  services.prometheus = {
    enable = true;
    exporters.node = {
      enable = true;
      port = nodeExporterPort;
    };
    scrapeConfigs = [
      {
        job_name = "node";
        scrape_interval = "30s";
        static_configs = [
          {
            targets = [ "localhost:${toString nodeExporterPort}" ];
            labels = { instance = config.networking.hostName; };
          }
        ];
      }
    ];
    extraFlags = [ "--web.listen-address=0.0.0.0:${toString prometheusPort}" ];
    stateDir = "prometheus2/data";
  };

  # Loki
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server = {
        http_listen_port = lokiPort;
        http_listen_address = "0.0.0.0";
      };
      common = {
        path_prefix = "/var/lib/loki";
        storage = {
          filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
        replication_factor = 1;
        ring = {
          instance_addr = "127.0.0.1";
          kvstore = {
            store = "inmemory";
          };
        };
      };
      schema_config.configs = [
        {
          from = "2020-10-24";
          store = "boltdb-shipper";
          object_store = "filesystem";
          schema = "v11";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];
      limits_config = {
        ingestion_rate_mb = 4;
        ingestion_burst_size_mb = 8;
        allow_structured_metadata = false;
      };
    };
    dataDir = "/var/lib/loki";
  };

  # Grafana Alloy
  services.alloy = {
    enable = true;
    configPath = alloyConfigDir;
    extraFlags = [ "--storage.path=/var/lib/alloy" ];
  };

  # Ensure Alloy has journal access and correct permissions
  systemd.services.alloy.serviceConfig = {
    SupplementaryGroups = [ "systemd-journal" ];
    StateDirectory = "alloy";
    User = "alloy";
    Group = "alloy";
  };

  # Ensure Prometheus has correct permissions
  systemd.services.prometheus.serviceConfig = {
    StateDirectory = "prometheus2/data";
    User = "prometheus";
    Group = "prometheus";
  };

  # Grafana
  services.grafana = {
    enable = true;
    settings = {
      server.http_port = grafanaPort;
      users.allow_sign_up = false;
      environment = {
        GF_SECURITY_ADMIN_USER = "admin";
        GF_SECURITY_ADMIN_PASSWORD_FILE = grafanaAdminPasswordFile;
      };
    };
    provision.datasources.settings = {
      apiVersion = 1;
      datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          access = "proxy";
          url = "http://localhost:${toString prometheusPort}";
          isDefault = true;
        }
        {
          name = "Loki";
          type = "loki";
          access = "proxy";
          url = "http://localhost:${toString lokiPort}";
        }
      ];
    };
  };

  # Firewall
  networking.firewall.allowedTCPPorts = [
    nodeExporterPort
    prometheusPort
    lokiPort
    grafanaPort
  ];

  # System settings
  time.timeZone = "Europe/Stockholm";
  services.journald.extraConfig = "Storage=persistent";
}
