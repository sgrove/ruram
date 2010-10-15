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
      begin
        $stderr = StringIO.new
        vm = VM.new Parser.new(Lexer.new).parse params[:code] + "\n"
        vm.execute
        reply = vm.registers.map do |pair|
          "#{pair[0]}\t#{pair[1]}"
        end.join "\n"
      rescue SystemExit
        $stderr.rewind
        reply = $stderr.read
      rescue => bang
        reply = "Error: #{bang.to_s}"
      ensure
        $stderr = STDERR
      end
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
end
