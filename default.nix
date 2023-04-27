
{ pkgs ? import <nixpkgs> {} }:

let
  mvn2nix = import (fetchTarball "https://github.com/fzakaria/mvn2nix/archive/master.tar.gz") {};
  mavenRepository = mvn2nix.buildMavenRepositoryFromLockFile { file = ./mvn2nix-lock.json; };
  inherit (pkgs) lib stdenv maven makeWrapper graalvm17-ce;
  inherit (stdenv) mkDerivation;
in
mkDerivation rec {
  pname = "gurupoo";
  version = "0.0.1-SNAPSHOT";
  name = "${pname}-${version}";
  src = lib.cleanSource ./.;
  nativeBuildInputs = [ graalvm17-ce maven makeWrapper ];
  buildPhase = ''
    mvn clean install spring-boot:repackage -X -Dmaven.repo.local=${mavenRepository}
  ''; # --offline
  installPhase = ''
    mkdir -p $out/bin
    ln -s ${mavenRepository} $out/lib
    cp target/${name}.jar $out/
    makeWrapper ${graalvm17-ce}/bin/java $out/bin/${pname} \
    --add-flags "-jar $out/${name}.jar"
  '';
}
