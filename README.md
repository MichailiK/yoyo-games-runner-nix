# `yoyo-games-runner-nix`

A utility which allows packaging YoYo Games Linux Runner for Nix/NixOS,
thus making the process of packaging GameMaker games easier.

Only `x86_64-linux` systems are supported for now.

## Usage

Import the flake in your `flake.nix`, then use the `mkYoYoGamesRunner` function:

```nix
{
  inputs = {
    yoyo-games-runner.url = "github:MichailiK/yoyo-games-runner-nix";
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-25.05";
  };
  outputs = {
    packages.x86_64-linux.deltarune =
      nixpkgs.x86_64-linux.callPackage yoyo-games-runner.mkYoYoGamesRunner {
        src = ./path/to/yoyo-games-runner-binary;
        version = "deltarune-1.03c";
        # You may optionally provide a directory of the game assets to copy into the derivation.
        gameAssets = ./path/to/game/files;
    };
  };
}
```

Then you should be able to launch your GameMaker game:
```sh
$ NIXPKGS_ALLOW_UNFREE=1 NIXPKGS_ALLOW_INSECURE=1 nix run --impure .#deltarune
```

## Q&A

### Why is there no package, only a `mkYoYoGamesRunner` function?

The binary that GameMaker games ship differ between each other, likely because
each GameMaker IDE version produces a different binary and developers
use various versions of the GameMaker IDE.
Instead of trying to track down each build that exists of the YoYo Games Runner,
I believe it is more useful to allow you to input an arbitrary binary, that then
gets fixed up to allow running in Nix/NixOS systems.

### Why is the derivation considered insecure?

The YoYo Games Runner depends on OpenSSL 1.0.0, which has been end-of-life
since 2019.

### Why is the derivation dependent on Debian packages?

The YoYo Games Runner depends on
[Debian-specific symbol versioning of `libcurl3-gnutls`](https://bugs.debian.org/1020780).
The easiest solution I've found around that is to pull Debian builds of`libcurl3-gnutls`
(alongside a few other dependencies that weren't packaged in nixpkgs.)
