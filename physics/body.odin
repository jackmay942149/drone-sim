package physics

import "core:math"
import la "core:math/linalg"

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

add_force :: proc(body: ^Body, force: la.Vector2f32) {
	assert(body != nil)
	body.net_force += force
}

add_force_at_point :: proc(body: ^Body, force: la.Vector2f32, point: la.Vector2f32) {
	assert(body != nil)
	r := point - body.position

	torque := r.x * force.y - r.y * force.x
	add_torque(body, torque)
	add_force(body, force)
}


add_gravity :: proc(body: ^Body) {
	assert(body != nil)
	assert(body.mass > 0)
	add_force(body, body.mass * la.Vector2f32{0, -gravity})
}

add_torque :: proc(body: ^Body, torque: f32) {
	assert(body != nil)
	body.net_torque += torque
}

@(private)
moment_of_inertia :: proc(body: Body) -> f32 {
	assert(body.mass > 0)
	w_sqrd := body.size.x * body.size.x
	h_sqrd := body.size.y * body.size.y
	assert(w_sqrd + h_sqrd > 0)
	return body.mass * (w_sqrd + h_sqrd) / 12
}

local_to_world :: proc(parent: Body, local: la.Vector2f32) -> (world: la.Vector2f32) {
	parent_pos := parent.position
	world.x = parent_pos.x + local.x * math.cos(parent.angle) - local.y * math.sin(parent.angle)
	world.y = parent_pos.y + local.x * math.sin(parent.angle) + local.y * math.cos(parent.angle)
	return
}

local_force_to_world :: proc(parent: Body, local: la.Vector2f32) -> (world: la.Vector2f32) {
	world.x = local.x * math.cos(parent.angle) - local.y * math.sin(parent.angle)
	world.y = local.x * math.sin(parent.angle) + local.y * math.cos(parent.angle)
	return
}

