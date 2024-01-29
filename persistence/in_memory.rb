require 'singleton'

module Persistence
  class InMemory
    include Singleton

    class << self
      def get(*)
        instance.get(*)
      end

      def set!(*)
        instance.set!(*)
      end
    end

    def initialize
      @storage = {}
    end

    def get(key)
      storage[key]
    end

    def set!(key, value)
      @storage[key] = value
    end

    private

    attr_reader :storage
  end
end

