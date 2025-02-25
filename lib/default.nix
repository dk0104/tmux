{ ... }:

let
  hr = text:
    let
      parts = builtins.split "." text;
    in
    builtins.foldl'
      (text: part:
        if builtins.isList part then
          "${text}-"
        else
          text
      )
      ""
      (builtins.tail parts);
in
{
  # Create a tmux configuration file.
  # Type: Attrs -> Path
  # Usage: mkConfig { inherit pkgs; shell = "${pkgs.bash}/bin/bash"; plugins = [ pkgs.tmuxPlugins.nord ]; extra-config = "set -g history-limit 1000"; }
  #   result: /nix/store/<hash>-tmux.conf
  mkConfig =
    { pkgs
    , shell ? "${pkgs.zsh}/bin/zsh"
    , terminal ? "screen-256color-bce"
    , plugins ? [ ]
    , extra-config ? ""
    }:
    let
      is-package = pkgs.lib.types.package.check;
      get-plugin-name = plugin:
        if is-package plugin then
          plugin.pname
        else
          plugin.plugin.pname;

      base-config = ''
        set -g default-terminal "${terminal}"
      '';

      plugin-config = pkgs.lib.concatMapStringsSep
        "\n\n"
        (plugin: ''
          # ${get-plugin-name plugin}
          # ${hr (get-plugin-name plugin)}
          ${plugin.extraConfig or ""}
          run-shell ${if is-package plugin then plugin.rtp else plugin.plugin.rtp}
        '')
        plugins;
    in
    pkgs.writeText "tmux.conf" ''
      # This file is generated by https://github.com/dk0104/tmux

      #========================#
      #          BASE          #
      #========================#

      ${base-config}

      #========================#
      #         PLUGINS        #
      #========================#

      ${plugin-config}

      #========================#
      #      EXTRA CONFIG      #
      #========================#

      ${extra-config}
    '';
}
