// The only host-side C in the project. stb_image is a single-header library:
// it needs exactly one translation unit to define STB_IMAGE_IMPLEMENTATION so
// the function bodies get emitted, and this file is it.
//
// Writing a JPEG/PNG decoder in Zig was not the point of the rewrite, and
// matching darknet's pixel-for-pixel decode behaviour matters if you want
// weights trained here to behave identically to weights trained by upstream
// darknet. So we vendor the same public-domain decoder darknet itself uses.

#define STB_IMAGE_IMPLEMENTATION
#define STBI_NO_HDR
#define STBI_NO_LINEAR
#include "stb_image.h"

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"
