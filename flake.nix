{
  description = "ss3o";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    
    packages.x86_64-linux.default = 

      let pkgs = import nixpkgs {
          system = "x86_64-linux";
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
      
        buildInputs = [ pkgs.flex ];

        buildPhase = ''
          flex admb/src/nh99/tpl2cpp.lex
          sed -f admb/src/nh99/sedflex lex.yy.c > tpl2cpp.c
          clang tpl2cpp.c -o tpl2cpp
          cat ss3/SS_biofxn.tpl ss3/SS_miscfxn.tpl ss3/SS_selex.tpl ss3/SS_popdyn.tpl ss3/SS_recruit.tpl ss3/SS_benchfore.tpl ss3/SS_expval.tpl ss3/SS_objfunc.tpl ss3/SS_write.tpl ss3/SS_write_ssnew.tpl ss3/SS_write_report.tpl ss3/SS_ALK.tpl ss3/SS_timevaryparm.tpl ss3/SS_tagrecap.tpl > SS_functions.temp
          cat ss3/SS_versioninfo_330safe.tpl ss3/SS_readstarter.tpl ss3/SS_readdata_330.tpl ss3/SS_readcontrol_330.tpl ss3/SS_param.tpl ss3/SS_prelim.tpl ss3/SS_global.tpl ss3/SS_proced.tpl SS_functions.temp > ss3.tpl
          ./tpl2cpp ss3
          mkdir -p admb/include
          cp ss3.htp admb/include
          cp admb/src/nh99/*.h admb/include
          cp admb/src/nh99/evalxtrn.cpp admb/include
          rm admb/src/nh99/evalxtrn.cpp
          cp admb/src/linad99/*.hpp admb/include
          cp admb/src/linad99/*.h admb/include
          cp admb/src/tools99/*.hpp admb/include
          cp admb/src/tools99/*.h admb/include
          cp admb/src/tools99/integrate.cpp admb/include
          rm admb/src/tools99/integrate.cpp
          cp admb/src/df1b2-separable/*.h admb/include
          rm admb/src/linad99/getopt.cpp
          sed "s/std::scientific < setp/std::scientific << std::setp/g" admb/src/linad99/xfmmtr1.cpp > admb/src/linad99/xfmmtr1_fix.cpp
          rm admb/src/linad99/xfmmtr1.cpp
          mv admb/src/linad99/xfmmtr1_fix.cpp admb/src/linad99/xfmmtr1.cpp        
          sed 's/#include "tweedie_logW.cpp"//g' admb/src/linad99/dtweedie.cpp > admb/src/linad99/fix.cpp
          cat admb/src/linad99/tweedie_logW.cpp >> admb/src/linad99/fix.cpp
          rm admb/src/linad99/dtweedie.cpp
          rm admb/src/linad99/tweedie_logW.cpp
          mv admb/src/linad99/fix.cpp dtweedie.cpp
          clang++ -c admb/src/linad99/*.cpp -Iadmb/include -D_USE_MATH_DEFINES
          mv expm.o linexpm.o
          clang++ -c admb/src/tools99/*.cpp -Iadmb/include -D_USE_MATH_DEFINES       
          clang++ -c admb/src/nh99/*.cpp -Iadmb/include -D_USE_MATH_DEFINES       
          clang++ -c admb/src/df1b2-separable/*.cpp -Iadmb/include -D_USE_MATH_DEFINES
          clang++ -c admb/src/sparse/*.cpp -Iadmb/include -D_USE_MATH_DEFINES
          sed "s/abs(\(.*parm_1(j, 8) > 0\))/\1/g" ss3.cpp > ss3_fix.cpp
          rm ss3.cpp
          mv ss3_fix.cpp ss3.cpp
          clang++ -c ss3.cpp -Iadmb/include -D_USE_MATH_DEFINES
          clang++ *.o -Iadmb/include/ -D_USE_MATH_DEFINES -o ss3o
      '';

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin ss3o
          mkdir -p $out/data
          cp source/models/Simple/starter.ss $out/data
          cp source/models/Simple/control.ss $out/data
          cp source/models/Simple/data.ss $out/data
          cp source/models/Simple/forecast.ss $out/data
        '';   

     };

  };
}


