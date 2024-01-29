require_relative "persistence/in_memory"

module Persistence
  class PersistenceError < StandardError; end

  module_function

  def in_memory
    InMemory
  end

  def file_based
    raise "Not Implemented"
  end
end