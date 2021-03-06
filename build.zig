const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zsql", "src/zsql/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.addPackagePath("clap", "deps/zig-clap/clap.zig");
    exe.addPackagePath("postgres", "postgres.zig");
    exe.addPackagePath("cmd", "src/cmd/cmd.zig");
    exe.linkSystemLibrary("pq");
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
