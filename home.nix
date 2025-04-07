{ pkgs, ... }:
let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
  proton-installer = pkgs.writeShellScriptBin "install-proton" ''
    set -euo pipefail
    echo "setting up temp working directory..."
    mkdir /tmp/proton-ge-custom
    cd /tmp/proton-ge-custom
    echo "fetching proton-ge tarball..."
    curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .tar.gz)"
    echo "fetching proton-ge sha512sum..."
    curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | grep browser_download_url | cut -d\" -f4 | grep .sha512sum)"
    echo "checking tarball with checksum..."
    sha512sum -c ./*.sha512sum
    mkdir -p ~/.steam/root/compatibilitytools.d
    echo "extracting proton-ge tarball to steam directory..."
    tar -xf GE-Proton*.tar.gz -C ~/.steam/root/compatibilitytools.d/
    echo "Done."
  '';
in
{
  home.username = "eureka";
  home.homeDirectory = "/home/eureka";

  home.packages = with pkgs; [
    zoom-us
    nvtop
    nvidia-offload
    proton-installer
    zsh
    oh-my-zsh
    fastfetch
    pfetch
    git
    helix
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        bbenoist.nix # nix syntax highlighting
        rust-lang.rust-analyzer
        vadimcn.vscode-lldb # lldb for rust
        pkief.material-product-icons
        tamasfe.even-better-toml
        esbenp.prettier-vscode
        ms-vsliveshare.vsliveshare
        vscodevim.vim
        piousdeer.adwaita-theme
        dracula-theme.theme-dracula
        zhuangtongfa.material-theme
        file-icons.file-icons
        eamodio.gitlens # git lens
      ];
    })
    nil
    reaper
    obsidian
    ffmpeg
    gphoto2
    jetbrains-mono
    libreoffice
    zoom-us
  ];

  programs.kitty = {
    enable = true;
    settings = {
      # The window padding (in pts) (blank area between the text and the window border).
      # A single value sets all four sides. Two values set the vertical and horizontal sides.
      # Three values set top, horizontal and bottom. Four values set top, right, bottom and left.
      window_padding_width = "8 0 8 8"; # extra padding for oh-my-zsh dst theme
      hide_window_decorations = true;
    };
  };
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "ferra";
      editor = {
        cursor-shape = {
          insert = "underline";
          normal = "block";
          select = "block";
        };
        statusline = {
          mode = {
            insert = "INSERT";
            normal = "NORMAL";
            select = "SELECT";
          };
        };
        indent-guides = {
          render = true;
          character = "|";
          skip-levels = 1;
        };
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };
      };
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
  };

   # zsh & oh-my-zsh configurations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
  };
  programs.zsh.oh-my-zsh = {
    enable = true;
    plugins = [ "git" ];
    theme = "dst";
  };

  programs.git = {
    enable = true;
    userName = "eureka-cpu";
    userEmail = "github.eureka@gmail.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  nix.package = pkgs.nixVersions.latest;
  home.stateVersion = "23.11";
}
