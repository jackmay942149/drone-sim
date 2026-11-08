package ml

@(private)
loss_mse :: proc(predicted, target: []f32) -> f32 {
	assert(len(predicted) == len(target))
	assert(len(predicted) != 0)

	total: f32
	for i in 0 ..< len(predicted) {
		diff := predicted[i] - target[i]
		total += (diff * diff)
	}

	return total / f32(len(predicted))
}

