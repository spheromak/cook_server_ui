#!/usr/bin/env ruby
#
# Whee
#

require "sinatra/base"
require "ridley"
require "pp"
require "json"

module Cook
  class Server < Sinatra::Base
    @@connections = Hash.new


    def config_file
      JSON.parse IO.read "#{ENV['HOME']}/.cook_servers.json"
    end

    def servers
      config_file['servers']
    end

    def connections
      @@connections
    end

    def connect
      unless connections.has_key? @server
        Celluloid.boot
        ridley = Ridley.new( servers[@server].merge( ssl: { verify: false } ))
        ridley.logger.level = 4
        return ridley
      end
    end

    get "/" do
      erb :home
    end

    get "/servers" do
      erb :servers
    end

    get "/cookbooks" do
      erb :cookbooks
    end

    get %r{^/v1/servers/(.*)$} do

    end

    get %r{^/servers/(.*)$} do
      @server = params[:captures].first
      erb :server_detail
    end

    #
    # this should just set somthing if the key is v1/ and all methods should push out json
    get %r{^/v1/cooks/(.*)$} do
      content_type :json
      @server =  params[:captures].first
      conn = connect
      conn.cookbook.all.to_json
    end

    get %r{^/cooks/(.*)$} do
      @server =  params[:captures].first
      conn = connect
      @cookbooks = conn.cookbook.all
      erb :cooks
    end

  end
end
