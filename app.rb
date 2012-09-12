require 'bundler/setup'
require 'sinatra/base'
require 'lib/render_partial'

class Schulze < Sinatra::Base
  include Sinatra::RenderPartial

  set :haml, format: :html5

  get '/' do
    haml :index
  end
end
