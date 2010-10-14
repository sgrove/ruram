require 'sinatra'
require 'lexer'
require 'parser'
require 'vm'
require 'haml'

class WebApp < Sinatra::Base
  post '/run' do
    reply = nil
    t = Thread.new do
      begin
        vm = VM.new Parser.new(Lexer.new).parse params[:code] + "\n"
        vm.execute
        reply = vm.registers.map do |pair|
          "#{pair[0]}\t#{pair[1]}"
        end.join "\n"
      rescue Object => bang
        reply = "ERROR: #{bang.to_s}"
      end
    end
    if not t.join 5
      t.kill
      reply = 'ERROR: code execution time limit hit'
    end
    reply
  end

  get '/' do
    haml :root
  end
end
