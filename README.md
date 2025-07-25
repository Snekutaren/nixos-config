NixROG NixOS Configuration
This repository contains a personal NixOS configuration, managed as a Nix flake. It is designed for the nixrog machine, providing a reproducible and highly modular system with support for multiple desktop environments.

✨ Features
Reproducible System: Leveraging Nix flakes, this configuration ensures consistent system builds regardless of deployment time or location. Dependencies are pinned via flake.lock.

Multi-Desktop Environment Support: Selection between:

KDE Plasma 6: A powerful and customizable desktop environment.

Hyprland: A dynamic tiling Wayland compositor.

Deepin Desktop Environment (DDE): An elegant and user-friendly desktop.

Modular Structure: The configuration is broken down into logical modules for clarity and reusability:

hosts/: Machine-specific configurations (e.g., nixrog).

modules/common/: Universal system settings (e.g., core services, networking, basic packages).

modules/common/sound.nix: Dedicated audio configuration (PipeWire).

modules/common/localization.nix: Timezone, locale, and keyboard layout settings.

modules/common/display-manager.nix: Centralized display manager setup (SDDM).

modules/desktop/: Individual desktop environment configurations.

home/: User-specific Home Manager configurations.

Home Manager Integration: Declarative management of user-specific packages, dotfiles, and shell configurations for a consistent and reproducible user environment is provided.

Agenix Integration: Secure management of secrets (like Wi-Fi passwords, API keys) within the declarative configuration is achieved using age encryption.

NixOS 25.05: The configuration is built on the nixos-25.05 stable channel for up-to-date packages and features.

Getting Started
Deployment of this configuration to a NixOS machine involves these steps.

Prerequisites
A fresh NixOS installation (preferably minimal, without a desktop environment, to avoid conflicts).

Familiarity with the Nix command line and basic Linux operations is assumed.

NixOS installation compatibility with 25.05 is required.

1. Clone the Repository
git clone https://github.com/your-username/your-nixos-config.git ~/nixos-config
cd ~/nixos-config

2. Generate Hardware Configuration
On the nixrog machine, its specific hardware configuration is generated.

sudo nixos-generate-config --no-filesystems --root /mnt # For fresh installations
# Or if already installed:
sudo nixos-generate-config --show-only > ./hosts/rog/nixrog-hardware-configuration.nix

Important: hosts/rog/nixrog-hardware-configuration.nix identifies disks, partitions, and kernel modules.

3. Create User Configuration
The user-specific module for owdious is created.

mkdir -p home/owdious
touch home/owdious/home.nix

Initial content for home/owdious/home.nix is provided; this is expanded by Home Manager:

# home/owdious/home.nix
{ config, pkgs, ... }:

{
  # Home Manager needs to know your user's home directory
  home.homeDirectory = "/home/owdious";

  # Define user-specific packages here
  home.packages = with pkgs; [
    firefox # Example: Installation of Firefox for the user
    neovim  # Example: Installation of Neovim
  ];

  # Enable a shell (e.g., Zsh)
  programs.zsh.enable = true;
  programs.zsh.ohMyZsh.enable = true; # Example: Enabling Oh My Zsh

  # Enable Git configuration
  programs.git = {
    enable = true;
    userName = "Owdious";
    userEmail = "owdious@example.com";
  };

  # Set default editor
  home.sessionVariables.EDITOR = "nvim";

  # Restore home-manager state
  home.stateVersion = "23.11"; # Matching the home-manager release branch
}

4. Update flake.lock
Before application, the flake.lock is ensured to be up-to-date with all inputs.

nix flake update

5. Apply the Configuration
Finally, the system is switched to this new configuration.

sudo nixos-rebuild switch --flake .#nixrog

After a successful rebuild, a system reboot is performed. At the login screen (SDDM), selection between Plasma 6, Hyprland, and Deepin is available.

📂 Directory Structure
.
├── flake.nix                       # Main flake definition, inputs, and outputs
├── hosts/
│   └── rog/
│       ├── configuration.nix       # Main config for 'nixrog' host
│       ├── nixrog-hardware-configuration.nix # Hardware auto-generated for 'nixrog'
│       └── users.nix               # User definitions specific to 'nixrog'
├── modules/
│   ├── common/
│   │   ├── common.nix              # General system settings (X server, D-Bus, NetworkManager, unfree pkgs)
│   │   ├── sound.nix               # Audio configuration (PipeWire)
│   │   ├── localization.nix        # Timezone, locales, keyboard layouts
│   │   └── display-manager.nix     # SDDM configuration
│   └── desktop/
│       ├── deepin.nix              # Deepin Desktop Environment module
│       ├── hyprland.nix            # Hyprland Wayland Compositor module
│       └── plasma.nix              # KDE Plasma 6 Desktop Environment module
└── home/
    └── owdious/
        └── home.nix                # Home Manager configuration for 'owdious' user

💡 Usage Examples
Switching Desktop Environments
After rebooting, selection of the desired desktop environment (Plasma, Hyprland, or Deepin) occurs from the SDDM login screen.

Updating the Flake
Updating all defined flake inputs (e.g., Nixpkgs, Home Manager, Agenix) to their latest versions, as specified by their URLs, is performed by executing the following command:

nix flake update

Subsequently, the system is rebuilt:

sudo nixos-rebuild switch --flake .#nixrog

Entering a Development Shell
Entering a shell with the tools defined in the flake's devShell (if one is defined in flake.nix) is achieved via:

nix develop

⚠️ "Git tree is dirty" Warning
A warning: Git tree '/home/owdious/nixos-config' is dirty message may frequently appear during builds. This indicates uncommitted changes in the Git repository. While it does not prevent the build, committing changes before building is recommended for true reproducibility.

Committing changes prevents this warning:

git add .
git commit -m "My latest NixOS configuration changes"

🔒 Secrets Management with Agenix
This flake integrates agenix for secure secrets management.

Host key generation:

ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key # If one does not exist
# Or an existing SSH key can be used

Subsequently, the public key is added to the agenix configuration (e.g., in agenix.nix if created, or directly in hosts/rog/configuration.nix if simple).

Secret encryption:

echo "your_wifi_password" | age -r "ssh-ed25519 AAAA..." > secrets/wifi-password.age

Replacement of "ssh-ed25519 AAAA..." with the machine's public key is required. Encrypted secrets are stored in a secrets/ directory.

Secret reference in the configuration:

# Example in a module
networking.wireless.networks.MyWifi.pskFile = config.age.secrets.wifi-password.path;
```agenix` decrypts `secrets/wifi-password.age` during the build process.


🤝 Contributing
This repository is available for forking and adaptation to personal needs. Improvements or fixes can be 