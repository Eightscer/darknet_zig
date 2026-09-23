{
  description = "darknet-zig: darknet rewritten in Zig, with AMD HIP and NVIDIA CUDA backends";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      # CUDA is unfree, so the NVIDIA shell needs its own instantiation.
      pkgsCuda = import nixpkgs { inherit system; config.allowUnfree = true; };

      # build.zig wants a single directory laid out like a CUDA toolkit:
      # bin/nvcc, include/cuda_runtime.h, lib/stubs/libcuda.so. nixpkgs splits
      # those across packages, and across *outputs* in a way that has changed
      # between revisions -- some have cuda_cudart.dev and .stubs, others put
      # everything in the default output. Join whatever exists rather than
      # naming outputs that may not be there.
      optionalOutput = drv: name: if drv ? ${name} then drv.${name} else null;
      cudaRoot = pkgsCuda.symlinkJoin {
        name = "cuda-toolkit-root";
        paths = builtins.filter (p: p != null) (with pkgsCuda.cudaPackages; [
          cuda_nvcc
          cuda_cudart
          (optionalOutput cuda_nvcc "dev")
          (optionalOutput cuda_cudart "dev")
          (optionalOutput cuda_cudart "stubs")
          (optionalOutput cuda_cudart "lib")
        ]);
      };
    in {
      devShells.${system} = {
        # AMD, and the default: `nix develop`
        default = pkgs.mkShell {
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
            echo "darknet-zig, AMD shell."
            echo "  CPU build : zig build -Doptimize=ReleaseFast"
            echo "  GPU build : rocminfo | grep gfx   # find your arch, then:"
            echo "              zig build -Doptimize=ReleaseFast -Dgpu=true \\"
            echo "                        -Drocm-path=\$ROCM_PATH -Doffload-arch=gfx1030"
          '';
        };

        # NVIDIA: `nix develop .#cuda`
        cuda = pkgsCuda.mkShell {
          buildInputs = [ pkgsCuda.zig cudaRoot ];

          CUDA_PATH = "${cudaRoot}";

          shellHook = ''
            echo "darknet-zig, NVIDIA shell."
            echo "  CUDA_PATH = $CUDA_PATH"
            echo "  GPU build : zig build -Doptimize=ReleaseFast -Dgpu=true \\"
            echo "                        -Dgpu-backend=cuda -Dcuda-path=\$CUDA_PATH"
            echo "  (libcuda itself comes from the driver at run time, not from here.)"
          '';
        };
      };
    };
}
