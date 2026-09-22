{
  description = "darknet-zig: darknet rewritten in Zig with an AMD HIP backend";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.zig
          pkgs.rocmPackages.clr       # HIP runtime: libamdhip64.so
          pkgs.rocmPackages.hipcc     # compiles src/kernels/darknet_kernels.hip
          pkgs.rocmPackages.rocminfo  # `rocminfo` -- tells you your --offload-arch
        ];

        ROCM_PATH = "${pkgs.rocmPackages.clr}";

        shellHook = ''
          export HIP_PATH="${pkgs.rocmPackages.clr}"
          export LD_LIBRARY_PATH="${pkgs.rocmPackages.clr}/lib:$LD_LIBRARY_PATH"
          echo "darknet-zig dev shell."
          echo "  CPU build : zig build -Doptimize=ReleaseFast"
          echo "  GPU build : rocminfo | grep gfx   # find your arch, then:"
          echo "              zig build -Doptimize=ReleaseFast -Dgpu=true \\"
          echo "                        -Drocm-path=\$ROCM_PATH -Doffload-arch=gfx1030"
        '';
      };
    };
}
