
alias checkvenv='[ -n "$VIRTUAL_ENV" ] && echo "In venv: $VIRTUAL_ENV" || echo "Not in venv"'
venv_prompt() {
  if [ -n "$VIRTUAL_ENV" ]; then
    echo "($(basename "$VIRTUAL_ENV")) "
  fi
}

alias ll='ls -lah'
alias lR='ls -laR'
alias lRl='ls -laR | less'
alias comfyui='nix develop ~/comfyui/nix'
alias bng='cd $BEAMNG'
export BEAMNG="/home/owdious/.local/share/Steam/steamapps/compatdata/284160/pfx/drive_c/users/steamuser/AppData/Local/BeamNG.drive/0.36/mods"

#export PS1='$(venv_prompt)\u@\h:\w\$ '

export PATH="$HOME/.local/bin:$PATH"
function ssha() {
    pidof ssh-agent || eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/github/github_ed25519
}
function git-push-nixos() {
    ssha
    local config_dir="$HOME/nixos-config"
    git -C "$config_dir" checkout auto
    git -C "$config_dir" add .
    git -C "$config_dir" commit -m "$(date)" || true
    git -C "$config_dir" push
}
function git-push-dot() {
    ssha
    local config_dir="$HOME/dotfiles"
    git -C "$config_dir" checkout auto
    git -C "$config_dir" add .
    git -C "$config_dir" commit -m "$(date)" || true
    git -C "$config_dir" push
}
function git-push-comfyui() {
    local config_dir="$HOME/comfyui"
    git -C "$config_dir" checkout auto
    git -C "$config_dir" add .
    git -C "$config_dir" commit -m "$(date)" || true
    git -C "$config_dir" push
}
function update-flake() {
    sudo nix flake update --flake ~/nixos-config -v
}
function build-nix() {
    declare -f build-nix
    sudo nixos-rebuild switch --flake ~/nixos-config -v
}
function build-nix-dry() {
    sudo nixos-rebuild dry-activate --flake ~/nixos-config -v
}
function build-nix-push() {
    ssha
    build-nix
    git-push-nixos
}
function reload-conf() {
    echo "Bash configuration reloaded."
    hyprctl reload
    echo "Hyprland configuration reloaded."
}
