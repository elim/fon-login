#!/usr/bin/env ruby
# -*- mode: ruby; coding: utf-8-unix; indent-tabs-mode: nil -*-
#
# Author::    Takeru Naito (mailto:takeru.naito@gmail.com)
# Copyright:: Copyright (c) 2008 Takeru Naito
# License::   Distributes under the same terms as Ruby
#
#
#== fon へログインします
#
#
#== 依存ライブラリ
#
#* mechanize
#* pit
#
#
#== 使用方法
#% ./fonlogin
#

require 'rubygems'
require 'mechanize'
require 'logger'

class FonLogin
  def initialize(opts = {})
    @email = opts[:email]
    @agent  = WWW::Mechanize.new do |a|
      a.max_history      = 1
      a.user_agent_alias = 'Mac FireFox'
      a.log              = Logger.new(opts[:log_output])
      a.log.level        = opts[:log_level]
    end
  end

  def run
    if @email
      try_logout
    else 
      STDERR.puts('Oops. Please. email.')
    end
  end
  
  private
  def fetch(uri)
    begin
      sleep 2 #wait
      @agent.get(uri)
    rescue Timeout::Error
      @agent.log.warn "  caught Timeout::Error !"
      retry
    rescue WWW::Mechanize::ResponseCodeError => e
      case e.response_code
      when "502"
        @agent.log.warn "  caught Net::HTTPBadGateway !"
        retry
      when "404"
        @agent.log.warn "  caught Net::HTTPNotFound !"
      else
        @agent.log.warn "  caught Excepcion !" + e.response_code
      end
    end
  end

  def try_logout
    
  end

end


if $0 == __FILE__
  require 'optparse'

  opts = {
    :target     => nil,
    :log_output => STDERR,
    :log_level  => Logger::WARN
  }

  OptionParser.new do |parser|
    parser.instance_eval do
      on('-e email', '--email=email', 'Registered e-mail address') do |arg|
        opts[:target] = arg
      end

      on('-p password', '--password=password', 'password') do |arg|
        opts[:log_level] = Logger::INFO
      end

      on('-v', '--verbose', 'verbose mode') do |arg|
        opts[:log_level] = Logger::INFO
      end

      on('-d', '--debug', 'debug mode') do |arg|
        opts[:log_level]  = Logger::DEBUG
      end
      parse!
    end
  end
  
  MuxTapeSnatcher.new(opts).run
end
