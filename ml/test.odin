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

	// ReLU
	a := relu(z)
	testing.expectf(t, abs(a - 2.35) < float_error, "Expected: 2.35\nGot: %f", a)

	a = neuron_forward(neuron, inputs, .ReLU)
	testing.expectf(t, abs(a - 2.35) < float_error, "Expected: 2.35\nGot: %f", a)

	// Sigmoid
	a = sigmoid(z)
	testing.expectf(t, abs(a - 0.9129) < float_error, "Expected: 0.9129\nGot: %f", a)

	a = neuron_forward(neuron, inputs, .Sigmoid)
	testing.expectf(t, abs(a - 0.9129) < float_error, "Expected: 0.9129\nGot: %f", a)

	// Tanh
	a = tanh(z)
	testing.expectf(t, abs(a - 0.982) < float_error, "Expected: 0.982\nGot: %f", a)

	a = neuron_forward(neuron, inputs, .Tanh)
	testing.expectf(t, abs(a - 0.982) < float_error, "Expected: 0.982\nGot: %f", a)
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

@(test)
test_layer_construction :: proc(t: ^testing.T) {
	layer := layer_create(3, 5, .ReLU)
	defer layer_delete(layer)

	testing.expectf(t, len(layer.neurons) == 5, "Expected: 5\nGot: %v", layer.neurons)
	testing.expectf(t, len(layer.weights) == 15, "Expected: 15\nGot: %v", layer.weights)
	testing.expectf(t, len(layer.output) == 5, "Expected: 5\nGot: %v", layer.output)
	testing.expectf(t, layer.strategy == .ReLU, "Expected: ReLU\nGot: %v", layer.strategy)
	for n in layer.neurons {
		testing.expectf(t, len(n.weights) == 3, "Expected: 3\nGot: %v", len(n.weights))
	}
}

@(test)
test_forward_propagation :: proc(t: ^testing.T) {
	layer := layer_create(3, 5, .ReLU)
	defer layer_delete(layer)

	layer.neurons[0].bias = 0.5
	layer.neurons[1].bias = -1
	layer.neurons[2].bias = 0
	layer.neurons[3].bias = 0
	layer.neurons[4].bias = 0.1

	layer.neurons[0].weights[0] = 1
	layer.neurons[0].weights[1] = 0
	layer.neurons[0].weights[2] = 0

	layer.neurons[1].weights[0] = 0
	layer.neurons[1].weights[1] = 1
	layer.neurons[1].weights[2] = 0

	layer.neurons[2].weights[0] = 0
	layer.neurons[2].weights[1] = 0
	layer.neurons[2].weights[2] = 1

	layer.neurons[3].weights[0] = -1
	layer.neurons[3].weights[1] = 0
	layer.neurons[3].weights[2] = 0

	layer.neurons[4].weights[0] = 0.5
	layer.neurons[4].weights[1] = -0.25
	layer.neurons[4].weights[2] = 0.75

	input := []f32{1, 2, 3}
	layer_forward(layer, input)

	testing.expectf(
		t,
		abs(layer.output[0] - 1.5) < float_error,
		"Expected: 1.5\nGot: %v",
		layer.output[0],
	)

	testing.expectf(
		t,
		abs(layer.output[1] - 1) < float_error,
		"Expected: 1\nGot: %v",
		layer.output[1],
	)

	testing.expectf(
		t,
		abs(layer.output[2] - 3) < float_error,
		"Expected: 3\nGot: %v",
		layer.output[2],
	)

	testing.expectf(t, abs(layer.output[3]) < float_error, "Expected: 0\nGot: %v", layer.output[3])

	testing.expectf(
		t,
		abs(layer.output[4] - 2.35) < float_error,
		"Expected: 2.35\nGot: %v",
		layer.output[4],
	)
}

@(test)
test_layer_activation_strategy :: proc(t: ^testing.T) {
	layer := layer_create(3, 2, .ReLU)
	defer layer_delete(layer)

	layer.neurons[0].bias = 1
	layer.neurons[1].bias = -1
	input := []f32{1, 2, 3}

	z1 := weighted_sum(layer.neurons[0], input)
	z2 := weighted_sum(layer.neurons[1], input)
	testing.expectf(t, abs(z1 - 1) < float_error, "Expected: 1\nGot: %v", z1)
	testing.expectf(t, abs(z2 + 1) < float_error, "Expected: -1\nGot: %v", z2)

	layer_forward(layer, input)
	testing.expectf(
		t,
		abs(layer.output[0] - 1) < float_error,
		"Expected: 1\nGot: %v",
		layer.output[0],
	)
	testing.expectf(t, abs(layer.output[1]) < float_error, "Expected: 0\nGot: %v", layer.output[1])

	layer.strategy = .Sigmoid
	layer_forward(layer, input)
	testing.expectf(
		t,
		abs(layer.output[0] - 0.7311) < float_error,
		"Expected: 0.7311\nGot: %v",
		layer.output[0],
	)
	testing.expectf(
		t,
		abs(layer.output[1] - 0.2689) < float_error,
		"Expected: 0.2689\nGot: %v",
		layer.output[1],
	)

	layer.strategy = .Tanh
	layer_forward(layer, input)
	testing.expectf(
		t,
		abs(layer.output[0] - 0.7616) < float_error,
		"Expected: 0.7616\nGot: %v",
		layer.output[0],
	)
	testing.expectf(
		t,
		abs(layer.output[1] + 0.7616) < float_error,
		"Expected: -0.7616\nGot: %v",
		layer.output[1],
	)
}

