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
          cp admb/src/nh99/*.* .
          cp admb/src/linad99/*.* .
          cp admb/src/tools99/*.* .
          cp admb/src/df1b2-separable/*.* .
          sed -i 's/#include <admodel.h>/#include "admodel.h"/g' *.*
          sed -i 's/#  include <admodel.h>/#include "admodel.h"/g' *.*
          sed -i 's/#include <fvar.hpp>/#include "fvar.hpp"/g' *.*
          sed -i 's/#  include <fvar.hpp>/#include "fvar.hpp"/g' *.*
          sed -i 's/#include <df1b2fun.h>/#include "df1b2fun.h"/g' *.*
          sed -i 's/#  include <df1b2fun.h>/#include "df1b2fun.h"/g' *.*
          sed -i 's/#include <df1b2loc.h>/#include "df1b2loc.h"/g' *.*
          sed -i 's/#include <adrndeff.h>/#include "adrndeff.h"/g' *.*
          sed -i 's/#  include <adrndeff.h>/#include "adrndeff.h"/g' *.*
          sed -i 's/#include <tiny_ad.hpp>/#include "tiny_ad.hpp"/g' *.*
          sed -i 's/#include <dfpool.h>/#include "dfpool.h"/g' *.*
          sed -i 's/#include <ivector.h>/#include "ivector.h"/g' *.*
          sed -i 's/#include <gradient_structure.h>/#include "gradient_structure.h"/g' *.*
          sed -i 's/#include <imatrix.h>/#include "imatrix.h"/g' *.*
          sed -i 's/#include <adstring.hpp>/#include "adstring.hpp"/g' *.*
          sed -i 's/#include <cifstrem.h>/#include "cifstrem.h"/g' *.*
          sed -i 's/#include <Vectorize.hpp>/#include "Vectorize.hpp"/g' *.*
          sed -i 's/#include <adpool.h>/#include "adpool.h"/g' *.*
          sed -i 's/#include <tiny_wrap.hpp>/#include "tiny_wrap.hpp"/g' *.*
          sed -i 's/#include <integrate_wrap.hpp>/#include "integrate_wrap.hpp"/g' *.*
          sed -i 's/#include <df32fun.h>/#include "df32fun.h"/g' *.*
          sed -i 's/#include <df1b2fnl.h>/#include "df1b2fnl.h"/g' *.*
          sed -i 's/#include <df3fun.h>/#include "df3fun.h"/g' *.*
          sed -i 's/#include "\.\.\/linad99\/betacf_val.hpp"/#include "betacf_val.hpp"/g' *.*
          sed 's/std::scientific < setp/std::scientific << std::setp/g' xfmmtr1.cpp > xfmmtr1.cpp
          sed 's/#include "tweedie_logW.cpp"//g' dtweedie.cpp > dtweedie2.cpp
          cat tweedie_logW.cpp >> dtweedie2.cpp
          mv dtweedie2.cpp dtweedie.cpp
          rm tweedie_logW.cpp
          sed "s/abs(\(.*parm_1(j, 8) > 0\))/\1/g" ss3.cpp > ss31.cpp
          sed -e '/#include <ss3.htp>/rss3.htp' ss31.cpp > ss32.cpp
          sed "s/#include <ss3.htp>//g" ss32.cpp > ss33.cpp
          mv ss33.cpp ss3.cpp
          rm ss3.htp
          rm ss31.cpp
          rm ss32.cpp
          rm getopt.cpp
          sed -e '/#include "integrate.cpp"/rintegrate.cpp' integrate.hpp > integrate2.hpp
          sed 's/#include "integrate.cpp"//g' integrate2.hpp > integrate3.hpp
          mv integrate3.hpp integrate.hpp
          rm integrate2.hpp
          rm integrate.cpp
      '';

        installPhase = ''
          mkdir -p $out/bin
          install -t $out/bin ss3.cpp
          mkdir -p $out/data
          cp source/models/Simple/starter.ss $out/data
          cp source/models/Simple/control.ss $out/data
          cp source/models/Simple/data.ss $out/data
          cp source/models/Simple/forecast.ss $out/data
        '';   

     };

  };
}


