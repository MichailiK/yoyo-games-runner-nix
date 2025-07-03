# https://packages.debian.org/bookworm/libcurl3-gnutls
# Debian/Ubuntu use a patched libcurl3-gnutls which implements CURL_GNUTLS3.
# See the following discussions for more info:
# - https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=1020780
# - https://github.com/curl/curl/issues/2433#issuecomment-377046239
# - https://github.com/ValveSoftware/steam-runtime/issues/535#issuecomment-1258064277
{
  pkgs,
  lib,
  stdenvNoCC,
  autoPatchelfHook,
  callPackage,
  ...
}: stdenvNoCC.mkDerivation rec {
  pname = "libcurl3-gnutls";
  version = "7.88.1-10+deb12u12";

  src = builtins.fetchurl {
    # TODO: obtain a more permanent URL of this
    url = "http://http.us.debian.org/debian/pool/main/c/curl/libcurl3-gnutls_${version}_amd64.deb";
    sha256 = "sha256:04ccackkajgyck785h2mzh51zvsjcdwkm48m7hlx76nlnn3z5y0f";
  };

  unpackPhase = ''
    runHook beforeUnpack
    ${lib.getExe' pkgs.dpkg "dpkg-deb"} -x "$src" unpack
    runHook afterUnpack
  '';

  installPhase = ''
    runHook beforeInstall
  
    mkdir -p "$out"/lib
    install -m755 -D unpack/usr/lib/x86_64-linux-gnu/* "$out"/lib

    runHook afterInstall
  '';

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    pkgs.glibc
    pkgs.nghttp2.lib
    pkgs.libidn2
    pkgs.rtmpdump_gnutls
    pkgs.libssh2
    pkgs.libpsl
    pkgs.nettle
    pkgs.gnutls
    pkgs.krb5.lib
    (callPackage ./libldap-2.5-0.nix {}) # for libldap & libdler
    pkgs.zstd
    pkgs.brotli.lib
    pkgs.libz
  ];
}
