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

        machNix = import mach-nix {
          python = "python37";
          inherit pkgs;
        };

        pytorch-gpu = machNix.nixpkgs.python37Packages.pytorchWithCuda;
  
        myPython = machNix.mkPython rec {

          requirements = ''
            # torch-gpu
            jupyterlab
            # torchvision
            # matplotlib
            # scipy
            # scikit-learn
          '';

          packagesExtra = [ pytorch-gpu ];
          
          # providers = {
          #   _default = "nixpkgs,wheel,sdist";
          #   dataclasses = "wheel";
          #   };
          
        };

        devShell = pkgs.mkShell rec {
          buildInputs = [
            myPython
          ];
          
          shellHook = ''
            jupyter lab --notebook-dir=./
          '';
        };

        defaultPackage = myPython;

      in {
        inherit devShell defaultPackage;
      }
    );
}
