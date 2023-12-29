# frozen_string_literal: true

# Raw string character iterator for the Zodiac language compiler.
class StringCharacterIterator
  include ::Zodiac::CharacterHelpers

  def initialize(raw_string)
    @raw_string = raw_string
  end

  def not_finished?
    @raw_string.size.positive?
  end

  def iterate
    old_top = peek
    @raw_string = @raw_string[1..]

    old_top
  end

  def peek
    @raw_string[0]
  end

  def rest_includes?(value)
    @raw_string[1..].include?(value)
  end

  def current_word_includes?(_value)
    end_index = @raw_string.index(' ', 1) || @raw_string.size

    contains_equal_sign?(@raw_string[..end_index])
  end

  def char_until(value)
    @raw_string.index(value)
  end

  def op_assign_peek?
    equals_sign_is_close_enough = current_word_includes?('=') && (@raw_string.index('=') < 4)
    starts_with_op_assign_char = op_assign_symbol?(peek)

    equals_sign_is_close_enough && starts_with_op_assign_char
  end

  def take_until(condition, before: 0, after: 0)
    word = ''

    before.times { word += iterate }

    word += iterate while not_finished? && !condition.call(peek)

    after.times { word += iterate }

    word
  end

  def take_until_not(condition, before: 0, after: 0)
    word = ''

    before.times { word += iterate }

    word += iterate while not_finished? && condition.call(peek)

    after.times { word += iterate }

    word
  end
end
