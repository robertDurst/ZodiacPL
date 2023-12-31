# frozen_string_literal: true

require './spec/spec_helper'
require './src/zodiac/character_helpers'

describe Zodiac::CharacterHelpers do
  include described_class

  describe '.symbol?' do
    context 'when symbol' do
      it 'returns true' do
        expect(symbol?('.')).to be(true)
      end
    end

    context 'when not symbol' do
      it 'returns false' do
        expect(symbol?('a')).to be(false)
      end
    end
  end

  describe '.string_start?' do
    context 'when string start' do
      it 'returns true' do
        expect(string_start?('"')).to be(true)
      end
    end

    context 'when not string start' do
      it 'returns false' do
        expect(string_start?('a')).to be(false)
      end
    end
  end

  describe '.double_symbol?' do
    context 'when double symbol' do
      it 'returns true' do
        expect(double_symbol?('*')).to be(true)
      end
    end

    context 'when not double symbol' do
      it 'returns false' do
        expect(double_symbol?('-')).to be(false)
      end
    end
  end

  describe '.alpha_num?' do
    context 'when letter' do
      it 'returns true' do
        expect(alpha_num?('a')).to be(true)
      end
    end

    context 'when number' do
      it 'returns true' do
        expect(alpha_num?('1')).to be(true)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(alpha_num?(':')).to be(false)
      end
    end
  end

  describe '.contains_equal_sign?' do
    context 'when contains equal sign' do
      it 'returns true' do
        expect(contains_equal_sign?('a=b')).to be(true)
      end
    end

    context 'when does not contain equal sign' do
      it 'returns false' do
        expect(contains_equal_sign?('a')).to be(false)
      end
    end
  end

  describe '.letter?' do
    context 'when letter' do
      it 'returns true' do
        expect(letter?('a')).to be(true)
      end
    end

    context 'when number' do
      it 'returns false' do
        expect(letter?('1')).to be(false)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(letter?(':')).to be(false)
      end
    end
  end

  describe '.number?' do
    context 'when letter' do
      it 'returns false' do
        expect(number?('a')).to be(false)
      end
    end

    context 'when number' do
      it 'returns true' do
        expect(number?('1')).to be(true)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(number?(':')).to be(false)
      end
    end
  end

  describe '.underscore?' do
    context 'when underscore' do
      it 'returns true' do
        expect(underscore?('_')).to be(true)
      end
    end

    context 'when not underscore' do
      it 'returns false' do
        expect(underscore?('a')).to be(false)
      end
    end
  end
end
