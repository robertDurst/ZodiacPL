# frozen_string_literal: true

module Zodiac
  # Character helper methods common to parsing within the Zodiac language compiler.
  module CharacterHelpers
    def string_start?(value)
      ['"', "'", '`'].include?(value)
    end

    def symbol?(value)
      '.:[]{}+-*/%&|^><@~$!?:'.include?(value)
    end

    def op_assign_symbol?(value)
      '+-*/%*|^><&|[]'.include?(value)
    end

    def double_symbol?(value)
      '*<>|&@:.'.include?(value)
    end

    def contains_equal_sign?(value)
      value.include?('=')
    end

    def alpha_num?(value)
      letter?(value) || number?(value) || underscore?(value)
    end

    def letter?(value)
      value.match?(/[a-zA-Z]/)
    end

    def number?(value)
      value.match?(/[0-9]/)
    end

    def underscore?(value)
      value.match?(/_/)
    end
  end
end
