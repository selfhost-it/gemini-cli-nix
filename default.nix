# Questo file permette a chi non usa i Flakes (come il NUR) di accedere al pacchetto.
{ pkgs ? import <nixpkgs> { } }:

{
  # Esponiamo il pacchetto gemini-cli usando callPackage sul file esistente.
  gemini-cli = pkgs.callPackage ./package.nix { };
}
