{
  config,
  lib,
  stylix,
  ...
}:
{
  stylix.targets.waybar.colors.enable = true;
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    systemd.enable = true;
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 35;
        spacing = "4";

        modules-center = [
          "clock"
          "niri/window"
        ];
        modules-right = [
          "battery"
          "bluetooth"
          "network"
          "pulseaudio"
        ];
        modules-left = [ "niri/workspaces" ];

        bluetooth = {
          format = " {status}";
          format-disbaled = "";
          format-connected = " {num_connections} connected";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
          on-click = "vicinae vicinae://extensions/Gelei/bluetooth/devices";
        };

        "niri/window" = {
          "max-length" = 30;
        };
        clock = {
          format = "{:%I:%M%p %D}";
          tooltip = false;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% 󰂄";
          format-plugged = "{capacity}% 󱟢";
          format-alt = "{time} {icon}";
          # format-icons = [ "" "" "" "" "" ];
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        network = {
          format-wifi = "{essid} ({signalStrength}%)  ";
          format-ethernet = "{ipaddr}/{cidr} 󰈀";
          tooltip-format = "{ifname} via {gwaddr} 󰈀";
          format-linked = "{ifname} (No IP) 󰈀";
          format-disconnected = "Disconnected ⚠";
          format-alt = "{ifname}: {ipaddr}/{cidr}";
        };
        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source} ";
          format-source = " {volume}%  ";
          format-source-muted = "  ";
          format-icons = {
            headphone = "";
            hands-free = "󰋎";
            headset = "󰋎";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
        };
        # "custom/spacer" = {
        #   format = " "; # Insert a blank space
        #   interval = "once"; # Only render once
        #   tooltip = false; # Disable tooltip
        # };
      };
    };
    style = ''
      * {  border: none;
           font-family: "JetBrains Mono", monospace;
           font-size: 12px;
           margin: 0em 0em;
                }
      #window {
        background: @base01;
        color: @base0D;
        border-radius: .25em;
        margin: .5em .25em;
        
      }
      window#waybar {
        background: @base00;
        color: @base0D; /*maybe base0C this is text color */
        border: none;
        margin: 0em 0em;
      }
      #clock {
        padding: .25em .25em;
        margin: .5em .25em;
        border-radius: .25em;
        background: @base01;
      }
      #bluetooth {
        margin: .5em .25em;
        background: @base01;
        border-radius: .25em;
             }
      #battery {
        margin: .5em .25em;
        border-radius: .25em;
        padding: 0px 3px;
        color: @base0C;
        background: @base01;
      }
      #battery.discharging.warning:not(.charging) {
        color: @base05;
        }
      #battery.discharging.critical:not(.charging) {
        color: @base08;
      } 
      #workspaces button.active {
        color: @base0C;
        background: @base01;
      }        
      #workspaces button {
        border-radius: .25em;
        border: @base01; 
        padding: .25em 0em;
        margin: .5em .25em;
        color: @base04;
        background: @base01;
      }
      #pulseaudio {
        background: @base01;
        border-radius: .25em;
        margin: .5em .25em;
      }
      #network {
         background: @base01;
         border-radius: .25em;
         margin: .5em .25em;
      }

    '';

  };
}
