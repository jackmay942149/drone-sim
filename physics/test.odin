package physics

import "core:testing"

@(private = "file")
float_error :: 0.1

@(test)
test_torque :: proc(t: ^testing.T) {
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
		body.velocity,
	)
}

