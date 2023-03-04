{ config, lib, pkgs, ... }:

let cfg = config.modules.bash;
in {
  options.modules.bash = {
    enable = lib.mkEnableOption "bash";
    customAliases = lib.mkOption { default = { }; };
  };

  config = lib.mkIf cfg.enable {
    programs.bash = {
      enable = true;

      initExtra = ''
        PS1=$'\[\033[01;32m\]\u \[\033[00m\]\[\033[01;36m\]\w \[\033[00m\]$(${
          ./nix.bash
        })\[\033[01;36m\]\U276F\[\033[00m\] '
      '';

      historyIgnore = [ "ls" "cd" "exit" ];

      shellAliases = (import ./shell-aliases.nix { inherit pkgs; })
        // cfg.customAliases;
    };
  };
}
