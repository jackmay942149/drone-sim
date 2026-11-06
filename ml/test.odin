package ml

import "core:testing"

@(private = "file")
float_error :: 0.001

@(test)
test_neuron_activation :: proc(t: ^testing.T) {
	inputs := []f32{1, 2, 3}
	weights := []f32{0.5, -0.25, 0.75}

	neuron := Neuron {
		weights = weights,
		bias    = 0.1,
	}

	z := weighted_sum(neuron, inputs[:])
	testing.expectf(t, abs(z - 2.35) < float_error, "Expected: 2.35\nGot: %f", z)

	a := relu(z)
	testing.expectf(t, abs(a - 2.35) < float_error, "Expected: 2.35\nGot: %f", a)
}

@(test)
test_negative_weighted_sum :: proc(t: ^testing.T) {
	z: f32 = -0.5
	a := relu(z)
	testing.expectf(t, a == 0, "Expected: 0\nGot: %f", a)
}

@(test)
test_zero_input_vector :: proc(t: ^testing.T) {
	inputs := []f32{}
	weights := []f32{}

	neuron := Neuron {
		weights = weights,
		bias    = 0.1,
	}

	z := weighted_sum(neuron, inputs)
	testing.expectf(t, abs(z - neuron.bias) < float_error, "Expected: %f\nGot: %f", neuron.bias, z)
}

@(test)
test_bias_expected_change :: proc(t: ^testing.T) {
	inputs := []f32{1, 2, 3}
	weights := []f32{0.5, -0.25, 0.75}

	neuron_1 := Neuron {
		weights = weights,
		bias    = 0.1,
	}
	neuron_2 := Neuron {
		weights = weights,
		bias    = 0.2,
	}

	z1 := weighted_sum(neuron_1, inputs)
	z2 := weighted_sum(neuron_2, inputs)

	testing.expectf(t, abs((z2 - z1) - 0.1) < float_error, "Expected: 0.1\nGot: %f", z2 - z1)
}

@(test)
test_invalid_input_vector :: proc(t: ^testing.T) {
	inputs := []f32{1, 2, 3, 4}
	weights := []f32{0.5, -0.25, 0.75}

	neuron := Neuron {
		weights = weights,
		bias    = 0.1,
	}

	testing.expect_assert(t, "len(neuron.weights) == len(input)")
	_ = neuron_forward(neuron, inputs, .ReLU)
}

