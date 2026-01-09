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
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "aw-watcher-media-player";
          version = "1.1.1";

          src = ./.;

          cargoLock = {
            lockFile = ./Cargo.lock;
            outputHashes = {
              "aw-client-rust-0.1.0" = "sha256-fCjVfmjrwMSa8MFgnC8n5jPzdaqSmNNdMRaYHNbs8Bo=";
            };
          };

          nativeBuildInputs = with pkgs; [
            pkg-config
          ];

          buildInputs = with pkgs; [
            dbus
            openssl
          ];

          meta = with pkgs.lib; {
            description = "A cross-platform watcher to report currently playing media to ActivityWatch";
            homepage = "https://github.com/2e3s/aw-watcher-media-player";
            license = licenses.mpl20;
            maintainers = [ ];
            mainProgram = "aw-watcher-media-player";
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.default ];

          packages = with pkgs; [
            cargo
            rustc
            rust-analyzer
            clippy
            rustfmt
          ];
        };
      }
    );
}
