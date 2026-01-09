{
  description = "A cross-platform watcher to report currently playing media to ActivityWatch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  nixConfig = {
    extra-substituters = [ "https://solastrius.cachix.org" ];
    extra-trusted-public-keys = [ "solastrius.cachix.org-1:MawFli42h9VuWjlURZvxDG+M/tfUbELRwU+QN/6VvdM=" ];
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        commonArgs = {
          pname = "aw-watcher-media-player";
          version = "1.1.1";
          src = ./.;
          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "aw-client-rust-0.1.0" = "sha256-fCjVfmjrwMSa8MFgnC8n5jPzdaqSmNNdMRaYHNbs8Bo=";
            };
          };
          meta = with pkgs.lib; {
            description = "A cross-platform watcher to report currently playing media to ActivityWatch";
            homepage = "https://github.com/SolAstrius/aw-watcher-media-player";
            license = licenses.mpl20;
            mainProgram = "aw-watcher-media-player";
          };
        };
      in
      {
        packages = {
          default = pkgs.rustPlatform.buildRustPackage (commonArgs // {
            nativeBuildInputs = with pkgs; [ pkg-config ];
            buildInputs = with pkgs; [ dbus openssl ];
          });

          static = pkgs.pkgsStatic.rustPlatform.buildRustPackage (commonArgs // {
            nativeBuildInputs = with pkgs.pkgsStatic; [ pkg-config ];
            buildInputs = with pkgs.pkgsStatic; [ dbus openssl ];
          });
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];
          packages = with pkgs; [ cargo rustc rust-analyzer clippy rustfmt ];
        };
      }
    );
}
