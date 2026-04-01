/// @description Simulates bounce physics and expires coin after a short timer.

if (coin_collected) {
  coin_collect_vfx_steps -= 1;
  y -= 1.2;
  image_angle += 14;

  if (coin_collect_vfx_steps <= 0) {
    instance_destroy();
  }

  exit;
}

if (!game_is_running()) {
  instance_destroy();
  exit;
}

coin_life_steps -= 1;
if (coin_life_steps <= 0) {
  instance_destroy();
  exit;
}

coin_velocity_y += COIN_DROP_GRAVITY;
x += coin_velocity_x;
y += coin_velocity_y;

if (y >= coin_ground_y) {
  y = coin_ground_y;
  coin_velocity_y = -abs(coin_velocity_y) * COIN_DROP_BOUNCE_DAMPING;
  coin_velocity_x *= COIN_DROP_GROUND_FRICTION;

  if (abs(coin_velocity_y) < COIN_DROP_MIN_BOUNCE_TO_SETTLE) {
    coin_velocity_y = 0;
  }
}

image_angle += coin_rotation_speed;
coin_rotation_speed *= 0.96;
