require 'bundler/setup'

require 'sinatra'

require 'lib/render_partial'

module Schulze
  class Application < Sinatra::Base
    set :haml, format: :html5

    get '/' do
      haml :index
    end
  end
end
