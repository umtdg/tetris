const std = @import("std");
const raylib = @import("raylib");

const Vector2 = raylib.Vector2;
const Color = raylib.Color;

const CELL_SIZE: usize = 40;

const BUFFER_HEIGHT: usize = 20;
const PLAYFIELD_DIM = Vector2{ .x = 10, .y = 20 };
const GRID_DIM = Vector2{ .x = PLAYFIELD_DIM.x, .y = BUFFER_HEIGHT + PLAYFIELD_DIM.y };
const GRID_SIZE = Vector2{ .x = GRID_DIM.x * CELL_SIZE, .y = GRID_DIM.y * CELL_SIZE };

const WINDOW_SIZE = Vector2{
    .x = CELL_SIZE * PLAYFIELD_DIM.x + 100,
    .y = CELL_SIZE * PLAYFIELD_DIM.y,
};
const VIEWPORT_SIZE = Vector2{
    .x = CELL_SIZE * PLAYFIELD_DIM.x,
    .y = CELL_SIZE * (PLAYFIELD_DIM.y + BUFFER_HEIGHT),
};

// #1a1b26
const BACKGROUND_COLOR = raylib.RAYWHITE;

pub fn main(_: std.process.Init) !void {
    raylib.SetTargetFPS(60);

    raylib.InitWindow(WINDOW_SIZE.x, WINDOW_SIZE.y, "Tetris");
    defer raylib.CloseWindow();

    var camera = raylib.Camera2D{
        .target = Vector2{ .x = WINDOW_SIZE.x / 2.0, .y = CELL_SIZE * (PLAYFIELD_DIM.y / 2.0 + BUFFER_HEIGHT) },
        .offset = Vector2{ .x = WINDOW_SIZE.x / 2.0, .y = WINDOW_SIZE.y / 2.0 },
        .rotation = 0.0,
        .zoom = 1.0,
    };

    const grid: [GRID_DIM.y][GRID_DIM.x]bool = .{.{false} ** GRID_DIM.x} ** GRID_DIM.y;

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyDown(raylib.KEY_UP)) {
            camera.target.y -= 4.0;
        }

        if (raylib.IsKeyDown(raylib.KEY_DOWN)) {
            camera.target.y += 4.0;
        }

        {
            raylib.BeginDrawing();
            defer raylib.EndDrawing();

            // BACKGROUND_COLOR.ClearBackground();
            raylib.ClearBackground(BACKGROUND_COLOR);

            {
                raylib.BeginMode2D(camera);
                defer raylib.EndMode2D();

                for (0..grid.len + 1) |row| {
                    const y: f32 = @floatFromInt(row * CELL_SIZE);
                    raylib.DrawLineDashed(
                        Vector2{ .x = 0, .y = y },
                        Vector2{ .x = GRID_SIZE.x, .y = y },
                        2,
                        2,
                        raylib.LIGHTGRAY,
                    );
                }

                for (0..grid[0].len + 1) |col| {
                    const x: f32 = @floatFromInt(col * CELL_SIZE);
                    raylib.DrawLineDashed(
                        Vector2{ .x = x, .y = 0 },
                        Vector2{ .x = x, .y = GRID_SIZE.y },
                        2,
                        2,
                        raylib.LIGHTGRAY,
                    );
                }

                for (0..grid.len) |row| {
                    for (0..grid[row].len) |col| {
                        const x: f32 = @floatFromInt(col * CELL_SIZE);
                        const y: f32 = @floatFromInt(row * CELL_SIZE);

                        if (grid[row][col]) {
                            raylib.DrawRectangleRec(
                                raylib.Rectangle{
                                    .x = x,
                                    .y = y,
                                    .width = CELL_SIZE,
                                    .height = CELL_SIZE,
                                },
                                raylib.RED,
                            );
                        }
                    }
                }
            }
        }
    }
}
