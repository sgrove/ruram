require 'lexer'
require 'parser'
require 'vm'
require 'pp'

lex = Lexer.new
parser = Parser.new lex
instructions = parser.parse File.open(ARGV.first)
vm = VM.new instructions
vm.execute
pp vm.registers
pp vm.instructions_count
