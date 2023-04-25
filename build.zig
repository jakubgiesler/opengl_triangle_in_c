const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});

    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("triangle_in_c", null);
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");
    exe.linkSystemLibrary("opengl32");

    exe.addIncludePath("deps/include");

    const GLAD_PATH  = "deps/glad/";
    exe.addIncludePath(GLAD_PATH ++ "include");
    exe.addCSourceFile(GLAD_PATH ++ "src/glad.c", &[_][]const u8 { });

    const GLFW_PATH = "deps/glfw-3.3.8/";
    exe.addIncludePath(GLFW_PATH ++ "include");
    exe.addCSourceFile(GLFW_PATH ++ "src/" ++ "sources_all.c", &[_][]const u8 { "-D _GLFW_WIN32" });
    exe.addCSourceFile(GLFW_PATH ++ "src/" ++ "sources_windows.c", &[_][]const u8 { "-D _GLFW_WIN32" });

    exe.addCSourceFile("src/main.c", &[_][]const u8 {
        "-std=c17",
        "-pedantic",
        "-Wall",
        "-W",
        "-Wno-missing-field-initializers",
        "-fno-sanitize=undefined",
    });

    exe.linkLibC();

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
