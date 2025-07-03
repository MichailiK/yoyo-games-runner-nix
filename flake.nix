{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
    # current nixpkgs does not package OpenSSL 1.0.x
    nixpkgs-openssl.url = "github:NixOS/nixpkgs?ref=d1c3fea7ecbed758168787fe4e4a3157e52bc808";
  };
  outputs =
    {
      nixpkgs,
      nixpkgs-openssl,
      ...
    }:
    let
      # only 64-bit Linux systems are supported for now
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};

      pkgs-openssl = nixpkgs-openssl.legacyPackages.${system};
      openssl_1_0 = pkgs-openssl.openssl_1_0_2;
    in
    {
      # Packages the provided YoYo Games Runner Binary to allow execution on NixOS
      mkYoYoGamesRunner =
        {
          src,
          ...
        }@inputs:
        pkgs.callPackage ./yoyo-games-runner.nix (inputs // { inherit src openssl_1_0 pkgs; });
    };
}
