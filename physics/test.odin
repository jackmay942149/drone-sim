package physics

import "core:math"
import "core:testing"

@(private = "file")
float_error :: 0.001

@(test)
test_angular_velocity :: proc(t: ^testing.T) {
	body := Body {
		mass = 1,
		size = {1, 1},
	}

	for i in 0 ..< 120 {
		add_torque(&body, 1)
		update(&body, 1.0 / 120.0)
	}

	testing.expectf(
		t,
		abs(body.angular_velocity - 6) < float_error,
		"Expected: 6\nGot: %f\n",
		body.angular_velocity,
	)
}

@(test)
test_linear_velocity :: proc(t: ^testing.T) {
	body := Body {
		mass = 2,
		size = {1, 1},
	}

	for i in 0 ..< 120 {
		add_force(&body, {10, 0})
		update(&body, 1.0 / 120.0)
	}

	testing.expectf(
		t,
		abs(body.velocity.x - 5) < float_error,
		"Expected: 5\nGot: %f",
		body.velocity.x,
	)
}

@(test)
test_gravity :: proc(t: ^testing.T) {
	body_2kg := Body {
		mass = 2,
		size = {1, 1},
	}
	body_10kg := Body {
		mass = 10,
		size = {1, 1},
	}

	for i in 0 ..< 120 {
		add_gravity(&body_2kg)
		add_gravity(&body_10kg)
		update(&body_2kg, 1.0 / 120.0)
		update(&body_10kg, 1.0 / 120.0)
	}

	testing.expectf(
		t,
		abs(-body_2kg.velocity.y - gravity) < float_error,
		"Expected: %f\nGot: %f",
		gravity,
		body_2kg.velocity.y,
	)

	testing.expectf(
		t,
		abs(-body_10kg.velocity.y - gravity) < float_error,
		"Expected: %f\nGot: %f",
		gravity,
		body_10kg.velocity.y,
	)

}

@(test)
test_force_accumulation :: proc(t: ^testing.T) {
	body := Body {
		mass = 1,
		size = {1, 1},
	}

	add_force(&body, {10, 0})
	add_force(&body, {-4, 3})

	testing.expectf(
		t,
		abs(body.net_force.x - 6) < float_error,
		"Expected: 6\nGot: %f",
		body.net_force.x,
	)

	testing.expectf(
		t,
		abs(body.net_force.y - 3) < float_error,
		"Expected: 3\nGot: %f",
		body.net_force.y,
	)
}

@(test)
test_torque_from_offcentre_force :: proc(t: ^testing.T) {
	body := Body {
		mass     = 1,
		size     = {1, 1},
		position = {0, 0},
	}
	add_force_at_point(&body, {0, 10}, {0.5, 0})

	testing.expectf(
		t,
		abs(body.net_torque - 5) < float_error,
		"Expected: 5\nGot: %f",
		body.net_torque,
	)

	update(&body, 0)
	add_force_at_point(&body, {0, 10}, {-0.5, 0})

	testing.expectf(
		t,
		abs(body.net_torque + 5) < float_error,
		"Expected: 5\nGot: %f",
		body.net_torque,
	)
}

@(test)
test_balanced_force :: proc(t: ^testing.T) {
	body := Body {
		mass = 1,
		size = {1, 1},
	}
	add_force_at_point(&body, {0, 10}, {-0.5, 0})
	add_force_at_point(&body, {0, 10}, {0.5, 0})

	testing.expectf(t, abs(body.net_torque) < float_error, "Expected: 0\nGot: %f", body.net_torque)

	testing.expectf(
		t,
		abs(body.net_force.x) < float_error,
		"Expected: 0\nGot: %f",
		body.net_force.x,
	)

	testing.expectf(
		t,
		abs(body.net_force.y - 20) < float_error,
		"Expected: 20\nGot: %f",
		body.net_force.y,
	)
}

@(test)
test_local_to__world_transformation :: proc(t: ^testing.T) {
	body := Body {
		mass  = 1,
		size  = {1, 1},
		angle = math.PI / 2,
	}
	world := local_force_to_world(body, {0, 10})

	testing.expectf(t, abs(world.x + 10) < float_error, "Expected: -10\nGot: %f", world.x)
	testing.expectf(t, abs(world.y) < float_error, "Expected: 0\nGot: %f", world.y)
}

@(test)
test_force_and_torque_clearing :: proc(t: ^testing.T) {
	body := Body {
		mass = 1,
		size = {1, 1},
	}
	add_force(&body, {1, 1})
	add_torque(&body, 1)

	update(&body, 1)

	initial_velocity := body.velocity
	initial_angular_velocity := body.angular_velocity

	update(&body, 1)

	testing.expectf(
		t,
		abs(body.velocity.x - initial_velocity.x) < float_error,
		"Expected: %f\nGot: %f",
		initial_velocity,
		body.velocity.x,
	)
	testing.expectf(
		t,
		abs(body.velocity.y - initial_velocity.y) < float_error,
		"Expected: %f\nGot: %f",
		initial_velocity,
		body.velocity.y,
	)
	testing.expectf(
		t,
		abs(body.angular_velocity - initial_angular_velocity) < float_error,
		"Expected: %f\nGot: %f",
		initial_angular_velocity,
		body.angular_velocity,
	)
}

@(test)
test_conservation_of_motion :: proc(t: ^testing.T) {
	body := Body {
		mass             = 1,
		size             = {1, 1},
		velocity         = {1, 1},
		angular_velocity = 1,
	}

	for _ in 0 ..< 120 {
		update(&body, 1.0 / 120.0)
		testing.expectf(
			t,
			abs(body.angular_velocity - 1) < float_error,
			"Expected: 1\nGot: %f",
			body.angular_velocity,
		)

		testing.expectf(
			t,
			abs(body.velocity.x - 1) < float_error,
			"Expected: 1\nGot: %f",
			body.velocity.x,
		)

		testing.expectf(
			t,
			abs(body.velocity.y - 1) < float_error,
			"Expected: 1\nGot: %f",
			body.velocity.y,
		)

	}
}

