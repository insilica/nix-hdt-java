{
  description = "hdt-java as a flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      with import nixpkgs { inherit system; };
      let
        hdt-version = "3.0.10";

        hdt-java = stdenv.mkDerivation {
          pname = "hdt-java";
          version = hdt-version;

          src = fetchurl {
            url = "https://github.com/rdfhdt/hdt-java/releases/download/v${hdt-version}/rdfhdt.tar.gz";
            hash = "sha256-m5fyjr6R+9Zkkts202Uxr0BTala9eGyLuYz3CuepeMU=";
          };

          buildInputs = [ jdk ];

          nativeBuildInputs = [ makeWrapper ];

          installPhase = ''
            cp -r . "$out"

            rm "$out"/bin/*.bat
            rm "$out"/bin/*.ps1
            sed -i 's/javaenv\.sh/hdt-java-javaenv.sh/g' $(ls "$out"/bin/*.sh | grep -v javaenv);
            mv "$out"/bin/javaenv.sh "$out"/bin/hdt-java-javaenv.sh
            for i in $(ls "$out"/bin/*.sh | grep -v javaenv); do
              wrapProgram "$i" --prefix "PATH" : "${jdk}/bin/"
            done
          '';

          meta = with lib; {
            homepage = "http://www.rdfhdt.org/";
            description =
              "HDT-lib is a Java Library that implements the W3C Submission (http://www.w3.org/Submission/2011/03/) of the RDF HDT (Header-Dictionary-Triples) binary format for publishing and exchanging RDF data at large scale. Its compact representation allows storing RDF in fewer space, providing at the same time direct access to the stored information. ";
            license = licenses.lgpl21;
            platforms = platforms.linux;
          };
        };
      in {
        packages = {
          default = hdt-java;
        };
      });

}
