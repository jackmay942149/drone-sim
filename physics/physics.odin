package physics

tick :: 1.0 / 120.0

@(private)
gravity :: 9.81

update :: proc(body: ^Body, dt: f32) {
	assert(body != nil)
	assert(body.mass > 0)

	// Get acceleration newton's second law
	acceleration := body.net_force / body.mass
	body.net_force = {}

	// Get velocity semi-implicit Euler integration
	body.velocity += acceleration * dt
	body.position += body.velocity * dt

	angular_acceleration := body.net_torque / moment_of_inertia(body^)
	body.net_torque = 0

	body.angular_velocity += angular_acceleration * dt
	body.angle += body.angular_velocity * dt
}

