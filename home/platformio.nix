{ pkgs, ... }:
{
  home.packages = with pkgs; [
    platformio-core
  ];
}
