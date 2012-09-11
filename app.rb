require 'bundler/setup'

require 'sinatra'

module Schulze
  class Application < Sinatra::Base
    set :haml, format: :html5

    get '/' do
      haml :index
    end
  end
end
