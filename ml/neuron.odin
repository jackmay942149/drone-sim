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

neuron_forward :: proc(neuron: Neuron, input: []f32) -> f32 {
	assert(len(neuron.weights) == len(input))

	z := neuron.bias
	for i in 0 ..< len(neuron.weights) {
		z += (neuron.weights[i] * input[i])
	}

	switch neuron.strategy {
	case .ReLU:
		{
			return max(0, z)
		}
	case .Sigmoid:
		{
			return 1 / (1 + math.exp(-z))
		}
	case .Tanh:
		{
			return math.tanh(z)

		}
	}
	unreachable()
}

