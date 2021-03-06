# encoding: utf-8

require 'bundler/setup'
require 'haml'
require 'sinatra/base'
Dir.glob('lib/*').each { |file| require "#{file}" }
require 'riak'
require 'digest/sha1'
require 'fileutils'

class Schulze < Sinatra::Base
  include Sinatra::RenderPartial
  include Sinatra::LinkHelpers
  include Sinatra::FormHelpers

  set :haml, format: :html5, encoding: "ascii-8bit"
  set :method_override, true

  enable :sessions

  if development?
    set session_secret: "supersecret"
  end

  before do
    @title = "Mathias Schulze — freier Journalist"
  end

  before '/admin/*' do
    redirect to('/login') unless session[:logged_in] == "true"
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
    end.sort do |a,b| 
      t1 = Time.parse(b.date).to_i rescue 0
      t2 = Time.parse(a.date).to_i rescue 0
      t1 <=> t2
    end
  end

  get '/' do
    haml :index
  end
  
  get '/profil' do
    haml :profil
  end

  get '/admin' do
    redirect to('/admin/pressespiegel')
  end

  get '/admin/pressespiegel' do
    @articles = articles
    @edit_article = OpenStruct.new(riak.bucket('schulze').get(params[:key]).data.merge(key: (params[:key].present? ? params[:key] : Time.now.to_i)))
    haml :admin_pressespiegel
  end

  post '/admin/pressespiegel' do
    item = riak.bucket('schulze').get_or_new((params["article"] || {}).delete("key"))
    if params['article'].present?
      if params['article']['file'].present?
        file_params = params['article'].delete('file')
        filename = file_params[:filename]
        FileUtils.mkdir_p 'public/uploads'
        FileUtils.cp file_params[:tempfile].path, File.join("public/uploads", filename)
        params['article']['filename'] = file_params[:filename]
      end
      item.data = params['article']
    end
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

  get '/service' do
    haml :service
  end

  get '/preise' do
    haml :preise
  end

  get '/kontakt' do
    haml :kontakt
  end

  get '/impressum' do
    haml :impressum
  end

  get '/login' do
    redirect to('admin/pressespiegel') if session[:logged_in] == "true"
    haml :login
  end

  post '/login' do
    if Digest::SHA1.hexdigest(params[:password]) == "0bf56c85644de843404becc3f03b89ee63d29ef4"
      session[:logged_in] = "true"
      redirect to('/admin/pressespiegel')
    else
      redirect to('/login')
    end
  end

  get '/logout' do
    session[:logged_in] = nil
    redirect to('/')
  end
end
