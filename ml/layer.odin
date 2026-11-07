package ml

@(private = "file")
Layer :: struct {
	neurons:  []Neuron,
	strategy: Neuron_Activation_Strategy,
	output:   []f32,
}

layer_create :: proc(
	input_count: int,
	neuron_count: int,
	strategy: Neuron_Activation_Strategy,
	allocator := context.allocator,
) -> (
	layer: Layer,
) {
	weights := make([]f32, input_count * neuron_count, allocator)
	layer.neurons = make([]Neuron, neuron_count, allocator)
	for i in 0 ..< neuron_count {
		layer.neurons[i].weights = weights[i * input_count:i * input_count + input_count]
	}

	layer.strategy = strategy
	layer.output = make([]f32, input_count, allocator)
	return
}

layer_forward :: proc(layer: Layer, input: []f32) {
	assert(layer.neurons != nil)
	assert(layer.output != nil)

	for i in 0 ..< len(layer.output) {
		layer.output[i] = neuron_forward(layer.neurons[i], input, layer.strategy)
	}
	return
}

layer_delete :: proc(layer: Layer, allocator := context.allocator) {
	for i in 0 ..< len(layer.neurons) {
		delete(layer.neurons[i].weights, allocator)
	}
	delete(layer.neurons, allocator)
	delete(layer.output, allocator)

}

