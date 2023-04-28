
{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  mvn2nix = import (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz") {};
  inherit (pkgs) lib stdenv maven makeWrapper;
  inherit (stdenv) mkDerivation;
  JDK = graalvm17-ce;
in
mkDerivation rec {
  pname = "gurupoo";
  version = "0.0.1-SNAPSHOT";
  name = "${pname}-${version}";
  src = lib.cleanSource ./.;
  buildInputs = [ maven ];
  dontFixup = true;
  nativeBuildInputs = [  JDK makeWrapper ];
  buildPhase = ''
    mvn -Dmaven.repo.local=$out install spring-boot:repackage
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp target/${name}.jar $out/
    makeWrapper ${JDK}/bin/java $out/bin/${pname} \
    --add-flags "-jar $out/${name}.jar"
  '';
}
