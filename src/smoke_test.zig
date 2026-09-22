//! End-to-end checks that run without a GPU or a dataset on disk: build a
//! small network from cfg source, train it on synthetic data, and round-trip
//! its weights through the darknet binary format.
//!
//! These are the tests that would have caught a broken backward pass. They
//! are deliberately cheap enough to run on every `zig build test`.

const std = @import("std");
const sys = @import("sys.zig");
const parser = @import("parser.zig");
const net_mod = @import("network.zig");
const data_mod = @import("data.zig");
const matrix = @import("matrix.zig");
const utils = @import("utils.zig");

const tiny_cfg =
    \\[net]
    \\batch=8
    \\subdivisions=1
    \\height=8
    \\width=8
    \\channels=3
    \\learning_rate=0.1
    \\momentum=0.9
    \\decay=0.0005
    \\policy=constant
    \\max_batches=200
    \\
    \\[convolutional]
    \\batch_normalize=1
    \\filters=8
    \\size=3
    \\stride=1
    \\pad=1
    \\activation=leaky
    \\
    \\[maxpool]
    \\size=2
    \\stride=2
    \\
    \\[convolutional]
    \\filters=2
    \\size=1
    \\stride=1
    \\pad=1
    \\activation=linear
    \\
    \\[avgpool]
    \\
    \\[softmax]
    \\groups=1
;

/// Two linearly separable classes: dim images and bright ones.
fn makeSyntheticData(allocator: std.mem.Allocator, rows: usize) !data_mod.Data {
    const side = 8;
    const pixels = side * side * 3;
    var d: data_mod.Data = .{ .w = side, .h = side };
    d.x = try matrix.Matrix.init(allocator, rows, pixels);
    d.y = try matrix.Matrix.init(allocator, rows, 2);
    var rng = utils.Rng.init(7);
    for (0..rows) |i| {
        const class = i % 2;
        const base: f32 = if (class == 0) 0.2 else 0.8;
        for (d.x.vals[i]) |*p| p.* = base + rng.uniform(-0.05, 0.05);
        d.y.vals[i][class] = 1;
    }
    return d;
}

fn setupIo() std.Io.Threaded {
    return std.Io.Threaded.init(std.testing.allocator, .{});
}

test "a small classifier learns a separable synthetic task" {
    const allocator = std.testing.allocator;
    var threaded = setupIo();
    defer threaded.deinit();
    sys.init(threaded.io(), allocator);
    utils.seedDefault(1234);

    var net = try parser.parseNetworkSource(allocator, tiny_cfg);
    defer net.deinit();

    var d = try makeSyntheticData(allocator, 64);
    defer d.deinit(allocator);

    const first = net_mod.trainNetwork(&net, d);
    var last: f32 = first;
    for (0..30) |_| last = net_mod.trainNetwork(&net, d);

    // A separable two-class problem should be close to solved after 30 passes.
    try std.testing.expect(last < first);
    try std.testing.expect(last < 0.1);

    const acc = try net_mod.accuracies(&net, d, 2);
    try std.testing.expect(acc[0] > 0.95);
}

test "weights round trip through the darknet binary format" {
    const allocator = std.testing.allocator;
    var threaded = setupIo();
    defer threaded.deinit();
    sys.init(threaded.io(), allocator);
    utils.seedDefault(99);

    var net = try parser.parseNetworkSource(allocator, tiny_cfg);
    defer net.deinit();

    var d = try makeSyntheticData(allocator, 32);
    defer d.deinit(allocator);
    // Train briefly so the saved weights are not just the initialisation, and
    // so the batch-norm rolling statistics are non-trivial.
    for (0..5) |_| _ = net_mod.trainNetwork(&net, d);
    net.seen = 4242;

    var tmp = std.testing.tmpDir(.{});
    defer tmp.cleanup();
    var path_buf: [std.Io.Dir.max_path_bytes]u8 = undefined;
    const dir_len = try tmp.dir.realPath(sys.io, &path_buf);
    const dir_path = path_buf[0..dir_len];
    const weights_path = try std.fmt.allocPrint(allocator, "{s}/round_trip.weights", .{dir_path});
    defer allocator.free(weights_path);

    try parser.saveWeights(&net, weights_path);

    var reloaded = try parser.parseNetworkSource(allocator, tiny_cfg);
    defer reloaded.deinit();
    try parser.loadWeights(&reloaded, weights_path);

    try std.testing.expectEqual(@as(u64, 4242), reloaded.seen);

    // Same input, same prediction, to the last bit.
    const probe = d.x.vals[0];
    const a = net_mod.predict(&net, probe);
    const a_copy = try allocator.dupe(f32, a[0..net.outputs]);
    defer allocator.free(a_copy);
    const b = net_mod.predict(&reloaded, probe);
    for (a_copy, b[0..net.outputs]) |x, y| {
        try std.testing.expectApproxEqAbs(x, y, 1e-6);
    }
}

