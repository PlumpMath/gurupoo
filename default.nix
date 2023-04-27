
{ pkgs ? import <nixpkgs> {} }:

let
  mvn2nix = import (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz") {};
  mavenRepository = mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
  inherit (pkgs) lib stdenv maven makeWrapper jdk11_headless;
  inherit (stdenv) mkDerivation;
in
mkDerivation rec {
  pname = "gurupoo";
  version = "0.0.1-SNAPSHOT";
  name = "${pname}-${version}";
  src = lib.cleanSource ./.;
  nativeBuildInputs = [ jdk11_headless maven makeWrapper ];
  buildPhase = ''
    mvn package spring-boot:repackage -X --offline -Dmaven.repo.local=${mavenRepository}
  '';
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${mavenRepository} $out/lib
    cp target/${name}.jar $out/
    makeWrapper ${jdk11_headless}/bin/java $out/bin/${pname} \
    --add-flags "-jar $out/${name}.jar"
  '';
}
