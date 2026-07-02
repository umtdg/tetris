const std = @import("std");
const EnumArray = std.EnumArray;

const raylib = @import("raylib");
const Vector2 = raylib.Vector2;
const Color = raylib.Color;
const BACKGROUND_COLOR = raylib.RAYWHITE;

const Point = struct {
    x: usize,
    y: usize,

    pub fn zero() Point {
        return Point{ .x = 0, .y = 0 };
    }

    pub fn add(self: *const Point, rhs: *const Point) Point {
        return Point{ .x = self.x + rhs.x, .y = self.y + rhs.y };
    }

    pub fn subtract(self: *const Point, rhs: *const Point) Point {
        return Point{ .x = self.x - rhs.x, .y = self.y - rhs.y };
    }
};

const CELL_SIZE: usize = 40;

const BUFFER_HEIGHT: usize = 20;
const PLAYFIELD_DIM = Point{ .x = 10, .y = 20 };
const GRID_DIM = Point{ .x = PLAYFIELD_DIM.x, .y = BUFFER_HEIGHT + PLAYFIELD_DIM.y };
const GRID_SIZE = Point{ .x = GRID_DIM.x * CELL_SIZE, .y = GRID_DIM.y * CELL_SIZE };

const WINDOW_SIZE = Point{
    .x = CELL_SIZE * PLAYFIELD_DIM.x + 100,
    .y = CELL_SIZE * PLAYFIELD_DIM.y,
};
const WINDOW_SIZE_2 = Point{
    .x = @divTrunc(WINDOW_SIZE.x, 2),
    .y = @divTrunc(WINDOW_SIZE.y, 2),
};

const Tetromino = struct {
    const Piece = enum { I, O, T, S, Z, J, L };
    const State = enum { Spawn, Right, Down, Left };

    const StateData = EnumArray(State, [4]Point);
    const PieceStateData = EnumArray(Piece, StateData);

    const STATE_DATA = PieceStateData.init(.{
        .I = StateData.init(.{
            .Spawn = .{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 3, .y = 1 } },
            .Right = .{ .{ .x = 2, .y = 0 }, .{ .x = 2, .y = 1 }, .{ .x = 2, .y = 2 }, .{ .x = 2, .y = 3 } },
            .Down = .{ .{ .x = 0, .y = 2 }, .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 2 }, .{ .x = 3, .y = 2 } },
            .Left = .{ .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 }, .{ .x = 1, .y = 3 } },
        }),
        .O = StateData.init(.{
            .Spawn = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Right = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Down = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Left = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
        }),
        .T = StateData.init(.{
            .Spawn = .{ .{ .x = 1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Right = .{ .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 1, .y = 2 } },
            .Down = .{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 1, .y = 2 } },
            .Left = .{ .{ .x = 1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 } },
        }),
        .S = StateData.init(.{
            .Spawn = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 } },
            .Right = .{ .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 2, .y = 2 } },
            .Down = .{ .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 0, .y = 2 }, .{ .x = 1, .y = 2 } },
            .Left = .{ .{ .x = 0, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 } },
        }),
        .Z = StateData.init(.{
            .Spawn = .{ .{ .x = 0, .y = 0 }, .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Right = .{ .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 1, .y = 2 } },
            .Down = .{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 2 } },
            .Left = .{ .{ .x = 1, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 0, .y = 2 } },
        }),
        .J = StateData.init(.{
            .Spawn = .{ .{ .x = 0, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Right = .{ .{ .x = 1, .y = 0 }, .{ .x = 2, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 } },
            .Down = .{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 2, .y = 2 } },
            .Left = .{ .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 0, .y = 2 }, .{ .x = 1, .y = 2 } },
        }),
        .L = StateData.init(.{
            .Spawn = .{ .{ .x = 2, .y = 0 }, .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 } },
            .Right = .{ .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 }, .{ .x = 2, .y = 2 } },
            .Down = .{ .{ .x = 0, .y = 1 }, .{ .x = 1, .y = 1 }, .{ .x = 2, .y = 1 }, .{ .x = 0, .y = 2 } },
            .Left = .{ .{ .x = 0, .y = 0 }, .{ .x = 1, .y = 0 }, .{ .x = 1, .y = 1 }, .{ .x = 1, .y = 2 } },
        }),
    });

    const COLOR_DATA = EnumArray(Piece, Color).init(.{
        .I = raylib.SKYBLUE, // I
        .O = raylib.YELLOW, // O
        .T = raylib.PURPLE, // T
        .S = raylib.GREEN, // S
        .Z = raylib.RED, // Z
        .J = raylib.BLUE, // J
        .L = raylib.ORANGE, // L
    });

    piece: Piece,
    state: State,
    position: Point,

    pub fn color(self: *const Tetromino) Color {
        return COLOR_DATA.get(self.piece);
    }

    pub fn squares(self: *const Tetromino) [4]Point {
        const base = &STATE_DATA.get(self.piece).get(self.state);

        var out: [4]Point = undefined;
        for (0..4) |i| {
            out[i] = .{
                .x = base[i].x + self.position.x,
                .y = base[i].y + self.position.y,
            };
        }

        return out;
    }

    pub fn draw(self: *const Tetromino) void {
        for (self.squares()) |square| {
            raylib.DrawRectangleV(
                Vector2{
                    .x = @floatFromInt(square.x * CELL_SIZE),
                    .y = @floatFromInt(square.y * CELL_SIZE),
                },
                Vector2{ .x = CELL_SIZE, .y = CELL_SIZE },
                self.color(),
            );
        }
    }
};

// #1a1b26
pub fn main(_: std.process.Init) !void {
    raylib.SetTargetFPS(60);

    raylib.InitWindow(WINDOW_SIZE.x, WINDOW_SIZE.y, "Tetris");
    defer raylib.CloseWindow();

    const camera = raylib.Camera2D{
        .target = Vector2{
            .x = WINDOW_SIZE_2.x,
            .y = (BUFFER_HEIGHT * CELL_SIZE) + WINDOW_SIZE_2.y,
        },
        .offset = Vector2{ .x = WINDOW_SIZE_2.x, .y = WINDOW_SIZE_2.y },
        .rotation = 0.0,
        .zoom = 1.0,
    };

    const grid: [GRID_DIM.y][GRID_DIM.x]bool = .{.{false} ** GRID_DIM.x} ** GRID_DIM.y;

    var tetromino = Tetromino{
        .piece = .I,
        .state = .Spawn,
        .position = Point{ .x = 0, .y = 20 },
    };

    var game_speed: f32 = 1.0;
    var timer: f32 = 1.0 / game_speed;

    while (!raylib.WindowShouldClose()) {
        if (raylib.IsKeyDown(raylib.KEY_DOWN)) {
            game_speed = 2.0;
        }

        if (raylib.IsKeyDown(raylib.KEY_RIGHT)) {
            tetromino.position.x += 1;
        }
        if (raylib.IsKeyDown(raylib.KEY_LEFT)) {
            tetromino.position.x -= 1;
        }

        const delta_time = raylib.GetFrameTime();
        timer -= delta_time;
        if (timer <= std.math.floatEps(f32)) {
            tetromino.position.y += 1;
            timer = 1.0 / game_speed;
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

                tetromino.draw();
            }
        }
    }
}
