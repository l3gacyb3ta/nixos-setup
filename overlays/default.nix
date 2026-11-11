final: prev: {
	gram = final.callPackage ../pkgs/gram.nix { };
	hermes-agent = final.callPackage ../pkgs/hermes.nix { };
	thoth = final.callPackage ../pkgs/thoth.nix { };
}
