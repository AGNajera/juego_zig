const rl = @import("raylib");
const Rectangle = struct {
    y: f32,
    x: f32,
    width: f32,
    heigth: f32,
    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + self.width and
            self.x + self.width > other.x and
            self.y < other.x + self.width and
            self.y + self.heigth > other.y;
    }
};

const Game_config = struct {
    sreen_width: i32,
    screen_heigth: i32,
    player_width: f32,
    player_heigth: f32,
    player_start_y: f32,
    bullet_width: f32,
    bullet_heigth: f32,
    shield_start_x: f32,
    shield_y: f32,
    shield_width: f32,
    shield_heigth: f32,
    shield_spacing: f32,
    invader_start_x: f32,
    invader_start_y: f32,
    invader_width: f32,
    invader_heigth: f32,
    invader_spacing_x: f32,
    invader_spacing_y: f32,
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    heigth: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, heigth: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .heigth = heigth,
            .speed = 5.0,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.d)) self.position_x += self.speed;
        if (rl.isKeyDown(rl.KeyboardKey.a)) self.position_x -= self.speed;
    }

    pub fn get_rectangle(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .heigth = self.heigth,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.heigth),
            rl.Color.white,
        );
    }
};

pub fn main() void {
    const screen_width = 900;
    const screen_heigth = 600;

    const player_width = 50.0;
    const player_heigth = 30.0;

    var player: Player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_heigth)) - 60.0,
        player_width,
        player_heigth,
    );

    rl.initWindow(screen_width, screen_heigth, "Primera vez Raylib y Zig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        player.update();

        player.draw();
        rl.drawText("Raylib y Zig", 350, 280, 32, rl.Color.purple);
    }
}
