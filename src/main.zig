const std = @import("std");
const sdl = @cImport({
    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3_image/SDL_image.h");
});

pub fn main() !void {
    // Initialize SDL
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.debug.print("SDL_Init Error: {s}\n", .{sdl.SDL_GetError()});
        return error.SDLInitializationFailed;
    }
    defer sdl.SDL_Quit();



    // Import image data
    const image_data = @import("image_data.zig");

    // Create IO from memory
    const io = sdl.SDL_IOFromConstMem(&image_data.image_png, image_data.image_png.len);
    if (io == null) {
        std.debug.print("SDL_IOFromConstMem Error: {s}\n", .{sdl.SDL_GetError()});
        return error.IOFromMemoryFailed;
    }
    defer _ = sdl.SDL_CloseIO(io);

    // Load image from memory
    const temp_surface = sdl.IMG_Load_IO(io, true);
    if (temp_surface == null) {
        std.debug.print("IMG_Load_RW Error: {s}\n", .{sdl.SDL_GetError()});
        return error.ImageLoadFailed;
    }
    defer sdl.SDL_DestroySurface(temp_surface);

    // Get image dimensions
    const width = temp_surface.*.w;
    const height = temp_surface.*.h;

    std.debug.print("Loaded Image: {d}x{d}\n", .{ width, height });

    // Create window
    const window = sdl.SDL_CreateWindow("SDL3 PNG Renderer", width, height, @as(u32, 0));
    if (window == null) {
        std.debug.print("SDL_CreateWindow Error: {s}\n", .{sdl.SDL_GetError()});
        return error.WindowCreationFailed;
    }
    defer sdl.SDL_DestroyWindow(window);

    // Create renderer
    const renderer = sdl.SDL_CreateRenderer(window, null);
    if (renderer == null) {
        std.debug.print("SDL_CreateRenderer Error: {s}\n", .{sdl.SDL_GetError()});
        return error.RendererCreationFailed;
    }
    defer sdl.SDL_DestroyRenderer(renderer);

    // Create texture from surface
    const texture = sdl.SDL_CreateTextureFromSurface(renderer, temp_surface);
    if (texture == null) {
        std.debug.print("SDL_CreateTextureFromSurface Error: {s}\n", .{sdl.SDL_GetError()});
        return error.TextureCreationFailed;
    }
    defer sdl.SDL_DestroyTexture(texture);

    // Event loop
    var event: sdl.SDL_Event = undefined;
    var running = true;
    while (running) {
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                running = false;
            }
        }

        // Clear screen
        _ = sdl.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        _ = sdl.SDL_RenderClear(renderer);

        // Create source and destination rectangles
        var src_rect = sdl.SDL_FRect{ .x = 0, .y = 0, .w = @floatFromInt(width), .h = @floatFromInt(height) };
        var dst_rect = sdl.SDL_FRect{ .x = 0, .y = 0, .w = @floatFromInt(width), .h = @floatFromInt(height) };

        // Render image
        _ = sdl.SDL_RenderTexture(renderer, texture, &src_rect, &dst_rect);

        // Present renderer
        _ = sdl.SDL_RenderPresent(renderer);
    }
}
