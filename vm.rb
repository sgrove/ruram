# TODO: comment it up.
class VM
  KNOWN_INSTRUCTIONS = [:clr, :jmp, :cjmp, :mov, :clr, :del, :cont, :add]

  attr_reader :registers, :instructions_count

  def initialize(instructions)
    @labels = {}
    @registers = Registers.new
    @instructions_count = Counter.new
    @instructions = instructions
    @current_instr = 0
    instructions.each do |instr|
      @labels[instr.label] = @instructions.index instr
    end
  end

  def execute
    while @current_instr < @instructions.count
      step
      @current_instr += 1
    end
  end

  private

  def step
    if unknown_instruction?
      Log.error "Unexpected instruction code: #{current_instruction.code}"
    end
    @instructions_count[current_instruction.code] += 1
    send current_instruction.code, current_instruction.args
  end

  def unknown_instruction?
    not KNOWN_INSTRUCTIONS.include? current_instruction.code
  end

  def current_instruction
    @instructions[@current_instr]
  end

  def clr(reg)
    @registers[reg] = []
  end

  def add(args)
    @registers[args[1]].push args[0]
  end

  def cjmp(args)
    if @registers[args[0]].first == args[1]
      jmp args[2]
    end
  end

  def jmp(args)
    @current_instr = @labels[args] - 1
  end

  def del(args)
    @registers[args].shift
  end

  def cont(args)
    @current_instr = @instructions.count
  end

  def mov(args)
    @registers[args[0]] = @registers[args[1]].clone
  end
end

class Registers < Hash
  def [](x)
    return super(x) if self.include? x
    self[x] = []
  end
end

class Counter < Hash
  def [](x)
    super(x) or self[x] = 0
  end
end
