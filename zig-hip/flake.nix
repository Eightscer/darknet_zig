{
  description = "Zig + AMD HIP demos devShell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.zig
          pkgs.rocmPackages.clr        # HIP runtime: provides libamdhip64.so + headers
          pkgs.rocmPackages.hipcc      # hipcc: compiles the .hip device kernels
          pkgs.rocmPackages.rocminfo   # `rocminfo` -- use it to find your --offload-arch
          pkgs.SDL2                    # windowing/display for the plasma demo
        ];

        ROCM_PATH = "${pkgs.rocmPackages.clr}";
        SDL2_PATH = "${pkgs.SDL2}";

        shellHook = ''
          export HIP_PATH="${pkgs.rocmPackages.clr}"
          export LD_LIBRARY_PATH="${pkgs.rocmPackages.clr}/lib:${pkgs.SDL2}/lib:$LD_LIBRARY_PATH"
          echo "ROCm devShell ready. Run 'rocminfo | grep gfx' to find your GPU's arch string, then:"
          echo "  zig build run         -Drocm-path=\$ROCM_PATH -Doffload-arch=<yours>   (vector-add)"
          echo "  zig build run-plasma  -Drocm-path=\$ROCM_PATH -Dsdl2-path=\$SDL2_PATH -Doffload-arch=<yours>"
        '';
      };
    };
}
