{ custom, pkgs }:

let
  colors = {
    background = "#282A2E";
    background-alt = "#373B41";
    foreground = "#C5C8C6";
    primary = "#F0C674";
    secondary = "#8ABEB7";
    alert = "#A54242";
    disabled = "#707880";
    urgent = "#ff4500";
    transparent = "#00000000";
  };

  mkEthModule = interface: {
    type = "internal/network";
    interface = "${interface}";
    interface-type = "wired";
    label-connected = "⬆ %upspeed% ⬇ %downspeed%";
  };

in {
  "global/wm" = {
    margin-bottom = 0;
    margin-top = 0;
  };

  "module/xkeyboard" = {
    type = "internal/xkeyboard";
    blacklist-0 = "num lock";
    label-layout = "%layout%";
    label-layout-foreground = "${colors.primary}";
    label-indicator-padding = 2;
    label-indicator-margin = 1;
    label-indicator-foreground = "${colors.background}";
    label-indicator-background = "${colors.secondary}";
  };

  "bar/bottom" = {
    bottom = true;
    modules-left = "filesystem cpu memory";
    modules-center = "date";
    modules-right = "xkeyboard audio "
      + (if (pkgs.lib.my.hasSubAttr "polybar.ethernet" custom) then
        (builtins.concatStringsSep " "
          (pkgs.lib.imap0 (index: _: "eth${toString index}")
            custom.polybar.ethernet))
      else
        "") + " wlan1 battery";
    monitor = "\${env:MONITOR:}";
    background = "${colors.background}";
    foreground = "${colors.foreground}";
    fixed-center = true;
    font-0 = "JetBrainsMono Nerd Font:size=15;4";
    height = "30";
    locale = "en_US.UTF-8";
    offset-x = "0%";
    padding = "0";
    radius-top = "0";
    width = "100%";
    # display "above" window manager
    wm-restack = "generic";
    override-redirect = true;
    tray-position = "left";
  };

  "module/date" = {
    format = "<label>";
    format-foreground = "${colors.foreground}";
    format-background = "${colors.background}";
    format-padding = 2;
    format-margin = 0;
    interval = 1;
    label = "%date% %time%";
    time = "%H:%M:%S";
    date = "%d %b %Y";
    type = "internal/date";
  };

  "module/filesystem" = {
    type = "internal/fs";
    format = "<label>";
    format-background = "${colors.background}";
    format-foreground = "${colors.foreground}";
    format-padding = 2;
    format-margin = 0;
    mount-0 = "/";
    label-mounted = "%mountpoint% %percentage_used%%";
  };

  "module/cpu" = {
    format = "<label>";
    format-background = "${colors.background}";
    format-foreground = "${colors.foreground}";
    format-padding = 2;
    interval = "0.5";
    label = "CPU %percentage%%";
    type = "internal/cpu";
  };
} // (if (pkgs.lib.my.hasSubAttr "polybar.battery" custom) then {
  "module/battery" = {
    type = "internal/battery";
    adapter = "AC0";
    animation-charging-0 = "";
    animation-charging-1 = "";
    animation-charging-2 = "";
    animation-charging-3 = "";
    animation-charging-4 = "";
    animation-charging-framerate = 500;
    battery = custom.polybar.battery;
    format-charging = "󱐥 <animation-charging> <label-charging>";
    format-charging-padding = 1;
    format-discharging = "<ramp-capacity> <label-discharging>";
    format-discharging-padding = 1;
    format-full-padding = 1;
    full-at = 100;
    label-charging = "%percentage%% +%consumption%W";
    label-discharging = "%percentage%% -%consumption%W";
    label-full = " ";
    poll-interval = 2;
    ramp-capacity-0 = "";
    ramp-capacity-1 = "";
    ramp-capacity-2 = "";
    ramp-capacity-3 = "";
    ramp-capacity-4 = "";
  };
} else
  { }) // {
    "module/audio" = {
      format-muted = "<label-muted>";
      format-muted-background = "${colors.background}";
      format-muted-foreground = "${colors.urgent}";
      format-muted-overline = "${colors.transparent}";
      format-muted-padding = 2;
      format-muted-margin = 0;
      format-muted-prefix = "婢  ";
      format-muted-prefix-foreground = "${colors.urgent}";
      format-volume = "墳  VOL <label-volume>";
      format-volume-background = "${colors.background}";
      format-volume-foreground = "${colors.foreground}";
      format-volume-padding = 2;
      format-volume-margin = 0;
      label-muted = "MUTED";
      label-volume = "%percentage%%";
      type = "internal/pulseaudio";
    };

    "module/xworkspaces" = {
      type = "internal/xworkspaces";
      enable-scroll = false;
      pin-workspaces = true;
      format = "<label-state>";
      label-monitor = "";
      label-active = "%name%";
      label-active-background = "${colors.background}";
      label-active-foreground = "${colors.foreground}";
      label-active-padding = 1;
      label-active-margin = 0;
      label-active-font = 3;
      label-occupied = "%name%";
      label-occupied-background = "${colors.background}";
      label-occupied-foreground = "#707070";
      label-occupied-padding = 1;
      label-occupied-margin = 0;
      label-empty = "";
      label-empty-padding = 0;
      label-empty-margin = 0;
      label-urgent = "%name%";
      label-urgent-background = "${colors.background}";
      label-urgent-foreground = "${colors.urgent}";
      label-urgent-padding = 1;
      label-urgent-margin = 0;
    };

    "settings" = {
      compositing-background = "source";
      compositing-border = "over";
      compositing-foreground = "over";
      compositing-overline = "over";
      comppositing-underline = "over";
      pseudo-transparency = false;
      screenchange-reload = true;
      throttle-output = "5";
      throttle-output-for = "10";
    };

    "module/powermenu" = {
      type = "custom/menu";
      expand-left = true;
      format = "<label-toggle> <menu>";
      format-background = "${colors.background}";
      format-foreground = "${colors.foreground}";
      format-padding = 1;
      label-close = " ";
      label-close-padding-right = 0;
      label-close-padding-left = 1;
      label-open = " ";
      label-open-padding = 1;
      label-separator = "|";
      label-separator-padding = 1;
      menu-0-0 = "  Suspend";
      menu-0-0-exec = "systemctl suspend";
      menu-0-1 = "  Reboot";
      menu-0-1-exec = "v";
      menu-0-2 = "  Shutdown";
      menu-0-2-exec = "systemctl poweroff";
    };

    "module/wlan1" = {
      interface = custom.polybar.wifi;
      type = "internal/network";
      accumulate-stats = "true";
      format-connected = "<label-connected>";
      format-connected-background = "${colors.background}";
      format-connected-foreground = "${colors.foreground}";
      format-connected-margin = 0;
      format-connected-overline = "${colors.transparent}";
      format-connected-padding = 2;
      format-connected-underline = "${colors.transparent}";
      format-disconnected = "<label-disconnected>";
      format-disconnected-background = "${colors.background}";
      format-disconnected-foreground = "#909090";
      format-disconnected-margin = 0;
      format-disconnected-overline = "${colors.transparent}";
      format-disconnected-padding = 2;
      format-disconnected-underline = "${colors.transparent}";
      interval = "1.0";
      label-connected = "%essid% %signal%%";
      label-disconnected = "DISCONNECTED";
      unknown-as-up = true;
    };

    "module/memory" = {
      format = "<label>";
      format-background = "${colors.background}";
      format-foreground = "${colors.foreground}";
      format-padding = 2;
      format-margin = 0;
      interval = 3;
      label = "RAM %percentage_used%%";
      type = "internal/memory";
    };

    "module/distro-icon" = {
      exec =
        "${pkgs.coreutils}/bin/uname -r | ${pkgs.coreutils}/bin/cut -d- -f1";
      format = "   <label>";
      format-background = "${colors.background}";
      format-foreground = "${colors.foreground}";
      format-padding = 2;
      interval = "999999999";
      label = "%output%";
      type = "custom/script";
    };

    "module/xmonad" = {
      type = "custom/script";
      exec = "${pkgs.xmonad-log}/bin/xmonad-log";
      tail = true;
    };
  } // (if (pkgs.lib.my.hasSubAttr "polybar.ethernet" custom) then
    (pkgs.lib.my.mergeMapAttr
      (ii: { "module/eth${toString ii.index}" = mkEthModule ii.interface; })
      (pkgs.lib.imap0 (index: interface: {
        index = index;
        interface = interface;
      }) custom.polybar.ethernet))
  else
    { })
