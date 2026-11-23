{
  pkgs,
  inputs,
  lib,
  ...
}:
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "everforest_dark";
      editor = {
        auto-save = {
          focus-lost = true;
          after-delay = {
            enable = true;
            timeout = 500;
          };
        };
        bufferline = "always";
        color-modes = true;
        cursor-shape = {
          normal = "bar";
          insert = "bar";
          select = "bar";
        };
        cursorline = true;
        file-picker.hidden = false;
        indent-guides = {
          render = true;
          character = "┆";
        };
        inline-diagnostics = {
          cursor-line = "hint";
          other-lines = "error";
        };
        line-number = "relative";
        lsp = {
          auto-signature-help = false;
          display-inlay-hints = true;
          display-progress-messages = true;
        };
        rulers = [ 80 ];
        scrolloff = 4;
        soft-wrap.enable = true;
        true-color = true;
      };
    };
    languages = {

      language = [
        {
          name = "nix";
          auto-format = true;
        }
      ];

      language-server = {
        nil.config = {
          formatting.command = [ "nixfmt" ];
          nix.flake = {
            autoArchive = true;
            autoEvalInputs = true;
          };
        };

      };
    };
  };
}
