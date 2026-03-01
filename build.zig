const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const linkage = b.option(std.builtin.LinkMode, "linkage", "Library linkage type") orelse .static;

    const upstream = b.dependency("upstream", .{});
    const libdrm_dep = b.dependency("libdrm", .{ .target = target, .optimize = optimize });
    const src = upstream.path("");

    const mod = b.createModule(.{ .target = target, .optimize = optimize, .link_libc = true });
    mod.addIncludePath(src.path(b, "include"));
    mod.linkLibrary(libdrm_dep.artifact("drm"));
    mod.addCSourceFiles(.{ .root = src, .files = sources, .flags = &.{ "-fvisibility=hidden", "-std=c11" } });

    const lib = b.addLibrary(.{ .name = "liftoff", .root_module = mod, .linkage = linkage });
    lib.installHeader(src.path(b, "include/libliftoff.h"), "libliftoff.h");
    b.installArtifact(lib);
}

const sources: []const []const u8 = &.{
    "alloc.c", "device.c", "layer.c", "list.c",
    "log.c",   "output.c", "plane.c",
};
