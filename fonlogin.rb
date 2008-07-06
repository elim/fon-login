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

require 'logger'
require 'rubygems'
require 'mechanize'
require 'pit'

class FonLogin
  def initialize(opts = {})
    @email = opts[:email]
    @agent  = WWW::Mechanize.new do |a|
      a.max_history      = 1
      a.user_agent_alias = 'Mac FireFox'
      a.log              = Logger.new(opts[:log_output])
      a.log.level        = opts[:log_level]
    end
    @config = Pit.get("fon.com", :require => {
	"username" => "your email in fon",
	"password" => "your password in fon",
      })
  end

  def run
    logout_and_login
  end

  private
  def fetch(uri)
    begin
      sleep 2 #wait
      @agent.get(uri)
    rescue Timeout::Error
      @agent.log.warn "caught Timeout::Error !"
      retry
    rescue WWW::Mechanize::ResponseCodeError => e
      case e.response_code
      when '502'
        @agent.log.warn "caught Net::HTTPBadGateway !"
        retry
      when '404'
        @agent.log.warn "caught Net::HTTPNotFound !"
      else
        @agent.log.warn "caught Excepcion !" + e.response_code
      end
    end
  end

  def logout_and_login
    page = fetch('https://www.fon.com/en/userzone/logout')
    login_form = page.forms.first
    login_form['login_email'] = @config['username']
    login_form['login_password'] =@config['password']
    require 'pp'
    result =  @agent.submit(login_form)
    puts result.root.to_html
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
      on('-v', '--verbose', 'verbose mode') do |arg|
        opts[:log_level] = Logger::INFO
      end

      on('-d', '--debug', 'debug mode') do |arg|
        opts[:log_level]  = Logger::DEBUG
      end
      parse!
    end
  end
  
  FonLogin.new(opts).run
end
