# libliftoff zig

[libliftoff](https://gitlab.freedesktop.org/emersion/libliftoff), packaged for the Zig build system.

## Using

First, update your `build.zig.zon`:

```
zig fetch --save git+https://github.com/allyourcodebase/libliftoff.git
```

Then in your `build.zig`:

```zig
const libliftoff = b.dependency("libliftoff", .{ .target = target, .optimize = optimize });
exe.linkLibrary(libliftoff.artifact("liftoff"));
```
