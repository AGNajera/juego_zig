const rl = @import("raylib");
const Rectangle = struct {
    y: f32,
    x: f32,
    width: f32,
    height: f32,
    pub fn intersects(self: Rectangle, other: Rectangle) bool {
        return self.x < other.x + self.width and
            self.x + self.width > other.x and
            self.y < other.x + self.width and
            self.y + self.height > other.y;
    }
};

const Game_config = struct {
    sreen_width: i32,
    screen_height: i32,
    player_width: f32,
    player_height: f32,
    player_start_y: f32,
    bullet_width: f32,
    bullet_height: f32,
    shield_start_x: f32,
    shield_y: f32,
    shield_width: f32,
    shield_height: f32,
    shield_spacing: f32,
    invader_start_x: f32,
    invader_start_y: f32,
    invader_width: f32,
    invader_height: f32,
    invader_spacing_x: f32,
    invader_spacing_y: f32,
};

const Player = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
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
            .height = self.height,
        };
    }

    pub fn draw(self: @This()) void {
        rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.white,
        );
    }
};

const Bullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
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
            @intFromFloat(self.height),
            rl.Color.green,
        );
    }

    pub fn get_rectangle(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const Invader = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    alive: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 6.7,
            .alive = true,
        };
    }

    pub fn draw(self: @This()) void {
        if (self.alive) rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.green,
        );
    }

    pub fn update(self: *@This(), dx: f32, dy: f32) void {
        self.position_x += dx;
        self.position_y += dy;
    }

    pub fn get_rectangle(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }
};

