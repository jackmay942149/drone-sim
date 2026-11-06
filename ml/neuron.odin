package ml

Neuron :: struct {
	weights: []f32,
	bias:    f32,
}

relu :: proc(neuron: Neuron, input: []f32) {
	assert(len(neuron.weights) == len(input))

	z := neuron.bias
	for i in 0 ..< len(neuron.weights) {
		z += (neuron.weights[i] * input[i])
	}
}

