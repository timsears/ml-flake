{
  description = "Dev shell for machine learning";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.mach-nix.url = "github:DavHau/mach-nix";
  inputs.jupyterWith.url = "github:tweag/jupyterWith";
  inputs.jupyterWith.flake = false;
  
  outputs = {self, nixpkgs, flake-utils, mach-nix, jupyterWith }:
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
            # conda
            # pip
            # virtualenv
            # setuptools
            #
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
          
        # iPython = jupyter.kernels.iPythonWith {
        #   name = "mach-nix-jupyter";
        #   #python3 = myPython.python;
        #   # packages = myPython.python.pkgs.selectPkgs;
        # };
        
        # jupyterEnvironment = jupyter.jupyterlabWith {
        #   kernels = [
        #     iPython
        #   ];
        # };
        
        devShell = myShell;
        defaultPackage = myPython;
        

        # paganini-custom = mylib.mkPython {
        #   requirements = ''
        #     paganini==1.3.3
        #     cvxpy>=1.1.7 
        #     scs==2.1.1-2 # scs 2.1.2 broken 
        #   '';
        # };

        # devShell = pkgs.mkShell {
        #   #name = "ml-dev";
        #   buildInputs = with pkgs; [
        #     python37Packages.conda
        #     python37Packages.virtualenv
        #     python37Packages.pip
        #     python37Packages.setuptools
        #     python37Packages.numpy
        #     python37Packages.scikitlearn
        #     python37Packages.scipy
        #     python37Packages.matplotlib
        #     python37Packages.notebook
        #     # a couple of deep learning libraries
        #     #python37Packages.tensorflowWithCuda 
        #     #python37Packages.Keras
        #     #python37Packages.pytorchWithCuda
        #     python37Packages.pytorch
        #     python37Packages.torchvision

        #     # Lets assume we also want to use R, maybe to compare sklearn and R models
        #     R
        #     rPackages.mlr
        #     rPackages.data_table # "_" replaces "."
        #     rPackages.ggplot2
            
        #   ];
          
        #   shellHook = ''
        #   # add non-nix-supported packages here if needed. 
        #   # virtualenv example...
        #   # echo "yellowbrick" > requirements.txt
        #   # virtualenv simpleEnv
        #   # source simpleEnv/bin/activate
        #   # pip install -r requirements.txt 
        #  '';
        # };

      in {
        inherit devShell;
        defaultPackage = myPython;
      }
    );
}
