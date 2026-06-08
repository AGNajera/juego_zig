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
            .speed = 6.7,
        };
    }

    pub fn update(self: *@This()) void {
        if (rl.isKeyDown(rl.KeyboardKey.d)) self.position_x += self.speed;
        if (rl.isKeyDown(rl.KeyboardKey.a)) self.position_x -= self.speed;
        if (self.position_x < 0) self.position_x = 0;
        if (self.position_x + self.width > @as(f32, @floatFromInt(rl.getScreenWidth()))) {
            self.position_x = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.width;
        }
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

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    heigth: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, heigth: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .heigth = heigth,
            .speed = 12.0,
            .active = false,
        };
    }

    pub fn update(self: *@This()) void {
        if (self.active) {
            self.position_y -= self.speed;
            if (self.position_y < 0) self.active = false;
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) rl.drawRectangle(
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
    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_heigth = 10.0;

    const player_width = 50.0;
    const player_heigth = 30.0;

    var player: Player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_heigth)) - 60.0,
        player_width,
        player_heigth,
    );

    var bullets: [max_bullets]Bullet = undefined;

    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bullet_width, bullet_heigth);
    }

    rl.initWindow(screen_width, screen_heigth, "Primera vez Raylib y Zig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.black);
        player.update();
        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            for (&bullets) |*bullet| {
                if (!bullet.active) {
                    bullet.position_x = player.position_x + player.width / 2 - bullet.width / 2;
                    bullet.position_y = player.position_y;
                    bullet.active = true;
                    break;
                }
            }
        }
        // Esto puede ser ineficiente ya que se usan dos loops,
        // uno para actualizar y otro para dibujar.
        // No se sí se pueda hace de otra manera (imagino que sí), pero bueno, soy nuevo así que...
        for (&bullets) |*bullet| {
            bullet.update();
        }

        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }
        rl.drawText("Raylib y Zig", 350, 280, 32, rl.Color.purple);
    }
}
