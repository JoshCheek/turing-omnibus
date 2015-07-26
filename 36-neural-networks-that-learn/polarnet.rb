# -----  synaptic weights  ------

num_inputs  = 2
num_neurons = 2
num_outputs = 2

# weights from input layer to medial layer
synone = Array.new num_inputs do
  Array.new(num_neurons) { 0.1 * rand }
end

# weights from medial layer to ouptut layer
syntwo = Array.new num_neurons do
  Array.new(num_outputs) { 0.1 * rand }
end


# -----  learning rate  -----

# how much to adjust weights while training (lower reduces the amount of adjustment)
rate = 0.1


# -----  convert  -----
inputs = [12.0, 5.0]

neurons = Array.new num_neurons do |neuron_index|
  weighted_sum = inputs.each_with_index.inject 0 do |sum, (input, input_index)|
    sum + (input * synone[input_index][neuron_index])
  end

  # http://ruby-doc.org/core-2.2.2/Math.html#method-c-tanh
  # a number between 0 and 1 (technically it's units are radians)
  Math.tanh weighted_sum
end

outputs = Array.new num_outputs do |output_index|
  weighted_sum = neurons.each_with_index.inject 0 do |sum, (input, neuron_index)|
    sum + (input * synone[neuron_index][output_index])
  end

  # http://ruby-doc.org/core-2.2.2/Math.html#method-c-tanh
  # a number between 0 and 1 (technically it's units are radians)
  Math.tanh weighted_sum
end

p inputs
p neurons
p outputs
