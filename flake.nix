{
  inputs.nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {

      devShells.${system}.default = pkgs.mkShellNoCC {
        packages = with pkgs; [
          gitleaks
          shellcheck
          git-filter-repo
        ];
        shellHook = ''
          echo && chezmoi status && echo
        '';
      };
    };
}
