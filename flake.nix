{
  description = "Dev shell for machine learning";
  inputs.nixpkgs.url = "flake:nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  # inputs.mach-nix.url = "github:DavHau/mach-nix";
  
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

        myPython = (pkgs.python3.withPackages (p: with p; [
          jupyterlab
          ipywidgets
          matplotlib
          pyro-ppl
          #pytorchWithCuda
          pytorch-bin
          pytorch-lightning
          scikitlearn
          tensorflow-tensorboard_2
          torchvision
        ])).override (_ : { ignoreCollisions = true; });

        myShell = pkgs.mkShell rec {

          buildInputs = [
            myPython
            pkgs.conda
          ];
          
          shellHook = ''
            jupyter lab --ip="0.0.0.0" --notebook-dir="~/" --no-browser
          '';
        };
          
        devShell = myShell;
        defaultPackage = myPython;
        
      in {
        inherit devShell defaultPackage;
      }
    );
}
