{ inputs, system, config, lib, pkgs, ... }:
let
  cfg = config.modules.vscode;

  languageSnippets = {
    haskell = {
      newtype = {
        prefix = [ "newtype" ];
        body = [ "newtype \${1:Foo} = $1 { \${2:un$1} :: $0}" ];
        description = "Insert a newtype definition";
      };
      record = {
        prefix = [ "record" ];
        body = [
          "data \${1:Foo} = $1 {"
          "	\${1/(.)(.*)/\${1:/downcase}\${2:/camelcase}/}$2 :: $3,"
          "	\${1/(.)(.*)/\${1:/downcase}\${2:/camelcase}/}$4 :: $0"
          "	}"
        ];
        description = "Insert a data record defintion";
      };
      sumtype = {
        prefix = [ "sumtype" ];
        body = [ "data \${1:Foo}" "	= \${2:Bar}" "	| \${0:Baz}" ];
        description = "Insert a data record defintion";
      };
      impl = {
        prefix = [ "impl" ];
        body = [ ''(error "implement ''${0:this}")'' ];
        description = "Insert an implementation as error";
      };
      def = {
        prefix = [ "def" ];
        body = [ "$1 :: $2" ''$1 = ''${0:error "implement $1"}'' ];
        description = "Generate a definition";
      };
    };
  };

  globalSnippets = {
    fixme = {
      prefix = [ "fixme" ];
      body = [ "$LINE_COMMENT FIXME (felix): $0" ];
      description = "Insert a FIXME remark";
    };
    todo = {
      prefix = [ "todo" ];
      body = [ "$LINE_COMMENT TODO (felix): $0" ];
      description = "Insert a TODO remark";
    };
  };

  userSettings = {
    # editor settings
    "editor.minimap.enabled" = false;
    "editor.tabSize" = 2;
    "editor.formatOnSave" = true;
    # telemetry settings
    "telemetry.enableTelemetry" = false;
    "telemetry.enableCrashReporter" = false;
    # miscellaneous settings
    "workbench.colorThem" = "Default Dark+";
    "window.zoomLevel" = 1;
    # git settings
    "git.confirmSync" = false;
    "git.autofetch" = true;

    # default haskell settings
    "haskell.formattingProvider" = "ormolu";
  };

  haskellmode = let
    haskellmodeInput = inputs.haskellmode.packages.${system};
    haskellmode-version = haskellmodeInput.haskellmode-version;

    extensionFilename = "haskellmode-${haskellmode-version}";

    vsixToZip = input: filename:
      pkgs.stdenv.mkDerivation {
        name = "vsix-to-zip";
        src = input;
        buildPhase = pkgs.writeScript "vsix-to-zip" ''
          mkdir result
          mv ${filename}.vsix result/${filename}.zip
          mv result $out
        '';
      };

  in pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      publisher = "lzszt";
      name = "haskell-mode";
      version = haskellmode-version;
    };
    vsix = "${
        vsixToZip haskellmodeInput.haskellmode extensionFilename
      }/${extensionFilename}.zip";
  };

  extensions = with pkgs.vscode-extensions;
    [
      bbenoist.nix
      brettm12345.nixfmt-vscode
      haskell.haskell
      justusadam.language-haskell
      waderyan.gitblame
      donjayamanne.githistory
      arrterian.nix-env-selector
      haskellmode
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace
    (import ./extensions.nix).extensions;

in {
  options.modules.vscode = { enable = lib.mkEnableOption "vscode"; };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;
      inherit userSettings extensions languageSnippets globalSnippets;
    };
  };

}
