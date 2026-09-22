const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // -------------------------------------------------------------------
    // Options
    // -------------------------------------------------------------------
    // GPU support is off by default so the project builds and the CPU path
    // stays testable on machines with no ROCm installed at all.
    const gpu = b.option(bool, "gpu", "Build with the AMD HIP backend") orelse false;

    // Comma-separated list, e.g. -Doffload-arch=gfx1030,gfx1100. hipcc happily
    // takes several --offload-arch flags and bundles every ISA into one code
    // object, which is what you want when the machine that runs the binary
    // isn't the machine that built it. Find yours with `rocminfo | grep gfx`.
    const offload_arch = b.option(
        []const u8,
        "offload-arch",
        "AMD GPU target(s), comma separated, e.g. gfx1030,gfx1100",
    ) orelse "gfx1030";

    // Passed in from the shell rather than read inside build.zig: the exact
    // std.Build API for reading environment variables keeps moving between
    // Zig releases, so `nix develop` just expands $ROCM_PATH on the command
    // line. Same convention the zig-hip demo used.
    const rocm_path = b.option([]const u8, "rocm-path", "Path to the ROCm/HIP install") orelse "/opt/rocm";

    const options = b.addOptions();
    options.addOption(bool, "gpu", gpu);

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
        mod.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{rocm_path}) });
        mod.linkSystemLibrary("amdhip64", .{});
    }

    const exe = b.addExecutable(.{
        .name = "darknet-zig",
        .root_module = mod,
    });
    b.installArtifact(exe);

    // -------------------------------------------------------------------
    // Device kernels
    // -------------------------------------------------------------------
    // Zig has no amdgcn backend, so the kernels are HIP C++ compiled by hipcc
    // into a standalone code object (.hsaco) that the Zig host code loads at
    // runtime through hipModuleLoad. This is the entire C++ surface of the
    // project.
    if (gpu) {
        const hipcc = b.addSystemCommand(&.{"hipcc"});
        var it = std.mem.tokenizeScalar(u8, offload_arch, ',');
        while (it.next()) |arch| {
            hipcc.addArg(b.fmt("--offload-arch={s}", .{arch}));
        }
        hipcc.addArgs(&.{ "-O3", "-c", "--genco", "-o" });
        const hsaco = hipcc.addOutputFileArg("darknet_kernels.hsaco");
        hipcc.addFileArg(b.path("src/kernels/darknet_kernels.hip"));

        const install_hsaco = b.addInstallFileWithDir(hsaco, .bin, "darknet_kernels.hsaco");
        b.getInstallStep().dependOn(&install_hsaco.step);

        // A step that builds *only* the code object, so you can syntax-check
        // the kernels on a machine with hipcc but no AMD card in it.
        const kernels_step = b.step("kernels", "Compile the HIP device kernels only");
        kernels_step.dependOn(&install_hsaco.step);
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
