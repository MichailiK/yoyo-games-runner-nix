{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # current nixpkgs does not package OpenSSL 1.0.x
    nixpkgs-openssl.url = "github:NixOS/nixpkgs/d1c3fea7ecbed758168787fe4e4a3157e52bc808";
  };
  outputs = {
    nixpkgs,
    nixpkgs-openssl,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = callback:
      nixpkgs.lib.genAttrs supportedSystems (
        system: callback nixpkgs.legacyPackages.${system}
      );

    openssl1_0' = pkgs: (nixpkgs-openssl.legacyPackages.${pkgs.stdenv.hostPlatform.system}.openssl_1_0_2).overrideAttrs (prev: {
      meta.knownVulnerabilities = [];
    });
    curl-gnutls-debian' = pkgs: pkgs.callPackage ./curl-gnutls-debian.nix {};
    yoyo-games-runner' = pkgs: args:
      pkgs.callPackage ./yoyo-games-runner.nix (args
        // {
          curl-gnutls-debian = curl-gnutls-debian' pkgs;
          openssl1_0 = openssl1_0' pkgs;
        });
  in {
    # Packages the provided YoYo Games Runner Binary to allow execution on Nix/NixOS
    mkYoYoGamesRunner = {
      system,
      src,
      ...
    } @ args:
      assert nixpkgs.lib.assertMsg (builtins.any (v: v == system) supportedSystems) ''
        mkYoYoGamesRunner does not support system ${system}.
        Only ${builtins.concatStringsSep ", " supportedSystems} are supported.
      '';
        yoyo-games-runner' nixpkgs.legacyPackages.${system} args;

    supportedSystems = supportedSystems;

    packages = forAllSystems (pkgs: {
      curl-gnutls-debian = curl-gnutls-debian' pkgs;
      openssl1_0 = openssl1_0' pkgs;
    });
  };
}