const EnemyBullet = struct {
    position_x: f32,
    position_y: f32,
    width: f32,
    height: f32,
    speed: f32,
    active: bool,

    pub fn init(position_x: f32, position_y: f32, width: f32, height: f32) @This() {
        return .{
            .position_x = position_x,
            .position_y = position_y,
            .width = width,
            .height = height,
            .speed = 5.5,
            .active = false,
        };
    }

    pub fn get_rectangle(self: @This()) Rectangle {
        return .{
            .x = self.position_x,
            .y = self.position_y,
            .width = self.width,
            .height = self.height,
        };
    }

    pub fn update(self: *@This(), screen_height: i32) void {
        if (self.active) {
            self.position_y += self.speed;
            if (self.position_y > @as(f32, @floatFromInt(screen_height))) {
                self.active = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.active) rl.drawRectangle(
            @intFromFloat(self.position_x),
            @intFromFloat(self.position_y),
            @intFromFloat(self.width),
            @intFromFloat(self.height),
            rl.Color.red,
        );
    }
};

pub fn main() void {
    const screen_width = 900;
    const screen_height = 600;
    const max_bullets = 10;
    const bullet_width = 4.0;
    const bullet_height = 10.0;
    const invader_rows = 5;
    const invader_cols = 11;
    const invader_width = 40.0;
    const invader_height = 30.0;
    const invader_start_x = 100.0;
    const invader_start_y = 50.0;
    const invader_spacing_x = 60.0;
    const invader_spacing_y = 40.0;
    const invader_speed = 11.0;
    const invader_move_delay = 10;
    const invader_drop_distance = 35.0;
    const max_enemy_bullets = 20;
    const enemy_shoot_delay = 55;
    const enemy_shoot_chance = 7;
    // aplico tipo a las variables 'var' ya que son var y así sé de que tipo son para modificarlas :D
    // aunque tambien se puede aplicar inferencia (creo), pero bueno...
    var invader_direction: f32 = 1.0;
    var move_timer: f32 = 0;
    var enemy_shoot_timer: i32 = 0;
    var score: i32 = 0;
    var game_over: bool = false;
    const player_width = 50.0;
    const player_height = 30.0;

    var player: Player = Player.init(
        @as(f32, @floatFromInt(screen_width)) / 2 - player_width / 2,
        @as(f32, @floatFromInt(screen_height)) - 60.0,
        player_width,
        player_height,
    );

    var bullets: [max_bullets]Bullet = undefined;
    for (&bullets) |*bullet| {
        bullet.* = Bullet.init(0, 0, bullet_width, bullet_height);
    }

    var enemy_bullets: [max_enemy_bullets]EnemyBullet = undefined;
    for (&enemy_bullets) |*bullet| {
        bullet.* = EnemyBullet.init(0, 0, bullet_width, bullet_height);
    }

    var invaders: [invader_rows][invader_cols]Invader = undefined;
    for (&invaders, 0..) |*row, i| {
        for (row, 0..) |*invader, j| {
            const x = invader_start_x + @as(f32, @floatFromInt(j)) * invader_spacing_x;
            const y = invader_start_y + @as(f32, @floatFromInt(i)) * invader_spacing_y;
            invader.* = Invader.init(x, y, invader_width, invader_height);
        }
    }

    rl.initWindow(screen_width, screen_height, "Primera vez Raylib y Zig");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (game_over) {
            rl.drawText("GAME OVER", 300, 350, 36, rl.Color.red);
            const score_text = rl.textFormat("Final score %d", .{score});
            rl.drawText(score_text, 320, 410, 32, rl.Color.white);
            rl.drawText("ENTER para jugar de nuevo, ESC para salir", 380, 410, 28, rl.Color.green);

            if (rl.isKeyPressed(rl.KeyboardKey.enter)) game_over = false; // resetear el juego será después, ya es noche.
            continue;
        }

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

        for (&bullets) |*bullet| {
            if (bullet.active) {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        if (invader.alive) {
                            if (bullet.get_rectangle().intersects(invader.get_rectangle())) {
                                bullet.active = false;
                                invader.alive = false;
                                score += 10;
                                break;
                            }
                        }
                    }
                }
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.update(screen_height);
            if (bullet.active) {
                bullet.active = false;
                game_over = true;
            }
        }

        for (&enemy_bullets) |*bullet| {
            bullet.update(screen_height);
        }
        enemy_shoot_timer += 1;
        if (enemy_shoot_timer >= enemy_shoot_delay) {
            enemy_shoot_timer = 0;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive and rl.getRandomValue(0, 100) < enemy_shoot_chance) {
                        for (&enemy_bullets) |*bullet| {
                            if (!bullet.active) {
                                bullet.position_x = invader.position_x + invader.width / 2 - bullet.width / 2;
                                bullet.position_y = invader.position_y + invader.height;
                                bullet.active = false;
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        }

        // Muchos loops e ifs, pero bueno que le voy a hacer, este proyecto me está volviendo
        // a que me vaya a web, pero volver a escirbir HTML Y CSS zzz... :/
        move_timer += 1;
        if (move_timer >= invader_move_delay) {
            move_timer = 0;
            var hit_edge = false;
            for (&invaders) |*row| {
                for (row) |*invader| {
                    if (invader.alive) {
                        const next_x = invader.position_x + (invader_speed * invader_direction);
                        if (next_x < 0 or next_x + invader.width > @as(f32, @floatFromInt(screen_width))) {
                            hit_edge = true;
                            break;
                        }
                    }
                }
                if (hit_edge) break;
            }
            if (hit_edge) {
                invader_direction *= -1.0;
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(0, invader_drop_distance);
                    }
                }
            } else {
                for (&invaders) |*row| {
                    for (row) |*invader| {
                        invader.update(invader_speed * invader_direction, 0);
                    }
                }
            }
        }

        player.draw();
        for (&bullets) |*bullet| {
            bullet.draw();
        }

        for (&invaders) |*row| {
            for (row) |*invader| {
                invader.draw();
            }
        }
        for (&enemy_bullets) |*bullet| {
            bullet.draw();
        }
        const score_text = rl.textFormat("Score: %d", .{score});
        rl.drawText(score_text, 20, screen_height - 20, 24, rl.Color.white);
        rl.drawText("Raylib y Zig - SPACE dispara, ESC para salir", 20, 20, 28, rl.Color.purple);
    }
}
