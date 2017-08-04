require 'sinatra'
require 'sinatra/config_file'

config_file File.join(File.dirname(File.expand_path(__FILE__)), 'config.yml')

module Conf
  module_function
  def settings; Sinatra::Application.settings end
end

set :port, 8080
set :bind, '0.0.0.0'
