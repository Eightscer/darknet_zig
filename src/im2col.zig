//! im2col / col2im: the lowering that turns a convolution into a GEMM.
//!
//! Straight from darknet, which took it from Caffe. The column buffer is
//! (channels*ksize*ksize) rows by (height_col*width_col) columns, so a
//! convolution becomes weights[filters x c*k*k] * col[c*k*k x out_h*out_w].

const std = @import("std");

pub fn outputSize(size: usize, ksize: usize, stride: usize, pad: usize) usize {
    return (size + 2 * pad - ksize) / stride + 1;
}

pub fn im2col(
    data_im: []const f32,
    channels: usize,
    height: usize,
    width: usize,
    ksize: usize,
    stride: usize,
    pad: usize,
    data_col: []f32,
) void {
    const height_col = outputSize(height, ksize, stride, pad);
    const width_col = outputSize(width, ksize, stride, pad);
    const channels_col = channels * ksize * ksize;

    for (0..channels_col) |c| {
        const w_offset = c % ksize;
        const h_offset = (c / ksize) % ksize;
        const c_im = c / ksize / ksize;
        for (0..height_col) |h| {
            // Signed, because padding puts the first rows/cols out of bounds.
            const im_row = @as(isize, @intCast(h_offset + h * stride)) - @as(isize, @intCast(pad));
            const row_valid = im_row >= 0 and im_row < @as(isize, @intCast(height));
            const col_base = (c * height_col + h) * width_col;
            if (!row_valid) {
                @memset(data_col[col_base..][0..width_col], 0);
                continue;
            }
            const im_base = (c_im * height + @as(usize, @intCast(im_row))) * width;
            for (0..width_col) |w| {
                const im_col = @as(isize, @intCast(w_offset + w * stride)) - @as(isize, @intCast(pad));
                data_col[col_base + w] = if (im_col >= 0 and im_col < @as(isize, @intCast(width)))
                    data_im[im_base + @as(usize, @intCast(im_col))]
                else
                    0;
            }
        }
    }
}

/// The adjoint of im2col: scatter-accumulate the column buffer back into an
/// image. It adds rather than assigns, because overlapping receptive fields
/// contribute to the same input pixel.
pub fn col2im(
    data_col: []const f32,
    channels: usize,
    height: usize,
    width: usize,
    ksize: usize,
    stride: usize,
    pad: usize,
    data_im: []f32,
) void {
    const height_col = outputSize(height, ksize, stride, pad);
    const width_col = outputSize(width, ksize, stride, pad);
    const channels_col = channels * ksize * ksize;

    for (0..channels_col) |c| {
        const w_offset = c % ksize;
        const h_offset = (c / ksize) % ksize;
        const c_im = c / ksize / ksize;
        for (0..height_col) |h| {
            const im_row = @as(isize, @intCast(h_offset + h * stride)) - @as(isize, @intCast(pad));
            if (im_row < 0 or im_row >= @as(isize, @intCast(height))) continue;
            const im_base = (c_im * height + @as(usize, @intCast(im_row))) * width;
            const col_base = (c * height_col + h) * width_col;
            for (0..width_col) |w| {
                const im_col = @as(isize, @intCast(w_offset + w * stride)) - @as(isize, @intCast(pad));
                if (im_col < 0 or im_col >= @as(isize, @intCast(width))) continue;
                data_im[im_base + @as(usize, @intCast(im_col))] += data_col[col_base + w];
            }
        }
    }
}

test "im2col of a 3x3 image with a 2x2 kernel" {
    const im = [_]f32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    var col: [4 * 4]f32 = undefined;
    im2col(im[0..], 1, 3, 3, 2, 1, 0, col[0..]);
    // Row 0 is the top-left element of each 2x2 window.
    try std.testing.expectEqualSlices(f32, &[_]f32{ 1, 2, 4, 5 }, col[0..4]);
    // Row 3 is the bottom-right element of each window.
    try std.testing.expectEqualSlices(f32, &[_]f32{ 5, 6, 8, 9 }, col[12..16]);
}

test "col2im accumulates overlapping contributions" {
    var col: [4 * 4]f32 = @splat(1);
    var im: [9]f32 = @splat(0);
    col2im(col[0..], 1, 3, 3, 2, 1, 0, im[0..]);
    // The centre pixel appears in all four windows.
    try std.testing.expectApproxEqAbs(@as(f32, 4), im[4], 1e-6);
    // Each corner appears in exactly one.
    try std.testing.expectApproxEqAbs(@as(f32, 1), im[0], 1e-6);
}
