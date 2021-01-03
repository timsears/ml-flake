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

        # myPython = pkgs.python37.withPackages ( p: with p; [
        #     pytorchWithCuda
        #     jupyterlab
        #     conda
        #     torchvision
        # ]);

        machNix = import mach-nix {
          python = "python37";
          inherit pkgs;
        };

        pytorch-gpu = machNix.nixpkgs.python37Packages.pytorchWithCuda.overrideAttrs
          (old: { pname = "pytorch";});
  
        pyEnv = machNix.mkPython rec {

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
            pyEnv
          ];
          
          shellHook = ''
            jupyter lab --notebook-dir=./
          '';
        };
        
      in {
        inherit devShell;
        packages = { inherit pytorch-gpu; } ;
        # inherit defaultPackage;
      }
    );
}
