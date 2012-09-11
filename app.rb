require 'bundler/setup'

require 'sinatra'

module Schulze
  class Application < Sinatra::Base
    set :haml, format: :html5

    get '/' do
      'hello world!'
    end
  end
end
