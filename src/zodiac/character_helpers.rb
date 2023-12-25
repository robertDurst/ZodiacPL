# frozen_string_literal: true

module Zodiac
  # Character helper methods common to parsing within the Zodiac language compiler.
  module CharacterHelpers
    def symbol?(value)
      ".:[]{}\"'".include?(value)
    end

    def alpha_num?(value)
      letter?(value) || number?(value)
    end

    def letter?(value)
      value.match?(/[a-zA-Z]/)
    end

    def number?(value)
      value.match?(/[0-9]/)
    end
  end
end
