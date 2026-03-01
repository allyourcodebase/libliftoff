const std = @import("std");
const LinkMode = std.builtin.LinkMode;

const manifest = @import("build.zig.zon");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const options = .{
        .linkage = b.option(LinkMode, "linkage", "Library linkage type") orelse
            .static,
    };

    const deps = .{
        .libdrm = if (!b.systemIntegrationOption("libdrm", .{}))
            b.lazyDependency("libdrm", .{ .target = target, .optimize = optimize })
        else
            null,
    };

    const upstream = b.dependency("libliftoff_c", .{});

    const mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    mod.addIncludePath(upstream.path("include"));

    if (deps.libdrm) |dep|
        mod.linkLibrary(dep.artifact("drm"))
    else
        mod.linkSystemLibrary("libdrm", .{});

    mod.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = srcs,
        .flags = flags,
    });

    const lib = b.addLibrary(.{
        .name = "liftoff",
        .root_module = mod,
        .linkage = options.linkage,
        .version = try .parse(manifest.version),
    });

    lib.installHeader(upstream.path("include/libliftoff.h"), "libliftoff.h");
    b.installArtifact(lib);
}

const flags: []const []const u8 = &.{ "-fvisibility=hidden", "-std=c11" };

const srcs: []const []const u8 = &.{
    "alloc.c", "device.c", "layer.c", "list.c",
    "log.c",   "output.c", "plane.c",
};
