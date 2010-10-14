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
    haml <<eof
!!! 5
%html
  %head
    %title ruram
    %script{:type => "text/javascript",
      :src  => "http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.min.js"}
  %body{:style => "margin: 1em auto; width: 800px;"}
    %h1 ruram
    %div#left
      %h2 input
      %form
        %textarea#input{:cols => 20, :rows => 10}
          clr 0
        %br
        %input{:type => :button, :value => "Go", :onclick => "clicked();"}
    %div#right
      %h2 output
      %pre#output
      :javascript
        function clicked() {
          $('#output').load('/run', {code: $('#input').val()});
        }
eof
  end
end