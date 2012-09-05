require 'rubygems'
require 'sinatra'
require 'json'

post '/' do
  begin
    push = JSON.parse(params[:payload])
    "ok"
  rescue
    "error"
  end
end

