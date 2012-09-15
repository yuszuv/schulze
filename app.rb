# encoding: utf-8

require 'bundler/setup'
require 'haml'
require 'sinatra/base'
Dir.glob('lib/*').each { |file| require "#{file}" }
require 'riak'

class Schulze < Sinatra::Base
  include Sinatra::RenderPartial
  include Sinatra::LinkHelpers
  include Sinatra::FormHelpers

  set :haml, format: :html5, encoding: "ascii-8bit"
  set :method_override, true

  before do
    @title = "Mathias Schule — freier Journalist"
  end

  def riak
    @@riak ||= Riak::Client.new
  end

  def articles
    results = ::Riak::MapReduce.new(riak).
      index('schulze','$bucket','schulze').
      map('function(v) { 
        try {
          data = JSON.parse(v.values[0].data);
          data.key = v.key;
          data.modified = v.values[0].metadata["X-Riak-Last-Modified"];
        } catch(err) {
          data = {};
        }
        return [data]; }', :keep => true).run
    results.select(&:present?).map do |hash|
      item = OpenStruct.new(hash)
      item.modified = Time.parse(item.modified)
      item
    end.sort{ |a,b| a.modified <=> b.modified }
  end

  get '/' do
    haml :index
  end
  
  get '/profil' do
    haml :profil
  end

  get '/admin/pressespiegel' do
    @articles = articles
    @edit_article = OpenStruct.new(riak.bucket('schulze').get(params[:key]).data.merge(key: params[:key]))
    haml :admin_pressespiegel
  end

  post '/admin/pressespiegel' do
    item = riak.bucket('schulze').get_or_new((params["article"] || {}).delete("key"))
    item.data = params['article']
    item.store
    redirect to('/admin/pressespiegel')
  end

  delete '/admin/pressespiegel' do
    riak.bucket('schulze').delete(params[:key]) if params[:key]
    redirect to('/admin/pressespiegel')
  end

  get '/presse' do
    @articles = articles
    haml :pressespiegel
  end

  get '/projekte' do
    haml :projekte
  end

  get '/leistungen' do
    haml :leistungen
  end

  get '/partner' do
    haml :partner
  end

  get '/kontakt' do
    haml :kontakt
  end

  get '/impressum' do
    haml :impressum
  end
end
