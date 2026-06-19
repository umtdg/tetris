const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const tetris_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const tetris_exe = b.addExecutable(.{
        .name = "tetris",
        .root_module = tetris_mod,
    });
    b.installArtifact(tetris_exe);

    const tetris_run = b.addRunArtifact(tetris_exe);
    const tetris_run_step = b.step("run", "Run");
    tetris_run_step.dependOn(&tetris_run.step);

    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });
    tetris_mod.linkLibrary(raylib_dep.artifact("raylib"));
    tetris_mod.addImport("raylib", raylib_dep.module("raylib"));
}
