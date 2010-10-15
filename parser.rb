require 'log'
require 'instruction'

# The grammar supported by the parser is following
#
#   <program>    ::= <instrs>
#   <instrs>     ::= <instr> <instrs>
#                  | epsilon
#   <instr>      ::= <labeldef> <code>
#   <labeldef>   ::= <label> ":"
#                  | epsilon
#   <code>       ::= "continue"
#                  | "del" <register>
#                  | "clr" <register>
#                  | "jmp" <label>
#                  | <op> <register>
#                  | <register> "mov" <register>
#                  | <register> <op> <label>
#   <register>   ::= <symbol>
#   <op>         ::= <symbol>
#   <label>      ::= <symbol>
class Parser
  # Attaches the lexer.
  def initialize(lexer)
    @lexer = lexer
  end

  # Passes the input file to the Lexer and parses it returning an array of
  # Instructions.
  def parse(input)
    @lexer.input = input
    @symbols = {}
    @constants = {}
    @strings = {}
    move
    instrs
  end

  private

  # Reports a syntax error when the given class isn't the type of the current
  # token. Otherwise calls Parser#move.
  def match(token)
    if @token == token
      move
    else
      syntax_error
    end
  end

  # Moves to the next token.
  def move
    @token, @value = @lexer.next_token
  end

  # Reports a syntax error.
  def syntax_error
    Log.error "Syntax error at line #{@lexer.line}, unexpected #{@token}" +
      (" '#{@value}'" if @value).to_s
  end

  # Parses instructions.
  def instrs
    instructions = []
    while @token != :eof
      instructions << instr
    end
    instructions
  end

  # Parses an instruction.
  def instr
    retval = code
    if @label
      retval = code
      retval.label = @label
      @label = nil
    end
    retval
  end

  # Parses a label definition
  def labeldef(value)
    match :colon
    @label = value
  end

  # Parses code. TODO: It's utterly horrible. Fix it.
  def code
    case @value
    when 'continue'
      cont
    when 'del'
      del
    when 'clr'
      clr
    when 'jmp'
      jmp
    else
      if @value =~ /^add(.)$/
        add $1
      else
        value = @value
        match :symbol
        if @token == :colon
          labeldef value
        elsif @value == 'mov'
          mov value
        elsif @value =~ /^jmp(.)/
          jmpx value, $1
        else
          syntax_error
        end
      end
    end
  end

  # Parses add instruction
  def add(value)
    match :symbol
    register = @value
    match :symbol
    Instruction.new :add, [value, register]
  end

  # Parses clr instruction
  def clr
    match :symbol
    register = @value
    match :symbol
    Instruction.new :clr, register
  end

  # Parses add instruction
  def jmpx(register, value)
    match :symbol
    label = @value
    match :symbol
    Instruction.new :cjmp, [register, value, label]
  end

  # Parses continue instruction
  def cont
    match :symbol
    Instruction.new :cont
  end

  # Parses del instruction
  def del
    match :symbol
    register = @value
    match :symbol
    Instruction.new :del, register
  end

  # Parses jmp instruction
  def jmp
    match :symbol
    label = @value
    match :symbol
    Instruction.new :jmp, label
  end

  # Parses mov instruction
  def mov(dest)
    match :symbol
    src = @value
    match :symbol
    Instruction.new :mov, [dest, src]
  end
end
