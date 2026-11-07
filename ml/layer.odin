package ml

@(private = "file")
Layer :: struct {
	neurons:  []Neuron,
	stratgey: Neuron_Activation_Strategy,
	output:   []f32,
}

layer_create :: proc(
	count: int,
	strategy: Neuron_Activation_Strategy,
	allocator := context.allocator,
) -> (
	layer: Layer,
) {
	layer.neurons = make([]Neuron, count, allocator)
	layer.stratgey = strategy
	layer.output = make([]f32, count, allocator)
	return
}

layer_forward :: proc(layer: Layer, input: []f32) {
	assert(layer.neurons != nil)
	assert(layer.output != nil)

	for i in 0 ..< len(layer.output) {
		layer.output[i] = neuron_forward(layer.neurons[i], input, layer.stratgey)
	}
	return
}

layer_delete :: proc(layer: Layer, allocator := context.allocator) {
	delete(layer.neurons, allocator)
	delete(layer.output, allocator)
}

