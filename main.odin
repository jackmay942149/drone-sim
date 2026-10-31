package main

import "core:c"
import "core:log"

import la "core:math/linalg"

import rl "vendor:raylib"

/* --- Window ---  */
window_size :: [2]i32{800, 600}
ppm :: f32(window_size.y) / 10 // Makes vertical height be 10m regardless of window size

world_to_screen :: proc(world: la.Vector2f32) -> (x: i32, y: i32) {
	x = window_size.x / 2 + i32(world.x * ppm)
	y = window_size.y / 2 - i32(world.y * ppm)
	return
}

/* --- Physics ---  */
Body :: struct {
	position: la.Vector2f32,
	size:     la.Vector2f32,
	velocity: la.Vector2f32,
}

physics_update :: proc(body: ^Body, dt: f32) {
	assert(body != nil)
	body.position += body.velocity * dt
}

/* --- Renderer ---  */
draw_body :: proc(body: Body) {
	pos_x, pos_y := world_to_screen(body.position)
	size := body.size * ppm
	offset_x := i32(body.size.x * ppm) / 2
	offset_y := i32(body.size.y * ppm) / 2

	rl.DrawRectangle(pos_x - offset_x, pos_y - offset_y, i32(size.x), i32(size.y), rl.BLUE)
}

draw_grid :: proc(delta_x, delta_y: f32) {
	// Draw Axis
	origin_x, origin_y := world_to_screen(la.Vector2f32{})
	rl.DrawLine(c.INT32_MIN, origin_y, c.INT32_MAX, origin_y, rl.RED)
	rl.DrawLine(origin_x, c.INT32_MIN, origin_x, c.INT32_MAX, rl.GREEN)

	// Draw minor horizontals
	offset_x: f32 = 0
	for true {
		offset_x += delta_x
		line_x_pos, _ := world_to_screen(la.Vector2f32{offset_x, 0})
		line_x_neg, _ := world_to_screen(la.Vector2f32{-offset_x, 0})

		if line_x_pos > window_size.x {
			break
		}
		rl.DrawLine(line_x_pos, 0, line_x_pos, window_size.y, rl.BLACK)
		rl.DrawLine(line_x_neg, 0, line_x_neg, window_size.y, rl.BLACK)
	}

	// Draw minor verticals
	offset_y: f32 = 0
	for true {
		offset_y += delta_y
		_, line_y_pos := world_to_screen(la.Vector2f32{0, offset_y})
		_, line_y_neg := world_to_screen(la.Vector2f32{0, -offset_y})

		if line_y_pos < 0 {
			break
		}
		rl.DrawLine(0, line_y_pos, window_size.x, line_y_pos, rl.BLACK)
		rl.DrawLine(0, line_y_neg, window_size.x, line_y_neg, rl.BLACK)
	}

}

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(window_size.x, window_size.y, "Drone Simulator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	body := Body {
		position = {0, 0},
		size     = {1, 1},
	}

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		draw_grid(1, 1)
		draw_body(body)

		rl.EndDrawing()
	}
}

