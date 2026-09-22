const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Which GPU ISA to compile kernels for. Find yours with:
    //   rocminfo | grep gfx
    const offload_arch = b.option(
        []const u8,
        "offload-arch",
        "AMD GPU target, e.g. gfx1030, gfx1100, gfx90a",
    ) orelse "gfx1030";

    // Passed in from the shell rather than read inside build.zig -- see the
    // note on this from the vecadd demo; the exact std.Build API for reading
    // environment variables keeps moving across Zig releases, so the shell
    // just expands $ROCM_PATH / $SDL2_PATH directly on the command line.
    const rocm_path = b.option([]const u8, "rocm-path", "Path to the ROCm/HIP install") orelse "/opt/rocm";
    const sdl2_path = b.option([]const u8, "sdl2-path", "Path to the SDL2 install (optional)") orelse "";

    // =======================================================================
    // Demo 1: vector-add (src/vecadd_main.zig + src/kernel.hip)
    // =======================================================================
    const vecadd_kernel_cc = b.addSystemCommand(&.{
        "hipcc",
        b.fmt("--offload-arch={s}", .{offload_arch}),
        "-c",
        "--genco",
        "-o",
    });
    const vecadd_hsaco = vecadd_kernel_cc.addOutputFileArg("kernel.hsaco");
    vecadd_kernel_cc.addFileArg(b.path("src/kernel.hip"));

    const vecadd_exe = b.addExecutable(.{
        .name = "hip_zig_demo",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/vecadd_main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    vecadd_exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{rocm_path}) });
    vecadd_exe.root_module.linkSystemLibrary("amdhip64", .{});
    b.installArtifact(vecadd_exe);

    const install_vecadd_kernel = b.addInstallFileWithDir(vecadd_hsaco, .bin, "kernel.hsaco");
    b.getInstallStep().dependOn(&install_vecadd_kernel.step);

    const run_vecadd = b.addRunArtifact(vecadd_exe);
    run_vecadd.step.dependOn(b.getInstallStep());
    run_vecadd.setCwd(.{ .cwd_relative = b.getInstallPath(.bin, "") });
    const run_vecadd_step = b.step("run", "Build and run the vector-add demo");
    run_vecadd_step.dependOn(&run_vecadd.step);

    // =======================================================================
    // Demo 2: GPU plasma (src/plasma_main.zig + src/plasma_kernel.hip)
    // HIP computes a full frame each loop; SDL2 displays it.
    // =======================================================================
    const plasma_kernel_cc = b.addSystemCommand(&.{
        "hipcc",
        b.fmt("--offload-arch={s}", .{offload_arch}),
        "-c",
        "--genco",
        "-o",
    });
    const plasma_hsaco = plasma_kernel_cc.addOutputFileArg("plasma_kernel.hsaco");
    plasma_kernel_cc.addFileArg(b.path("src/plasma_kernel.hip"));

    const plasma_exe = b.addExecutable(.{
        .name = "gpu_plasma",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/plasma_main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    plasma_exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{rocm_path}) });
    plasma_exe.root_module.linkSystemLibrary("amdhip64", .{});
    if (sdl2_path.len > 0) {
        plasma_exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{sdl2_path}) });
    }
    plasma_exe.root_module.linkSystemLibrary("SDL2", .{});
    b.installArtifact(plasma_exe);

    const install_plasma_kernel = b.addInstallFileWithDir(plasma_hsaco, .bin, "plasma_kernel.hsaco");
    b.getInstallStep().dependOn(&install_plasma_kernel.step);

    const run_plasma = b.addRunArtifact(plasma_exe);
    run_plasma.step.dependOn(b.getInstallStep());
    run_plasma.setCwd(.{ .cwd_relative = b.getInstallPath(.bin, "") });
    const run_plasma_step = b.step("run-plasma", "Build and run the GPU plasma demo");
    run_plasma_step.dependOn(&run_plasma.step);
}
