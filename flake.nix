{
  description = "darknet-zig: darknet rewritten in Zig, with AMD HIP and NVIDIA CUDA backends";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      # CUDA is unfree, so the NVIDIA shell needs its own instantiation.
      pkgsCuda = import nixpkgs { inherit system; config.allowUnfree = true; };
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
          buildInputs = [
            pkgsCuda.zig
            pkgsCuda.cudaPackages.cuda_nvcc    # compiles the kernels to PTX
            pkgsCuda.cudaPackages.cuda_cudart  # headers, and the libcuda link stub
          ];

          shellHook = ''
            # nvcc and the headers live in separate store paths, so assemble a
            # single toolkit root for -Dcuda-path to point at.
            export CUDA_PATH="$PWD/.cuda-toolkit"
            mkdir -p "$CUDA_PATH"
            ln -sfn ${pkgsCuda.cudaPackages.cuda_nvcc}/bin     "$CUDA_PATH/bin"
            ln -sfn ${pkgsCuda.cudaPackages.cuda_cudart.dev}/include "$CUDA_PATH/include"
            ln -sfn ${pkgsCuda.cudaPackages.cuda_cudart}/lib   "$CUDA_PATH/lib"
            echo "darknet-zig, NVIDIA shell."
            echo "  GPU build : zig build -Doptimize=ReleaseFast -Dgpu=true \\"
            echo "                        -Dgpu-backend=cuda -Dcuda-path=\$CUDA_PATH"
            echo "  (libcuda itself comes from the driver at run time, not from here.)"
          '';
        };
      };
    };
}
