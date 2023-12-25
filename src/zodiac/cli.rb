module Zodiac
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
