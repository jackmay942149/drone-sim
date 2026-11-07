package ml

import "core:math"
import "core:math/rand"

@(private)
Layer :: struct {
	neurons:  []Neuron,
	strategy: Neuron_Activation_Strategy,
	output:   []f32,
	weights:  []f32,
}

layer_create :: proc(
	input_count: int,
	neuron_count: int,
	strategy: Neuron_Activation_Strategy,
	randomise := false,
	allocator := context.allocator,
	rng := context.random_generator,
) -> (
	layer: Layer,
) {
	layer.weights = make([]f32, input_count * neuron_count, allocator)
	layer.neurons = make([]Neuron, neuron_count, allocator)
	for i in 0 ..< neuron_count {
		layer.neurons[i].weights = layer.weights[i * input_count:i * input_count + input_count]
	}

	layer.strategy = strategy
	layer.output = make([]f32, neuron_count, allocator)

	if randomise {
		bound: f32

		switch strategy {
		case .ReLU:
			bound = math.sqrt(6.0 / f32(input_count))
		case .Sigmoid, .Tanh:
			bound = math.sqrt(6.0 / f32(input_count + neuron_count))
		}

		for &weight in layer.weights {
			weight = rand.float32_range(-bound, bound, rng)
		}
	}
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
	delete(layer.weights, allocator)
	delete(layer.neurons, allocator)
	delete(layer.output, allocator)
}

