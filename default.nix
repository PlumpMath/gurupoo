
{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  mvn2nix = import (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz") {};
  mavenRepository = mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
  repository = (buildMaven ./project-info.json).repo;
  inherit (pkgs) lib stdenv maven makeWrapper jdk17_headless;
  inherit (stdenv) mkDerivation;
in
mkDerivation rec {
  pname = "gurupoo";
  version = "0.0.1-SNAPSHOT";
  name = "${pname}-${version}";
  src = lib.cleanSource ./.;
  nativeBuildInputs = [ jdk17_headless maven makeWrapper ];
  buildPhase = ''
    mvn --offline -Dmaven.repo.local=${repository} package spring-boot:repackage;
  '';
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${mavenRepository} $out/lib
    cp target/${name}.jar $out/
    makeWrapper ${jdk17_headless}/bin/java $out/bin/${pname} \
    --add-flags "-jar $out/${name}.jar"
  '';
}
