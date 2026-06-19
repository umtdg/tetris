const std = @import("std");
const raylib = @import("raylib");

const Vector2 = raylib.Vector2;

const CELL_SIZE = 40;
const PLAYFIELD_DIMS = Vector2{ .x = 10, .y = 16 };
const PLAYFIELD_SIZE = Vector2{
    .x = PLAYFIELD_DIMS.x * CELL_SIZE,
    .y = PLAYFIELD_DIMS.y * CELL_SIZE,
};

const WINDOW_SIZE = Vector2{
    .x = PLAYFIELD_SIZE.x + 200,
    .y = PLAYFIELD_SIZE.y,
};

const Point = struct {
    row: u8,
    col: u8,
};

const Cell = struct {
    active: bool,
    position: Vector2,

    pub fn init() Cell {
        return Cell{
            .active = false,
            .position = Vector2{ .x = 0, .y = 0 },
        };
    }
};

pub fn main(_: std.process.Init) !void {
    raylib.SetTargetFPS(60);

    var grid: [PLAYFIELD_DIMS.y][PLAYFIELD_DIMS.x]Cell = undefined;
    for (0..grid.len) |row| {
        for (0..grid[row].len) |col| {
            grid[row][col].position = Vector2{
                .x = @as(f32, @floatFromInt(col)) * CELL_SIZE,
                .y = @as(f32, @floatFromInt(row)) * CELL_SIZE,
            };
        }
    }

    raylib.InitWindow(WINDOW_SIZE.x, WINDOW_SIZE.y, "Tetris");
    defer raylib.CloseWindow();

    var straight_pos = Point{ .row = 0, .col = 4 };
    for (0..4) |i| {
        grid[straight_pos.row][straight_pos.col + i].active = true;
    }

    const tick_interval: f32 = 1.0;
    const epsilon = std.math.floatEps(f32);
    var tick_timer: f32 = tick_interval;

    while (!raylib.WindowShouldClose()) {
        const fps_text = raylib.TextFormat("%d FPS", raylib.GetFPS());
        const fps_font_size = 20;
        const fps_width = raylib.MeasureText(fps_text, fps_font_size);

        const delta_time = raylib.GetFrameTime();

        tick_timer -= delta_time;
        if (tick_timer <= epsilon) {
            for (0..4) |i| {
                grid[straight_pos.row][straight_pos.col + i].active = false;
                grid[straight_pos.row + 1][straight_pos.col + i].active = true;
            }
            straight_pos.row += 1;

            tick_timer = tick_interval;
        }

        {
            raylib.BeginDrawing();
            defer raylib.EndDrawing();

            raylib.ClearBackground(raylib.RAYWHITE);
            raylib.DrawText(
                fps_text,
                @as(c_int, @intFromFloat(WINDOW_SIZE.x)) - fps_width - 10,
                10,
                fps_font_size,
                raylib.GREEN,
            );

            // Playfield
            for (1..PLAYFIELD_DIMS.y) |row| {
                const y = @as(f32, @floatFromInt(row)) * CELL_SIZE;

                raylib.DrawLineDashed(
                    Vector2{ .x = 0, .y = y },
                    Vector2{ .x = PLAYFIELD_SIZE.x, .y = y },
                    1,
                    1,
                    raylib.LIGHTGRAY,
                );
            }

            for (1..PLAYFIELD_DIMS.x + 1) |col| {
                const x = @as(f32, @floatFromInt(col)) * CELL_SIZE;

                raylib.DrawLineDashed(
                    Vector2{ .x = x, .y = 0 },
                    Vector2{ .x = x, .y = PLAYFIELD_SIZE.y },
                    1,
                    1,
                    raylib.LIGHTGRAY,
                );
            }

            // Cells
            var i: u32 = 0;
            for (0..grid.len) |row| {
                for (0..grid[row].len) |col| {
                    const text = raylib.TextFormat("%d", i);
                    const cell = &grid[row][col];

                    raylib.DrawText(
                        text,
                        @as(c_int, @intFromFloat(cell.position.x)) + 15,
                        @as(c_int, @intFromFloat(cell.position.y)) + 15,
                        5,
                        raylib.LIGHTGRAY,
                    );

                    if (cell.active) {
                        raylib.DrawRectangleRec(raylib.Rectangle{
                            .x = cell.position.x,
                            .y = cell.position.y,
                            .width = CELL_SIZE,
                            .height = CELL_SIZE,
                        }, raylib.RED);
                    }

                    i += 1;
                }
            }
        }
    }
}
