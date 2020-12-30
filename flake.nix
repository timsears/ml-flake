{
  description = "Dev shell for machine learning";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.mach-nix.url = "github:DavHau/mach-nix";
  inputs.jupyterWith.url = "github:tweag/jupyterWith";
  inputs.jupyterWith.flake = false;
  
  outputs = {self, ... }@inputs : with inputs;
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        
        # pkgs = nixpkgs.legacyPackages.${system};

        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            # allowUnsupportedSystem = true;
          };
        };
        
        mylib = mach-nix.lib.${system}; # adds mkPython, mkPythonShell, etc. 

        myPython = mylib.mkPython rec {
          requirements = ''
            jupyterlab
            matplotlib
            numpy
            torch
            scipy
            scikitlearn
            torchvision
          '';          
        };

        myShell = pkgs.mkShell rec {
          buildInputs = [
            myPython
          ];
          
          shellHook = ''
            jupyter lab --notebook-dir=~/
          '';
        };
          
        devShell = myShell;
        defaultPackage = myPython;
        
      in {
        inherit devShell;
        defaultPackage = myPython;
      }
    );
}
