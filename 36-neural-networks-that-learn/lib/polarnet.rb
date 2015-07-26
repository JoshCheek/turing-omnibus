module Polarnet
  extend self

  def generate_weights(neuron_counts, &generator)
    weights = neuron_counts.each_cons(2).with_index.map do |(from_count, to_count), offset|
      to_count.times.map do |to_index|
        from_count.times.map do |from_index|
          generator.call offset, from_index, to_index
        end
      end
    end

    iteration = {final: weights, sub_iterations: []}

    [iteration]
  end

  def generate_training_data(size)
    size.times.map do
      inputs  = [2 * rand - 1]
      radians = from_inputs(inputs)
      [ inputs, [Math.cos(radians), Math.sin(radians)] ]
    end
  end

  def from_inputs(inputs)
    (inputs.first + 1) * Math::PI
  end

  def to_inputs(radians)
    congruent_radians = radians % (2*Math::PI)
    input = congruent_radians / Math::PI - 1
    [input]
  end

  def interpret_outputs(radius, (x, y))
    [x*radius, y*radius]
  end

  def to_cartesian(radius, radians)
    [ radius * Math.cos(radians),
      radius * Math.sin(radians),
    ]
  end

  def convert(inputs, weight_layers, &activate)
    activate_neurons(inputs, weight_layers, &activate).last.map(&:last)
  end

  def activate_neurons(inputs, weight_layers, &activate)
    weight_layers.inject [inputs.map { |i| [i, i] }] do |activated, weights|
      activated << weights.map { |weights_by_input|
        weighted_sum = activated.last
                                .map { |sum, sigmoided| sigmoided }
                                .zip(weights_by_input)
                                .reduce(0) { |sum, (neuron, weight)| sum + neuron*weight }
        [weighted_sum, activate.call(weighted_sum)]
      }
    end
  end

  def train_all(weight_history:, training_data:, save_frequency:, on_save:, activation:, activation_slope:)
    saved   = []
    weights = weight_history[-1][:final]

    training_data.each_with_index do |(inputs, desired_outputs), index|
      will_save = (index % save_frequency == 0)
      new_weights, gradients, activations, errors =
        train_once(weights, inputs, desired_outputs, activation, activation_slope, will_save)

      if will_save
        saved << new_weights
        on_save.call index,
                     inputs,
                     desired_outputs,
                     weights,
                     new_weights,
                     gradients,
                     activations,
                     errors
      end
    end

    [*weight_history, {final: weights, sub_iterations: saved}]
  end

  def train_once(weight_layers, inputs, desired_outputs, activation, activation_slope, will_save)
    learning_rate   = 0.05
    activation_data = activate_neurons inputs, weight_layers, &activation

    (output_activations, _), *dependent_activations_and_indexes =
      activation_data.flat_map.with_index.to_a.reverse

    errors = []
    gradient_set = output_activations.zip(desired_outputs).map { |(weighted, activated), desired|
      error = desired - activated
      errors << error
      activation_slope.call(weighted) * error
    }

    gradient_sets = dependent_activations_and_indexes.inject([gradient_set]) { |sets, (activation_layer, layer_index)|
      weighted_gradients_per_output = weight_layers[layer_index]
                                        .zip(gradient_set)
                                        .map { |weights, gradient|
                                          weights.map { |weight| weight * gradient }
                                        }

      gradient_set = activation_layer.map.with_index do |(weighted, activated), in_index|
        activation_slope.call(weighted) *
          weighted_gradients_per_output.inject(0) { |sum, gradients| sum + gradients[in_index] }
      end

      sets << gradient_set
    }.reverse

    new_weights = weight_layers.map.with_index do |weight_layer, layer_index|
      neurons   = activation_data[layer_index].map { |weighted, activated| weighted }
      gradients = gradient_sets[layer_index.next]

      weight_layer.map.with_index do |weights_for_output, out_neuron|
        weights_for_output.map.with_index do |weight, in_neuron|
          weight + learning_rate * neurons[in_neuron] * gradients[out_neuron]
        end
      end
    end

    [new_weights, gradient_sets, activation_data, errors]
  end
end
