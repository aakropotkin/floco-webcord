# ============================================================================ #
#
# 
#
# ---------------------------------------------------------------------------- #
{

  description = "probably a discord frontend or something";

  inputs.nixpkgs.follows = "/at-node-nix/nixpkgs";
  inputs.at-node-nix.url = "github:aameen-tulip/at-node-nix";

# ---------------------------------------------------------------------------- #

  outputs = { nixpkgs, at-node-nix, ... } @ inputs: let

# ---------------------------------------------------------------------------- #

    overlays.deps    = at-node-nix.overlays.default;
    overlays.webcord = final: prev: {
      flocoPackages = let
        metaEnt = let
          metaRaw = ( import ./meta.nix )."webcord/2.1.4";
        in final.lib.libmeta.metaEntFromRaw' { typecheck = false; } metaRaw;
      in prev.flocoPackages.extend ( fpFinal: fpPrev: {
        "webcord/2.1.4" = final.mkBinPackage {
          ident          = "webcord";
          version        = "2.1.4";
          key            = "webcord/2.1.4";
          src            = builtins.fetchTree metaEnt.fetchInfo;
          globalNmDirCmd = ":";
          moduleInstall  = false;
        };
      } );  # End flocoPackages
    };  # End webcordOverlay

    # Our project + dependencies prepared for consumption as a Nixpkgs extension.
    overlays.default = nixpkgs.lib.composeExtensions overlays.deps
                                                     overlays.webcord;

# ---------------------------------------------------------------------------- #

  in {  # Begin Outputs

# ---------------------------------------------------------------------------- #

    # Exposes our extension to Nixpkgs for other projects to use.
    inherit overlays;

# ---------------------------------------------------------------------------- #

    # Exposes our project to the Nix CLI
    packages = at-node-nix.lib.eachDefaultSystemMap ( system: let
      pkgsFor = nixpkgs.legacyPackages.${system}.extend overlays.default;
      package = pkgsFor.flocoPackages."webcord/2.1.4";
    in {
      # Expose our package as an "installable". ( uses package.json name ).
      webcord = package;
      default = package;
    } );


# ---------------------------------------------------------------------------- #

  };  # End Outputs

}


# ---------------------------------------------------------------------------- #
#
# SERIAL: 8
#
# ============================================================================ #
