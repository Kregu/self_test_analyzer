# frozen_string_literal: true

require 'sinatra/base'
require "sinatra/reloader"

class SelfApp < Sinatra::Base
  set :root, File.dirname(__FILE__)
  configure :development do
    register Sinatra::Reloader
  end

  disable :show_exceptions

  get '/' do
    erb :index
  end

  post '/result' do
    self_test = params[:text]
    @reboot_cause = ''

    if params[:file]
      @file = params[:file][:tempfile]
      self_test = File.open(@file, &:read)
    end
    @internet_access = []
    self_test.split(/\n/).each do |line|
      if line.include?('SoC power status')
        @reboot_cause = line
      end
      if line.include?('InternetChecker: Internet access')
        @internet_access << line
      end
    end

    @model = self_test.match(%r{<hwid>(.*?)</hwid>})
    @serial = self_test.match(%r{<serial>(.*?)</serial>})
    @servicetag = self_test.match(%r{<servicetag>(.*?)</servicetag>})
    @mac = self_test.match(%r{<mac>(.*?)</mac>})
    @release = self_test.match(%r{<release>(.*?)</release>})

    erb :result

  end
end
