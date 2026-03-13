# `yoyo-games-runner-nix`

A utility which allows packaging GMS/YoYo Games Linux Runner for Nix/NixOS,
thus making the process of packaging GameMaker games easier.

Only `x86_64-linux` & `aarch64-linux` systems are supported for now.

## Source governance & Security notice

The GMS runner is proprietary. For the sake of user experience, the
derivations produced by `mkYoYoGamesRunner` do not get marked as unfree by default.

Additionally, GMS depends on OpenSSL 1.0. Support for OpenSSL 1.0 has ended in 2019.
However, it does not look like GMS is actually using OpenSSL. Because of this
and for the sake of user experience, the package is not marked as insecure either.

## Usage

Import the flake in your `flake.nix`, then use the `mkYoYoGamesRunner` function:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    yoyo-games-runner.url = "github:MichailiK/yoyo-games-runner-nix";
  };
  outputs = {
    nixpkgs,
    yoyo-games-runner,
    ...
  }:
  {
    packages.x86_64-linux.deltarune = yoyo-games-runner.mkYoYoGamesRunner {
      # Required arguments
      system = "x86_64-linux";
      src = ./path/to/yoyo-games-runner-binary;
      # Optional arguments
      name = "deltarune";
      version = "1.03c";
      # You may provide a directory of the game assets to copy into the derivation.
      # Consider using `pkgs.requireFile` to require users to provide the assets themselves.
      gameAssets = ./path/to/game/files;
      # For games that make use of videos
      includeFFmpeg = true;
    };
  };
}
```

Then you should be able to launch your GameMaker game:
```sh
$ nix run .#deltarune
```

## Q&A

### Why is there no package, only a `mkYoYoGamesRunner` function?

Each GameMaker IDE revision seems to produce a (slightly) different runner binary.
Instead of trying to track down each build that exists of the YoYo Games Runner,
I believe it is more useful to allow you to input an arbitrary binary, that then
gets patched to allow running in Nix/NixOS systems.

### Why am I building OpenSSL 1.0.2u?

The YoYo Games Runner depends on OpenSSL 1.0, which has been end-of-life
since 2019 & is thus considered insecure.

Insecure packages are not built for `cache.nixos.org`,
and thus must instead be built locally.

### Why am I building curl?

The YoYo Games Runner depends on
[Debian-specific symbol versioning of `libcurl3-gnutls`](https://bugs.debian.org/1020780).
The patch can be found at <https://sources.debian.org/patches/curl/> as
`ZZZgnutls build.patch`. This patch requires curl to be rebuilt locally.


## Other notes

This is a sister project of [deltarune-nix], a Nix flake for running the RPG
GameMaker game DELTARUNE on Nix/NixOS systems, including TAS tools.

[deltarune-nix]: https://github.com/MichailiK/deltarune-nix
