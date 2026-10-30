package main

import "core:log"

import la "core:math/linalg"

import rl "vendor:raylib"

/* --- Window ---  */
window_size :: [2]i32{800, 600}
ppm :: f32(window_size.y) / 4 // Makes vertical height be 4m regardless of window size

world_to_screen :: proc(world: la.Vector2f32) -> (x: i32, y: i32) {
	x = i32(world.x * ppm) + window_size.x / 2
	y = i32((world.y - 2) * ppm) * -1
	return
}

/* --- Physics ---  */
Body :: struct {
	position: la.Vector2f32,
	size:     la.Vector2f32,
}

/* --- Renderer ---  */
draw_body :: proc(body: Body) {
	pos_x, pos_y := world_to_screen(body.position)
	size := body.size * ppm
	offset_x := i32(body.size.x * ppm) / -2
	offset_y := i32(body.size.y * ppm) / -2

	rl.DrawRectangle(
		pos_x + offset_x,
		pos_y + offset_y,
		i32(body.size.x * ppm),
		i32(body.size.y * ppm),
		rl.GREEN,
	)
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

		draw_body(body)

		rl.EndDrawing()
	}
}

