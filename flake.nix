{
  description = "Dev shell for machine learning";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.mach-nix.url = "github:DavHau/mach-nix";
  
  outputs = {self, ... }@inputs : with inputs;
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
          };
        };
        
        myPython = (pkgs.python37.withPackages (p: with p; [
          pytorchWithCuda
          jupyterlab
          torchvision
          matplotlib
        ])).override (_ : { ignoreCollisions = true; });

        myShell = pkgs.mkShell rec {

          buildInputs = [
            myPython
            pkgs.conda
          ];
          
          shellHook = ''
            jupyter lab --notebook-dir=~/
          '';
        };
          
        devShell = myShell;

        defaultPackage = myPython;
        
      in {
        inherit devShell defaultPackage;
      }
    );
}
