# encoding: utf-8

require 'bundler/setup'
require 'sinatra/base'
require 'lib/render_partial'
require 'lib/link_helpers'

class Schulze < Sinatra::Base
  include Sinatra::RenderPartial
  include Sinatra::LinkHelpers

  set :haml, format: :html5

  before do
    @title = "Mathias Schule — freier Journalist"
  end

  get '/' do
    haml :index
  end
  
  get '/profil' do
    haml :profil
  end
end
