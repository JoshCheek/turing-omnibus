require 'polarnet'

RSpec.describe Polarnet do
  def pi
    Math::PI
  end

  describe '.generate_weights' do
    let(:weights) {
      Polarnet.generate_weights [1, 2, 3, 3] do |offset, from_index, to_index|
        offset + from_index + to_index
      end
    }

    it 'returns an array of weight iterations, with only the first filled in, each iteration contains the final weights, and the sub_iterations, which are empty for us' do
      expect(weights.length).to eq 1
      expect(weights[0].keys.sort).to eq [:final, :sub_iterations]
      expect(weights[0][:sub_iterations]).to eq []
    end

    specify 'the final weights are a mapping of input neurons to the output neurons, the value coming from the block' do
      expect(weights[0][:final]).to eq [
        # 1 to 2
        [ [[0+0+0, 0+0+1]],

        # 2 to 3
        ], [
          [[1+0+0, 1+0+1, 1+0+2]],
          [[1+1+0, 1+1+1, 1+1+2]],

        # 3 to 3
        ], [
          [[2+0+0, 2+0+1, 2+0+2]],
          [[2+1+0, 2+1+1, 2+1+2]],
          [[2+2+0, 2+2+1, 2+2+2]],
        ],
      ]
    end
  end


  describe '.generate_training_data' do
    it 'randomly generates the requested number of inputs, each input a number between -1 and 1' do
      data = Polarnet.generate_training_data 1000
      expect(data.length).to eq 1000         # quantity
      expect(data).to be_all { |n| n  <= 1 } # domain
      expect(data).to be_all { |n| -1 <= n } # domain
      expect(data.uniq.length).to be > 1     # random
    end
  end

  describe '.to_inputs' do
    it 'mods the angle so that it is within -pi to pi' do
      expected = Polarnet.to_inputs 0
      expect(Polarnet.to_inputs -2 * pi).to eq expected
      expect(Polarnet.to_inputs  0 * pi).to eq expected
      expect(Polarnet.to_inputs  2 * pi).to eq expected
    end

    it 'translates 0 to be -1, 2pi to 1, and other values linearlly therein' do
      expect(Polarnet.to_inputs 0.0 * pi).to eq -1.0
      expect(Polarnet.to_inputs 0.5 * pi).to eq -0.5
      expect(Polarnet.to_inputs 1.0 * pi).to eq  0.0
      expect(Polarnet.to_inputs 1.5 * pi).to eq  0.5
      expect(Polarnet.to_inputs 1.9 * pi).to be > 0.9
    end
  end


  describe 'interpret_outputs' do
    def interprets!(radius:, outputs:, x:, y:)
      actual_x, actual_y, *rest = Polarnet.interpret_outputs(radius, outputs)
      expect(rest).to eq []
      expect(actual_x).to eq x
      expect(actual_y).to eq y
    end

    it 'multiplies the outputs by the radius' do
      interprets! radius: 2,  outputs: [1  , 1],    x:  2,  y:  2
      interprets! radius: 2,  outputs: [-1 , -1],   x: -2,  y: -2
      interprets! radius: 10, outputs: [1  , -1],   x: -10, y: -10
      interprets! radius: 4,  outputs: [0.5, 0.25], x: 2,   y: 1
    end
  end


  describe 'to_cartesian' do
    it 'returns the x, y pair for the radius/angle (in radians)' do
      sqrt2 = Math.sqrt 2
      expect(Polarnet.to_cartesian 1, 0.00*pi).to eq [      1,      0 ]
      expect(Polarnet.to_cartesian 1, 0.25*pi).to eq [  sqrt2,  sqrt2 ]
      expect(Polarnet.to_cartesian 1, 0.50*pi).to eq [      0,      1 ]
      expect(Polarnet.to_cartesian 1, 0.75*pi).to eq [ -sqrt2,  sqrt2 ]
      expect(Polarnet.to_cartesian 1, 1.00*pi).to eq [     -1,      0 ]
      expect(Polarnet.to_cartesian 1, 1.25*pi).to eq [ -sqrt2, -sqrt2 ]
      expect(Polarnet.to_cartesian 1, 1.50*pi).to eq [      0,     -1 ]
      expect(Polarnet.to_cartesian 1, 1.75*pi).to eq [  sqrt2, -sqrt2 ]
      expect(Polarnet.to_cartesian 1, 2.00*pi).to eq [      1,      0 ]

      expect(Polarnet.to_cartesian 2, 0.00*pi).to eq [ 2, 0 ]
      expect(Polarnet.to_cartesian 3, 0.50*pi).to eq [ 0, 3 ]
    end
  end

  # outputs   = Polarnet.convert inputs, weights
  # post_data = Polarnet.train weights, data, save_frequency.to_i
  # errors    = Polarnet.errors_for angle, outputs
end
