package main

import "core:c"
import "core:log"

import "core:math"
import la "core:math/linalg"

import rl "vendor:raylib"

import "./physics"

/* --- Window ---  */
window_size :: [2]i32{1800, 1080}
ppm :: f32(window_size.y) / 10 // Makes vertical height be 10m regardless of window size

world_to_screen :: proc(world: la.Vector2f32) -> (x: i32, y: i32) {
	x = window_size.x / 2 + i32(world.x * ppm)
	y = window_size.y / 2 - i32(world.y * ppm)
	return
}

/* --- Renderer ---  */
draw_body :: proc(body: physics.Body) {
	pos_x, pos_y := world_to_screen(body.position)
	size := body.size * ppm

	// rl.DrawRectangle(pos_x - offset_x, pos_y - offset_y, i32(size.x), i32(size.y), rl.BLUE)
	rec := rl.Rectangle {
		x      = f32(pos_x),
		y      = f32(pos_y),
		width  = size.x,
		height = size.y,
	}

	origin := rl.Vector2{size.x / 2, size.y / 2}
	rl.DrawRectanglePro(rec, origin, -body.angle * 180 / math.PI, rl.BLUE)
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

body_initial :: physics.Body {
	position = {0, 0},
	size     = {1.2, 0.1},
	mass     = 1,
}

Motor :: struct {
	thrust: f32,
	offset: f32,
}

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(window_size.x, window_size.y, "Drone Simulator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	physics_accumulator: f32 = 0
	body := body_initial
	paused := false
	gravity_enabled := false

	l_motor := Motor {
		thrust = 0,
		offset = -0.5,
	}
	r_motor := Motor {
		thrust = 0,
		offset = 0.5,
	}

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		// Input
		if rl.IsKeyPressed(.R) {
			body = body_initial
			physics_accumulator = 0
			l_motor.thrust = 0
			r_motor.thrust = 0
		}
		if rl.IsKeyPressed(.SPACE) {
			paused = !paused
		}
		if rl.IsKeyPressed(.G) {
			gravity_enabled = !gravity_enabled
		}

		if rl.IsKeyDown(.E) && !paused {
			r_motor.thrust += 15 * delta
			r_motor.thrust = min(r_motor.thrust, 10)
		} else if !paused {
			r_motor.thrust -= 15 * delta
			r_motor.thrust = max(r_motor.thrust, 0)
		}
		if rl.IsKeyDown(.Q) && !paused {
			l_motor.thrust += 15 * delta
			l_motor.thrust = min(l_motor.thrust, 10)
		} else if !paused {
			l_motor.thrust -= 15 * delta
			l_motor.thrust = max(l_motor.thrust, 0)
		}

		// Physics
		if (!paused) {
			physics_accumulator += delta
		}

		for physics_accumulator >= physics.tick {
			if gravity_enabled {
				physics.add_gravity(&body)
			}

			l_motor_world_pos := physics.local_to_world(body, {l_motor.offset, 0})
			r_motor_world_pos := physics.local_to_world(body, {r_motor.offset, 0})
			l_motor_force := physics.local_force_to_world(body, {0, l_motor.thrust})
			r_motor_force := physics.local_force_to_world(body, {0, r_motor.thrust})

			physics.add_force_at_point(&body, l_motor_force, l_motor_world_pos)
			physics.add_force_at_point(&body, r_motor_force, r_motor_world_pos)
			physics.update(&body, physics.tick)
			physics_accumulator -= physics.tick
		}

		// Rendering
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		draw_grid(1, 1)
		draw_body(body)

		// Draw motor forces
		l_motor_world_pos := physics.local_to_world(body, {l_motor.offset, 0})
		l_pos_x, l_pos_y := world_to_screen(l_motor_world_pos)
		l_motor_force := physics.local_force_to_world(body, {0, l_motor.thrust})
		rl.DrawLine(
			l_pos_x,
			l_pos_y,
			l_pos_x - i32(l_motor_force.x * ppm),
			l_pos_y - i32(l_motor_force.y * ppm),
			rl.WHITE,
		)

		r_motor_world_pos := physics.local_to_world(body, {r_motor.offset, 0})
		r_pos_x, r_pos_y := world_to_screen(r_motor_world_pos)
		r_motor_force := physics.local_force_to_world(body, {0, r_motor.thrust})
		rl.DrawLine(
			r_pos_x,
			r_pos_y,
			r_pos_x - i32(r_motor_force.x * ppm),
			r_pos_y - i32(r_motor_force.y * ppm),
			rl.WHITE,
		)

		if paused {
			rl.DrawText("Paused", 10, 10, 20, rl.RED)
		} else {
			rl.DrawText("Running", 10, 10, 20, rl.GREEN)
		}

		if gravity_enabled {
			rl.DrawText("Gravity: Enabled", 10, 30, 20, rl.GREEN)
		} else {
			rl.DrawText("Gravity: Disabled", 10, 30, 20, rl.RED)
		}

		rl.EndDrawing()
	}
}

