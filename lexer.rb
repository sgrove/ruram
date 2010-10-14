require 'log'

class Lexer
  attr_reader :line

  def input=(input)
    @buffer = Buffer.new input
    @line = 1
  end

  def next_token
    c = next_nonwhitespace_char
    return :symbol, next_symbol(c) if c.is_symbol?
    case c
    when ':'
      :colon
    when ''
      :eof
    else
      Log.error "Illegal character on line #{@line}: '#{c}'"
    end
  end

  private

  def next_nonwhitespace_char
    loop do
      return '' if (c = @buffer.read_char).nil?
      @line += 1 if c == "\n"
      return c if not c.is_whitespace?
    end
  end

  def next_symbol(symbol)
    loop do
      c = @buffer.read_char
      if c.is_whitespace? or not (symbol + c).is_symbol?
        @buffer.unread_char c
        break
      end
      break if c.nil?
      symbol << c
    end
    symbol
  end
end

class Buffer
  BufferSize = 1024

  class EmptyFile
    def read(args)
    end
  end

  def initialize(input)
    if input.is_a? String
      @input = EmptyFile.new
      @buffer = input.chars.to_a
    else
      @input = input
      @buffer = []
    end
  end

  def read_char
    if @buffer.empty?
      return nil unless new_buffer = @input.read(BufferSize)
      @buffer = new_buffer.chars.to_a
    end
    @buffer.shift
  end

  def unread_char(c)
    @buffer.unshift c
  end
end

class String
  WHITESPACES = [' ', "\t", "\n"]

  SYMBOL_RE = /^[a-zA-Z0-9_\-]+$/

  def is_whitespace?
    WHITESPACES.include? self
  end

  def is_symbol?
    self =~ SYMBOL_RE
  end
end
