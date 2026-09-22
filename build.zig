const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -------------------------------------------------------------------
    // Options
    // -------------------------------------------------------------------
    // GPU support is off by default so the project builds and the CPU path
    // stays testable on machines with no ROCm or CUDA installed at all.
    const gpu = b.option(bool, "gpu", "Build with a GPU backend") orelse false;

    const Backend = enum { hip, cuda };
    const backend = b.option(
        Backend,
        "gpu-backend",
        "Which GPU backend to build: hip (AMD, default) or cuda (NVIDIA)",
    ) orelse .hip;
    const cuda = backend == .cuda;

    // Comma-separated list, e.g. -Doffload-arch=gfx1030,gfx1100. hipcc happily
    // takes several --offload-arch flags and bundles every ISA into one code
    // object, which is what you want when the machine that runs the binary
    // isn't the machine that built it. Find yours with `rocminfo | grep gfx`.
    const offload_arch = b.option(
        []const u8,
        "offload-arch",
        "AMD GPU target(s), comma separated, e.g. gfx1030,gfx1100",
    ) orelse "gfx1030";

    // The NVIDIA side needs no equivalent list. We emit PTX, which the driver
    // JIT-compiles on load, so one artifact runs on any GPU at or above this
    // virtual architecture. compute_52 (Maxwell) is about as low as CUDA 12
    // still accepts; raise it if you want to drop the deprecation warning or
    // use newer PTX features.
    const cuda_arch = b.option(
        []const u8,
        "cuda-arch",
        "NVIDIA virtual architecture for the PTX, e.g. compute_52",
    ) orelse "compute_52";

    // Passed in from the shell rather than read inside build.zig: the exact
    // std.Build API for reading environment variables keeps moving between
    // Zig releases, so `nix develop` just expands $ROCM_PATH on the command
    // line. Same convention the zig-hip demo used.
    const rocm_path = b.option([]const u8, "rocm-path", "Path to the ROCm/HIP install") orelse "/opt/rocm";
    const cuda_path = b.option([]const u8, "cuda-path", "Path to the CUDA toolkit install") orelse "/usr/local/cuda";

    const options = b.addOptions();
    options.addOption(bool, "gpu", gpu);
    options.addOption(bool, "cuda", cuda);

    // -------------------------------------------------------------------
    // The library module: everything except the CLI entry point
    // -------------------------------------------------------------------
    const mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    mod.addOptions("build_options", options);

    // stb_image, compiled as C. See src/c/stb_impl.c for why this exists.
    mod.addIncludePath(b.path("src/c"));
    mod.addCSourceFile(.{
        .file = b.path("src/c/stb_impl.c"),
        .flags = &.{ "-std=c99", "-O2", "-fno-sanitize=undefined" },
    });

    if (gpu) {
        if (cuda) {
            // libcuda ships with the *driver*, not the toolkit, so at link
            // time we bind against the toolkit's stub and the real one is
            // resolved at load. This is the standard arrangement for driver
            // API programs and is why a build machine needs no NVIDIA GPU.
            //
            // Where the stub lives varies by distribution, and Zig treats a
            // library path that does not exist as an error rather than a
            // warning, so probe rather than adding every candidate.
            const candidates = [_][]const u8{
                "lib64/stubs", "lib/stubs", "lib/x86_64-linux-gnu/stubs",
                "lib64",       "lib",
            };
            var found_stub = false;
            for (candidates) |rel| {
                const dir = b.fmt("{s}/{s}", .{ cuda_path, rel });
                std.Io.Dir.accessAbsolute(b.graph.io, dir, .{}) catch continue;
                mod.addLibraryPath(.{ .cwd_relative = dir });
                found_stub = true;
            }
            if (!found_stub) {
                std.debug.print(
                    "warning: no library directory found under {s}; " ++
                        "pass -Dcuda-path=<toolkit root> if linking against libcuda fails\n",
                    .{cuda_path},
                );
            }
            mod.linkSystemLibrary("cuda", .{});
        } else {
            mod.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{rocm_path}) });
            mod.linkSystemLibrary("amdhip64", .{});
        }
    }

    const exe = b.addExecutable(.{
        .name = "darknet-zig",
        .root_module = mod,
    });
    b.installArtifact(exe);

    // -------------------------------------------------------------------
    // Device kernels
    // -------------------------------------------------------------------
    // Zig can target neither amdgcn nor nvptx, so the kernels are compiled by
    // the vendor toolchain into a standalone code object that the Zig host
    // loads at runtime. One source file serves both; see its header. This is
    // the entire C++ surface of the project.
    if (gpu) {
        const object: std.Build.LazyPath = if (cuda) blk: {
            // -x cu because the file is named .hip. PTX rather than a cubin,
            // so the result is architecture-independent.
            const nvcc = b.addSystemCommand(&.{b.fmt("{s}/bin/nvcc", .{cuda_path})});
            nvcc.addArgs(&.{
                "-ptx",
                "-x",  "cu",
                "-O3", b.fmt("-arch={s}", .{cuda_arch}),
                "-Wno-deprecated-gpu-targets",
                // nvcc normally finds cuda_runtime.h relative to its own
                // binary; say it explicitly so a wrapper script or a symlink
                // into the toolkit still works.
                b.fmt("-I{s}/include", .{cuda_path}),
                "-o",
            });
            const ptx = nvcc.addOutputFileArg("darknet_kernels.ptx");
            nvcc.addFileArg(b.path("src/kernels/darknet_kernels.hip"));
            break :blk ptx;
        } else blk: {
            const hipcc = b.addSystemCommand(&.{"hipcc"});
            var it = std.mem.tokenizeScalar(u8, offload_arch, ',');
            while (it.next()) |arch| {
                hipcc.addArg(b.fmt("--offload-arch={s}", .{arch}));
            }
            hipcc.addArgs(&.{ "-O3", "-c", "--genco", "-o" });
            const hsaco = hipcc.addOutputFileArg("darknet_kernels.hsaco");
            hipcc.addFileArg(b.path("src/kernels/darknet_kernels.hip"));
            break :blk hsaco;
        };

        const object_name = if (cuda) "darknet_kernels.ptx" else "darknet_kernels.hsaco";
        const install_object = b.addInstallFileWithDir(object, .bin, object_name);
        b.getInstallStep().dependOn(&install_object.step);

        // A step that builds *only* the code object, so you can syntax-check
        // the kernels on a machine that has the compiler but no matching card.
        const kernels_step = b.step("kernels", "Compile the device kernels only");
        kernels_step.dependOn(&install_object.step);
    }

    // -------------------------------------------------------------------
    // run / test
    // -------------------------------------------------------------------
    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| run.addArgs(args);
    const run_step = b.step("run", "Build and run darknet-zig");
    run_step.dependOn(&run.step);

    const unit_tests = b.addTest(.{ .root_module = mod });
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
