package ml

Network :: struct {
	layers: []Layer,
}

network_create :: proc(
	inputs, outputs: int,
	hidden_layers: []int,
	strategies: []Neuron_Activation_Strategy,
	randomise := false,
	allocator := context.allocator,
) -> (
	network: Network,
) {
	assert(len(strategies) == len(hidden_layers) + 1)
	network.layers = make([]Layer, len(hidden_layers) + 1, allocator)

	input_count := inputs
	neuron_count: int
	for layer, i in network.layers {
		if i != len(hidden_layers) {
			neuron_count = hidden_layers[i]
		} else {
			neuron_count = outputs
		}

		// Create layer
		network.layers[i] = layer_create(
			input_count,
			neuron_count,
			strategies[i],
			randomise,
			allocator,
		)

		// Setup inputs for next loop
		input_count = neuron_count
	}
	return
}

network_set_bias :: proc(network: Network, layer_id, neuron_id: int, bias: f32) {
	assert(len(network.layers) > layer_id)
	assert(len(network.layers[layer_id].neurons) > neuron_id)
	network.layers[layer_id].neurons[neuron_id].bias = bias
}

network_set_weight :: proc(network: Network, layer_id, neuron_id, weight_id: int, weight: f32) {
	assert(len(network.layers) > layer_id)
	assert(len(network.layers[layer_id].neurons) > neuron_id)
	assert(len(network.layers[layer_id].neurons[neuron_id].weights) > weight_id)
	network.layers[layer_id].neurons[neuron_id].weights[weight_id] = weight
}

network_forward :: proc(network: Network, input: []f32) -> (output: []f32) {
	input := input
	for layer in network.layers {
		layer_forward(layer, input)
		output = layer.output
		input = output
	}
	return output
}

network_delete :: proc(network: Network, allocator := context.allocator) {
	for layer in network.layers {
		layer_delete(layer, allocator)
	}
	delete(network.layers, allocator)
}

