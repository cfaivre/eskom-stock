# encoding: utf-8
require 'csv'
require 'haml'
#require 'iconv'
require 'sinatra'
require 'sinatra/flash'
require 'syslog'
require_relative 'minify_resources'
require_relative 'lib/authentication'
require_relative 'lib/user'


class StockApp < Sinatra::Application
  test_environment = (ENV['RACK_ENV'] == 'test')
  dev_environment = (ENV['RACK_ENV'] == 'development')

  TEN_MINUTES   = 60 * 10
  use Rack::Session::Pool, expire_after: TEN_MINUTES # Expire sessions after ten minutes of inactivity
  helpers Authentication

  use Rack::Session::Cookie, :key => 'project',
                             :path => '/',
                             :expire_after => 14400, # In seconds
                             :secret => 'project'

  set :session_secret, '90f7gsg*43%'
  register Sinatra::Flash

  disable :protection

  configure do
    set :sessions, true
    set :app_file, __FILE__
    enable :logging, :dump_errors
    set :raise_errors, true
  end

  configure :production, :staging do
    set :haml, { :ugly=>true }
    set :clean_trace, true
    set :css_files, :blob
    set :js_files,  :blob
  end

  configure :development, :test do
    set :css_files, MinifyResources::CSS_FILES
    set :js_files,  MinifyResources::JS_FILES
  end

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  error do
    content_type :json
    e = @env['sinatra.error']
    logger.debug e.message
    halt 500, { error: "Internal Server Error - #{e.message}"}.to_json
  end

  def audit_event    a = Audit.create(user: request.session['user_id'], controller: env["REQUEST_PATH"], json: "")
    a.upsert
  end
end

require_relative 'helpers/init'
require_relative 'models/init'
require_relative 'controllers/init'
require_relative 'view_models/init'
require_relative 'lib/init'
