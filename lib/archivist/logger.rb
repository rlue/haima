# frozen_string_literal: true

require 'logger'
require 'singleton'

module Archivist
  class Logger
    include Singleton

    class << self
      attr_reader :stdout, :stderr

      def open
        @stdout = ::Logger.new($stdout)
        @stderr = ::Logger.new($stderr)

        Archivist::Config.verbose ? stdout.debug! : stdout.info!
        Archivist::Config.verbose ? stderr.warn!  : stderr.fatal!
      end

      %i[unknown fatal error warn].each do |m|
        define_method(m) { |*args| stderr.send(m, *args) }
      end

      %i[info debug].each do |m|
        define_method(m) { |*args| stdout.send(m, *args) }
      end
    end
  end
end