const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "sdl3_png_renderer",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Add system paths
    exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
    exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });

    // SDL3 paths
    const sdl3_base = "/opt/homebrew/Cellar/sdl3/3.2.4";
    exe.addIncludePath(.{ .cwd_relative = sdl3_base ++ "/include" });
    exe.addLibraryPath(.{ .cwd_relative = sdl3_base ++ "/lib" });

    // SDL3_image paths
    const sdl3_image_base = "/opt/homebrew/Cellar/sdl3_image/3.2.0";
    exe.addIncludePath(.{ .cwd_relative = sdl3_image_base ++ "/include" });
    exe.addLibraryPath(.{ .cwd_relative = sdl3_image_base ++ "/lib" });

    // Link required libraries
    exe.linkSystemLibrary("SDL3");
    exe.linkSystemLibrary("SDL3_image");

    // Add any necessary compiler flags
    exe.linkLibC();

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
}