test "analytic gradients match finite differences" {
    const allocator = std.testing.allocator;
    var threaded = setupIo();
    defer threaded.deinit();
    sys.init(threaded.io(), allocator);
    utils.seedDefault(5);

    // No batch norm here: its forward pass depends on the whole batch, so a
    // single-weight perturbation moves the normalisation too and the finite
    // difference stops matching the per-weight partial derivative.
    const cfg_src =
        \\[net]
        \\batch=4
        \\subdivisions=1
        \\height=6
        \\width=6
        \\channels=3
        \\learning_rate=0.01
        \\momentum=0.9
        \\decay=0
        \\policy=constant
        \\max_batches=10
        \\
        \\[convolutional]
        \\filters=4
        \\size=3
        \\stride=1
        \\pad=1
        \\activation=leaky
        \\
        \\[convolutional]
        \\filters=3
        \\size=1
        \\stride=1
        \\pad=1
        \\activation=linear
        \\
        \\[avgpool]
        \\
        \\[softmax]
        \\groups=1
    ;

    var net = try parser.parseNetworkSource(allocator, cfg_src);
    defer net.deinit();

    var rng = utils.Rng.init(11);
    for (net.input) |*v| v.* = rng.uniform(0, 1);
    @memset(net.truth, 0);
    for (0..net.batch) |b| net.truth[b * 3 + (b % 3)] = 1;

    net.train = true;
    net_mod.forward(&net);
    net_mod.backward(&net);

    const l = &net.layers[0];
    // The cost is the summed cross entropy over the batch; `weight_updates`
    // holds -dCost/dw, since darknet's delta convention is truth - pred.
    const analytic = try allocator.dupe(f32, l.weight_updates);
    defer allocator.free(analytic);

    const eps: f32 = 1e-2;
    var checked: usize = 0;
    var i: usize = 0;
    while (i < l.nweights and checked < 8) : (i += 7) {
        const original = l.weights[i];

        l.weights[i] = original + eps;
        net_mod.forward(&net);
        const up = net.cost;

        l.weights[i] = original - eps;
        net_mod.forward(&net);
        const down = net.cost;

        l.weights[i] = original;

        const numeric = -(up - down) / (2 * eps);
        const scale = @max(1.0, @max(@abs(numeric), @abs(analytic[i])));
        try std.testing.expectApproxEqAbs(numeric / scale, analytic[i] / scale, 2e-2);
        checked += 1;
    }
    try std.testing.expect(checked > 0);
}

test "batch norm rolling statistics follow darknet's 0.99 EMA" {
    // Why this test exists: at inference the normalisation uses
    // `rolling_mean`/`rolling_variance`, which start at zero and are dragged
    // towards the batch statistics by only 1% per step. A network is
    // therefore not usable for inference until roughly 500+ batches have
    // passed, however low its *training* loss has gone -- and with a deep
    // stack of batch-normalised layers the error compounds once per layer.
    // That is darknet's behaviour, reproduced here on purpose, and it is
    // surprising enough to be worth pinning down.
    const allocator = std.testing.allocator;
    var threaded = setupIo();
    defer threaded.deinit();
    sys.init(threaded.io(), allocator);

    const batchnorm = @import("layers/batchnorm.zig");
    const lay = @import("layer.zig");

    const batch = 4;
    const w = 3;
    const h = 3;
    const c = 2;

    var l = try batchnorm.make(allocator, batch, w, h, c);
    defer l.deinit(allocator);

    const input = try allocator.alloc(f32, batch * w * h * c);
    defer allocator.free(input);
    var rng = utils.Rng.init(31);
    for (input) |*v| v.* = rng.uniform(-2, 2);

    // Fixed input and frozen weights, so the per-batch statistics are
    // identical every step and the EMA has a closed form.
    var state: lay.State = .{ .input = input, .train = true };
    const steps = 200;
    for (0..steps) |_| batchnorm.forward(&l, &state);

    const expected_fraction = 1.0 - std.math.pow(f32, 0.99, steps);
    for (0..c) |i| {
        try std.testing.expectApproxEqRel(l.mean[i] * expected_fraction, l.rolling_mean[i], 1e-3);
        try std.testing.expectApproxEqRel(l.variance[i] * expected_fraction, l.rolling_variance[i], 1e-3);
    }

    // Concretely: after 200 batches the inference-time variance is still
    // ~13% low, which inflates activations by ~7% per batch-normalised layer.
    try std.testing.expect(expected_fraction > 0.86 and expected_fraction < 0.88);
}
