require 'sinatra'
require 'lexer'
require 'parser'
require 'vm'
require 'haml'
require 'stringio'

class WebApp < Sinatra::Base
  post '/run' do
    reply = nil
    t = Thread.new do
      reply = execute params[:code] + "\n"
    end
    if not t.join 5
      t.kill
      reply = 'Error: code execution time limit hit'
    end
    reply
  end

  get '/' do
    haml :root
  end

  def execute(code)
    reply = nil
    begin
      $stderr = StringIO.new
      vm = VM.new Parser.new(Lexer.new).parse code
      vm.execute
      reply = "REGISTERS\n"+
        vm.registers.map { |pair| "#{pair[0]}\t#{pair[1]}" }.join("\n") +
        "\n\nINSTRUCTIONS\n"+
        vm.instructions_count.sort { |x,y| y[1] <=> x[1] } .map do |pair|
          "#{pair[0]}\t#{pair[1]}"
        end.join("\n")
    rescue SystemExit
      $stderr.rewind
      reply = $stderr.read
    rescue => bang
      reply = "Error: #{bang.to_s}"
    ensure
      $stderr = STDERR
    end
    reply
  end
end
