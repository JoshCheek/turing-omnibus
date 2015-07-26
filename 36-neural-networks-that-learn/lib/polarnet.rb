module Polarnet
  extend self

  def generate_weights(neuron_counts, &generator)
    weights = neuron_counts.each_cons(2).with_index.map do |(from_count, to_count), offset|
      from_count.times.map do |from_index|
        to_count.times.map do |to_index|
          generator.call offset, from_index, to_index
        end
      end
    end

    iteration = {final: weights, sub_iterations: []}

    [iteration]
  end

  def generate_training_data(size)
    size.times.map { (2*rand) - 1 }
  end

  def to_inputs(radians)
    congruent_radians = radians % (2*Math::PI)
    congruent_radians / Math::PI - 1
  end

  def interpret_outputs(radius, (x, y))
    [x*radius, y*radius]
  end

  def to_cartesian(radius, radians)
    [ radius * Math.cos(radians),
      radius * Math.sin(radians),
    ]
  end

  def convert(neurons, weights, &sigmoidal)
    weights.each do |weights|
      neurons = weights.transpose.map do |recipient_weights|
        sigmoidal.call \
          neurons
            .zip(recipient_weights)
            .reduce(0) { |sum, (neuron, weight)| sum + neuron*weight }
      end
    end

    neurons
  end

end

__END__
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
inputs = [
  1,    # radius is always 1, b/c we're on the unit circle
  0.395 # the angle
]

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
