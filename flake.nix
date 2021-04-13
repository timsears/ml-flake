

{
  description = "Dev shell for machine learning";
  inputs.nixpkgs.url = "nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.mach-nix.url = "github:DavHau/mach-nix";

  outputs = {self, ... }@inputs : with inputs;
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let

        machnix = import mach-nix {
          python = "python38";
          inherit pkgs;
        };
        
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            allowBroken = true;
            # overlays = final: prev: {
            #   python38 = prev.python38.override {
            #     packageOverrides = pyfinal: pyprev: {
            #       pytorch-lightning = pyfinal.python3.pkgs.callPackage ./pytorch-lightning { };
            #     };
            #   };
            # };
          };
        };
    
        #myPython = (pkgs.python38.withPackages (p: with p; [
        myPython = machnix.mkPython {
          requirements = '' 
            pytorch-lightning 
            jupyterlab
            ipywidgets
            matplotlib
            pyro-ppl
            #pytorchWithCuda
            #pytorch-bin
            #torch
            pytorch-lightning
            PyYAML == 5.3.1
            scikit-learn
            tensorboard
            torchvision
          '' ;
          providers.torch = "nixpkgs";
          overridesPost = [(curr: prev: {
            torch = prev.torch.override {
              cudaSupport = true;
            };
          })];
          # packagesExtra = [
          # jupyterlab
          # ipywidgets
          # matplotlib
          # pyro-ppl
          # #pytorchWithCuda
          # pytorch-bin
          # #pytorch-lightning
          # scikitlearn
          # tensorflow-tensorboard_2
          # torchvision
          # ];
        };
    #)).override (_ : { ignoreCollisions = true; });

        myShell = pkgs.mkShell rec {

          buildInputs = [
            myPython
            pkgs.conda
          ];


          shellHook = ''
            jupyter notebook --ip="0.0.0.0" --notebook-dir="~/" --no-browser
          '';
        };
          
        devShell = myShell;
        defaultPackage = myPython;
        
      in
        {
          inherit devShell defaultPackage;
        }
    );
}
