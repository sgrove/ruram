class Instruction
  attr_reader :code, :args
  attr_accessor :label

  def initialize(code, args=[])
    @code = code
    @args = args
  end
end
