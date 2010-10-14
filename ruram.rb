require 'lexer'
require 'parser'
require 'vm'

lex = Lexer.new
parser = Parser.new lex
instructions = parser.parse File.open(ARGV.first)
vm = VM.new instructions
vm.execute
vm.dump_registers