@(test)
test_layer_weight_independence :: proc(t: ^testing.T) {
	layer := layer_create(3, 5, .ReLU, false, context.allocator)
	defer layer_delete(layer, context.allocator)

	layer.neurons[0].bias = 0.5
	layer.neurons[1].bias = -1
	layer.neurons[2].bias = 0
	layer.neurons[3].bias = 0
	layer.neurons[4].bias = 0.1

	layer.neurons[0].weights[0] = 1
	layer.neurons[0].weights[1] = 0
	layer.neurons[0].weights[2] = 0

	layer.neurons[1].weights[0] = 0
	layer.neurons[1].weights[1] = 1
	layer.neurons[1].weights[2] = 0

	layer.neurons[2].weights[0] = 0
	layer.neurons[2].weights[1] = 0
	layer.neurons[2].weights[2] = 1

	layer.neurons[3].weights[0] = -1
	layer.neurons[3].weights[1] = 0
	layer.neurons[3].weights[2] = 0

	layer.neurons[4].weights[0] = 0.5
	layer.neurons[4].weights[1] = -0.25
	layer.neurons[4].weights[2] = 0.75

	input := []f32{1, 2, 3}

	// Run forward propagation and record outputs
	layer_forward(layer, input)
	outputs := make([]f32, len(layer.output), context.temp_allocator)
	defer free_all(context.temp_allocator)
	copy_slice(outputs, layer.output)

	layer.neurons[0].weights[0] = 2
	layer_forward(layer, input)

	testing.expectf(t, abs(outputs[0] - 1.5) < float_error, "Expected: 1.5\nGot %v", outputs[0])
	testing.expectf(
		t,
		abs(layer.output[0] - 2.5) < float_error,
		"Expected: 2.5\nGot %v",
		layer.output[0],
	)

	testing.expectf(t, abs(outputs[1] - 1) < float_error, "Expected: 1\nGot %v", outputs[1])
	testing.expectf(
		t,
		abs(layer.output[1] - 1) < float_error,
		"Expected: 1\nGot %v",
		layer.output[1],
	)

	testing.expectf(t, abs(outputs[2] - 3) < float_error, "Expected: 3\nGot %v", outputs[2])
	testing.expectf(
		t,
		abs(layer.output[2] - 3) < float_error,
		"Expected: 3\nGot %v",
		layer.output[2],
	)

	testing.expectf(t, abs(outputs[3]) < float_error, "Expected: 0\nGot %v", outputs[3])
	testing.expectf(t, abs(layer.output[3]) < float_error, "Expected: 0\nGot %v", layer.output[3])

	testing.expectf(t, abs(outputs[4] - 2.35) < float_error, "Expected: 2.35\nGot %v", outputs[4])
	testing.expectf(
		t,
		abs(layer.output[4] - 2.35) < float_error,
		"Expected: 2.35\nGot %v",
		layer.output[4],
	)
}

@(test)
test_network_construction :: proc(t: ^testing.T) {
	network := network_create(3, 2, []int{5}, []Neuron_Activation_Strategy{.ReLU, .Sigmoid}, false)

	testing.expect_value(t, len(network.layers), 2)
	testing.expect_value(t, len(network.layers[0].neurons), 5)
	testing.expect_value(t, len(network.layers[0].weights), 15)
	testing.expect_value(t, len(network.layers[0].output), 5)
	testing.expect_value(t, network.layers[0].strategy, .ReLU)

	for neuron in network.layers[0].neurons {
		testing.expect_value(t, len(neuron.weights), 3)
	}

	testing.expect_value(t, len(network.layers[1].neurons), 2)
	testing.expect_value(t, len(network.layers[1].weights), 10)
	testing.expect_value(t, len(network.layers[1].output), 2)
	testing.expect_value(t, network.layers[1].strategy, .Sigmoid)

	for neuron in network.layers[1].neurons {
		testing.expect_value(t, len(neuron.weights), 5)
	}
	defer network_delete(network)
}

