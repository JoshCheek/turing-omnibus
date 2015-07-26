Neural Networks That Learn
==========================

AI mimicking the human learning process.

Model
-----

* Neural network
  ![neural network](http://www.rsipvision.com/wp-content/uploads/2015/04/Slide5.png)
  - layers of neurons, with each neuron from the previous layer sending input to each neuron in the current layer through a synapse
  - the values of the first layer are the program inputs
  - the values of the last layer are the program outputs
* Neuron
  - has a value between -1 and 1 (in our case, anyway)
  - calculates the output by summing its inputs and running them through a "sigmoidal" function
    like hyperbolic tangent: tanh x = sinh x / cosh x = (e^x + e^-x) / (e^x - e^-x)
  - purpose of the sigmoidal function: keep the input bounded, and allow the neuron to respond non-linearly
  - potential sigmoidal functions:
    * hyperbolic tangent
    * arc tangent
    * fermi function
* Synapses
  - the connection between two neurons
  - they include a weight which modifies the neuron's value

Learning
--------

The network learns when it adjusts the weights of its synapses.
This is done by training it using a method called "back propagation",
which walks backwards through the neural network,
adjusting weights according to the amount of error on the previous layer.


Problem: POLARNET
-----------------

Build the AI, train it to turn [cartesian coordinates into polar coordinates](http://www.mathsisfun.com/polar-cartesian-coordinates.html).

### Inputs:

* radius - always 1, because then we can translate any polar coordinates by multiplying its output x and y by the actual radius)
* angle  - uhm... this has to be between -1 and 1 (that is the domain of a neuron), so I guess:
  1. Mod the angle so it is between 0 and 2π
  2. Then subtract π so it is between -π and π
  3. Then divide by π so it is between -1 and 1

### Outputs:

* x value on the unit circle
* y value on the unit circle

B/c they are on the unit circle, they will always be between -1 and 1.
Then you can multiply them by the actual radius (the one we substituted as 1 in the input)
to get the actual x and actual y.

### Medial layers:

* Two layers of 15 synapses each (after 25,000 trainings, it should have an error rate approaching 1.5%)

```ruby
# http://www.mathsisfun.com/polar-cartesian-coordinates.html

# cartesian (12, 5) = polar (13, 22.6º) = polar (13, 0.395 radians)
x = 12.0                  # => 12.0
y = 5.0                   # => 5.0
r = Math.sqrt(x*x + y*y)  # => 13.0

radians = Math.atan2(y, x)          # => 0.3947911196997615
degrees = radians * 180 / Math::PI  # => 22.619864948040426

Math.cos(radians) * r  # => 12.0
Math.sin(radians) * r  # => 5.0


# cartesian (-12, -5) = polar (13, -157.4º) = polar (13, 202.6º)
x = -12.0                 # => -12.0
y = -5.0                  # => -5.0
r = Math.sqrt(x*x + y*y)  # => 13.0

radians = Math.atan2(y, x)          # => -2.746801533890032
degrees = radians * 180 / Math::PI  # => -157.38013505195957
Math.cos(radians) * r               # => -12.0
Math.sin(radians) * r               # => -4.999999999999999

radians += 2*Math::PI               # => 3.5363837732895544
degrees = radians * 180 / Math::PI  # => 202.61986494804043
Math.cos(radians) * r               # => -12.000000000000002
Math.sin(radians) * r               # => -4.9999999999999964


# Converting angles around a circle to our domain of -1..1, and seeing the appropriate x values
# by walking around it and looking at the x/y that come out.
def d(f)
  truncated = (f*100).to_i / 100.0
  ('%0.2f' % truncated).rjust(5, ' ')
end

0.step(2*Math::PI, Math::PI/4)
 .map { |angle|
   domain_units = (angle - Math::PI) / Math::PI
   "#{d angle} radians | #{d domain_units} domain units | (#{d Math.cos angle}, #{d Math.sin angle}) | #{d Math.tan angle}"
  }
# => [" 0.00 radians | -1.00 domain units | ( 1.00,  0.00) |  0.00",
#     " 0.78 radians | -0.75 domain units | ( 0.70,  0.70) |  0.99",
#     " 1.57 radians | -0.50 domain units | ( 0.00,  1.00) | 16331239353195368.00",
#     " 2.35 radians | -0.25 domain units | (-0.70,  0.70) | -1.00",
#     " 3.14 radians |  0.00 domain units | (-1.00,  0.00) |  0.00",
#     " 3.92 radians |  0.25 domain units | (-0.70, -0.70) |  0.99",
#     " 4.71 radians |  0.50 domain units | ( 0.00, -1.00) | 5443746451065123.00",
#     " 5.49 radians |  0.75 domain units | ( 0.70, -0.70) | -1.00",
#     " 6.28 radians |  1.00 domain units | ( 1.00,  0.00) |  0.00"]
```


Thoughts
--------

These are mostly critical, so I'll start with appreciation:
I've tried to understand neural networks several times,
and never walked away feeling like I understood it well enough to implement it.
Well, here I succeeded at implementing it!

* It was confusing how they used an example partway through that was different from the one
  they were describing. Not saying they need to take it out, but it would have been nice if it were better delimited.
* It was completely unclear how to map the cartesian coordinates to the inputs / polar
  coordinates to the outputs. In the end, I did it by translating the x/y to fall within the
  unit circle, by dividing them by the distance from the origin
  ...still haven't figured out what I'm going to do w/ the outputs yet
* The psuedocode is completely procedural, and uses undefined ideas / names,
  making it very difficult to make sense of
* The pseudocode for back propagation has a lot of comments,
  because the pseudocode itself is unreadable
* I'm pretty sure there is an error in the pseudocode for coordinate conversion,
  where it says `for j <- 1 to 3`, I can't think of any reason we would have a 3 here,
  it's probably supposed to be a 2, for the two input neurons.
* The equation for hyperbolic tangent was wrong on 243,
  the denominator should be `e^x + e^(-x)`, the book had a minus
* I find it very hard to read `synone` and `syntwo`, and map that to anything meaningful.
* I wish they would have provided sample inputs / outputs,
  that would have gone a really long way to making this easier to figure out.
* I wish they would have provided sample weights, so that I could test that my code worked
  by running it against those weights before trying to use it to generate my own.
* Okay, the algorithm halfway through uses 2 medial layers of 15 each, but then on page 247,
  they saiy we are "free to change the number of input neurons(3), output neurons (2), or
  medial neurons (n) to any number" ...I only have 1 input neuron,
  b/c the angle is the only thing that matters (or is there some way we're supposed to deal
  with the radius, which can be infinitely large?), and the psuedocode on 247 doesn't ever
  have `1 to 3`, so what the fuck?
* They never actually explain how to calculate the error.
  I swear I've read this chapter 10x now, it's not in there.
  I think it's supposed to be:

  > For each medial neuron, the back-propagation procedure forms the product
  > between each of the two error terms and their corresponding synapse values
  > for that particular medial neuron. It adds the two products together and
  > then, pretending that this was the output of the medial neuron in question,
  > computes the corresponding error-improving input by using the derivative of
  > the sigmoidal function, in this case, 1 - y^2"

  But there are so many things wrong with this:

  1. For one, it's in the middle of the section on some other dude's algorithm
     (or is that the algorithm we're supposed to be writing? see previous point).
  2. How am I supposed to get the error terms?
  3. Why does the derivative of the sigmoidal function lead to error reduction?
  4. This made it sound like there are multiple sigmoidal functions being used,
     so I had to go calculate the value several different ways, and then test
     it to see if it was the same (it is, apparently, code is below). But
     still, how much time was lost b/c I got confused about this, and then had
     to go calculate / research it before I realized they were the same?

     ```ruby
     E = Math::E

     def compute(x)
       [ Math.cosh(x) ** -2,
         (4 * E**(2*x)) / (E**(4*x) + 2*E**(2*x) + 1),
         1 - Math.tanh(x)**2
       ]
     end

     def same?(a, b)
       (a - b).abs < 0.0000001
     end

     [ *1000.times.map { rand },
       *1000.times.map { rand*10 - 5 },
     ].each do |x|
       sech_x_sq, annoying_fraction, one_minus_y_sq = compute x

       next if same?(sech_x_sq, annoying_fraction) && same?(sech_x_sq, one_minus_y_sq)
       puts "x:                                      #{x}"
       puts "sech_x_sq:                              #{sech_x_sq}"
       puts "annoying_fraction:                      #{annoying_fraction} #{}"
       puts "one_minus_y_sq:                         #{one_minus_y_sq}"
       puts "diff sech_x_sq,      annoying_fraction: #{(sech_x_sq      - annoying_fraction).abs}"
       puts "diff sech_x_sq,      one_minus_y_sq:    #{(sech_x_sq      - one_minus_y_sq).abs}"
       puts "diff one_minus_y_sq, annoying_fraction: #{(one_minus_y_sq - annoying_fraction).abs}"
       break
     end
     ```
