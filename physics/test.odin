package physics

import "core:testing"

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
		abs(body.angular_velocity - 6) < 0.1,
		"Expected: 6\nGot: %f\n",
		body.angular_velocity,
	)
}

