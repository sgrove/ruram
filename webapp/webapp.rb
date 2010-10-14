require 'sinatra'
require 'lexer'
require 'parser'
require 'vm'
require 'haml'

class WebApp < Sinatra::Base
  post '/run' do
    vm = VM.new Parser.new(Lexer.new).parse params[:code] + "\n"
    vm.execute
    vm.registers.map do |pair|
      "#{pair[0]}\t#{pair[1]}"
    end.join "\n"
  end

  get '/' do
    haml :root
  end
end
