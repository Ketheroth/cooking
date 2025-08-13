{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/25.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          cook-cli
        ];
      };
      packages.${system} =
        let
          start-server-src = pkgs.lib.readFile ./start-server.sh;
          chef = pkgs.rustPlatform.buildRustPackage {
            pname = "chef";
            version = "0.10.1";
            src = pkgs.fetchFromGitHub {
              owner = "Zheoni";
              repo = "cooklang-chef";
              tag = "v0.10.1";
              hash = "sha256-U/zEtDHIAjBakMjIqpJeFzTxof8SHSgLj9zjgND6q1Q=";
            };
            cargoHash = "sha256-gk5ayEXCILTyX59xANHHNYtMSRJZIEMGXKPhKAJU1bk=";
            meta = {
              description = "A CLI to manage cooklang recipes";
              homepage = "https://github.com/Zheoni/cooklang-chef";
              licence = pkgs.lib.licenses.mit;
              maintainers = [ ];
            };
          };
          start-server = (pkgs.writeScriptBin "start-server" start-server-src).overrideAttrs (old: {
            buildCommand = "${old.buildCommand}\n patchShebangs $out";
          });
        in
        {
          start-server = pkgs.symlinkJoin {
            name = "start-server";
            paths = [ start-server ];
            buildInputs = [ pkgs.makeWrapper ];
            postBuild = "wrapProgram $out/bin/start-server --prefix PATH : $out/bin";
          };
          chef = chef;
          default = chef;
        };
    };
}
