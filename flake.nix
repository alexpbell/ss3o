{
  description = "ss3o";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    
    packages.aarch64-darwin.default = 

      let pkgs = import nixpkgs {
          system = "aarch64-darwin";
        };
      in pkgs.clangStdenv.mkDerivation {

        pname = "ss3o";
        version = "0.0.2";

        srcs = [
          (pkgs.fetchFromGitHub {
            owner = "admb-project";
            repo = "admb";
            rev = "admb-13.2";
            name = "admb";
            sha256 = "z7S3MqT6TQH8GW5VImCzmBnk+7XQmHeEN7ocmBHGUqg=";
          })
          (pkgs.fetchFromGitHub {
            owner = "nmfs-ost";
            repo = "ss3-source-code";
            rev = "v3.30.22.1";
            name = "ss3";
            sha256 = "r/grfMvbna6XpfovOiT96d7Mm4o06l4WzGX3VFGojYQ=";
          })
          (pkgs.fetchFromGitHub {
            owner = "nmfs-ost";
            repo = "ss3-test-models";
            rev = "ad02c34";
            sha256 = "2nqEzzKQROlsmS9SLZ+H3Fv/QDWKUeedVZdX+1w8eqw=";
          })
        ];

        sourceRoot = ".";
      
        buildInputs = [ pkgs.flex pkgs.R pkgs.rPackages.Rcpp ];

        buildPhase = ''
          flex admb/src/nh99/tpl2cpp.lex
          sed -f admb/src/nh99/sedflex lex.yy.c > tpl2cpp.c
          clang tpl2cpp.c -o tpl2cpp
          cat ss3/SS_biofxn.tpl ss3/SS_miscfxn.tpl ss3/SS_selex.tpl ss3/SS_popdyn.tpl ss3/SS_recruit.tpl ss3/SS_benchfore.tpl ss3/SS_expval.tpl ss3/SS_objfunc.tpl ss3/SS_write.tpl ss3/SS_write_ssnew.tpl ss3/SS_write_report.tpl ss3/SS_ALK.tpl ss3/SS_timevaryparm.tpl ss3/SS_tagrecap.tpl > SS_functions.temp
          cat ss3/SS_versioninfo_330safe.tpl ss3/SS_readstarter.tpl ss3/SS_readdata_330.tpl ss3/SS_readcontrol_330.tpl ss3/SS_param.tpl ss3/SS_prelim.tpl ss3/SS_global.tpl ss3/SS_proced.tpl SS_functions.temp > ss3.tpl
          ./tpl2cpp ss3
      '';

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin ss3.htp
          mkdir -p $out/data
          cp source/models/Simple/starter.ss $out/data
          cp source/models/Simple/control.ss $out/data
          cp source/models/Simple/data.ss $out/data
          cp source/models/Simple/forecast.ss $out/data
        '';   

     };

  };
}


