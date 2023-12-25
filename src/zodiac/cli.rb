# frozen_string_literal: true

module Zodiac
  # Command line interface for the Zodiac language.
  class CLI
    def initialize(args)
      return unless args.size

      @args = args
    end

    def compile?
      @args[0] == 'compile'
    end
  end
end
