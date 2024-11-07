{
  inputs,
  system,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.modules.vscode;

  userSettings = import ./user-settings.nix;

  snippets = import ./snippets.nix;

  rebind = binding: [
    {
      key = binding.oldKey;
      command = "-" + binding.command;
      when = binding.when or "";
    }
    {
      key = binding.newKey;
      command = binding.command;
      when = binding.when or "";
    }
  ];

  extensions = import ./extensions.nix {
    inherit
      inputs
      system
      pkgs
      lib
      config
      rebind
      ;
  };
  defaultKeybindings = import ./keybindings.nix { inherit lib rebind; };

  allKeybindings = lib.flatten (defaultKeybindings ++ extensions.keybindings);

  allUserSettings = userSettings // extensions.userSettings;
in
{
  options.modules.vscode = {
    enable = lib.mkEnableOption "vscode";
    extensions = {
      custom = lib.mkOption { default = [ ]; };
    } // extensions.enableOptions;
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      mutableExtensionsDir = false;
      keybindings = allKeybindings;
      inherit (snippets) languageSnippets globalSnippets;
      userSettings = allUserSettings;
      extensions = extensions.installedExtensions;
    };
  };
}
