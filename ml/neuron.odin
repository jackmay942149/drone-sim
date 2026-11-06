package ml

import "core:math"

Neuron :: struct {
	weights:  []f32,
	bias:     f32,
	strategy: Neuron_Activation_Strategy,
}

Neuron_Activation_Strategy :: enum {
	ReLU,
	Sigmoid,
	Tanh,
}

neuron_forward :: proc(neuron: Neuron, input: []f32) -> (z: f32) {
	assert(len(neuron.weights) == len(input))

	z = neuron.bias
	for i in 0 ..< len(neuron.weights) {
		z += (neuron.weights[i] * input[i])
	}
	return z
}

@(private)
relu :: proc(z: f32) -> (a: f32) {
	return max(0, z)
}

@(private)
sigmoid :: proc(z: f32) -> (a: f32) {
	return 1 / (1 + math.exp(-z))
}

@(private)
tanh :: proc(z: f32) -> (a: f32) {
	return math.tanh(z)}

