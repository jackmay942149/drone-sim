package main

import "core:c"
import "core:log"

import "core:math"
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
physics_tick :: 1.0 / 120.0
physics_accumulator: f32 = 0
gravity :: 9.81

Body :: struct {
	position:         la.Vector2f32,
	size:             la.Vector2f32,
	velocity:         la.Vector2f32,
	net_force:        la.Vector2f32,
	mass:             f32,
	angle:            f32,
	angular_velocity: f32,
	net_torque:       f32,
}

body_add_force :: proc(body: ^Body, force: la.Vector2f32) {
	assert(body != nil)
	body.net_force += force
}

body_add_gravity :: proc(body: ^Body) {
	assert(body != nil)
	assert(body.mass > 0)
	body_add_force(body, body.mass * la.Vector2f32{0, -gravity})
}

body_add_torque :: proc(body: ^Body, torque: f32) {
	assert(body != nil)
	body.net_torque += torque
}

body_moment_of_inertia :: proc(body: Body) -> f32 {
	w_sqrd := body.size.x * body.size.x
	h_sqrd := body.size.y * body.size.y
	return body.mass * (w_sqrd + h_sqrd) / 12
}

physics_update :: proc(body: ^Body, dt: f32) {
	assert(body != nil)
	assert(body.mass > 0)

	// Get acceleration newton's second law
	acceleration := body.net_force / body.mass
	body.net_force = {}

	// Get velocity semi-implicit Euler integration
	body.velocity += acceleration * dt
	body.position += body.velocity * dt

	angular_acceleration := body.net_torque / body_moment_of_inertia(body^)
	body.net_torque = 0

	body.angular_velocity += angular_acceleration * dt
	body.angle += body.angular_velocity * dt
}

/* --- Renderer ---  */
draw_body :: proc(body: Body) {
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

body_initial :: Body {
	position = {0, 0},
	size     = {1, 1},
	mass     = 1,
}

main :: proc() {
	context.logger = log.create_console_logger()

	rl.InitWindow(window_size.x, window_size.y, "Drone Simulator")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	body := body_initial
	paused := false
	gravity_enabled := false

	for !rl.WindowShouldClose() {
		delta := rl.GetFrameTime()

		// Input
		if rl.IsKeyPressed(.R) {
			body = body_initial
			physics_accumulator = 0
		}
		if rl.IsKeyPressed(.SPACE) {
			paused = !paused
		}
		if rl.IsKeyPressed(.G) {
			gravity_enabled = !gravity_enabled
		}

		torque: f32 = 0
		if rl.IsKeyDown(.E) {
			torque -= 1
		}
		if rl.IsKeyDown(.Q) {
			torque += 1
		}

		// Physics
		if (!paused) {
			physics_accumulator += delta
		}

		for physics_accumulator >= physics_tick {
			if gravity_enabled {
				body_add_gravity(&body)
			}

			body_add_torque(&body, torque)

			physics_update(&body, physics_tick)
			physics_accumulator -= physics_tick
		}

		// Rendering
		rl.BeginDrawing()
		rl.ClearBackground(rl.GRAY)

		draw_grid(1, 1)
		draw_body(body)

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

