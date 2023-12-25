# frozen_string_literal: true

require './src/zodiac/character_helpers'

describe Zodiac::CharacterHelpers do
  include Zodiac::CharacterHelpers

  describe '.alpha_num?' do
    context 'when letter' do
      it 'returns true' do
        expect(alpha_num?('a')).to eq(true)
      end
    end

    context 'when number' do
      it 'returns true' do
        expect(alpha_num?('1')).to eq(true)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(alpha_num?(':')).to eq(false)
      end
    end
  end

  describe '.letter?' do
    context 'when letter' do
      it 'returns true' do
        expect(letter?('a')).to eq(true)
      end
    end

    context 'when number' do
      it 'returns false' do
        expect(letter?('1')).to eq(false)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(letter?(':')).to eq(false)
      end
    end
  end

  describe '.number?' do
    context 'when letter' do
      it 'returns false' do
        expect(number?('a')).to eq(false)
      end
    end

    context 'when number' do
      it 'returns true' do
        expect(number?('1')).to eq(true)
      end
    end

    context 'when symbol' do
      it 'returns false' do
        expect(number?(':')).to eq(false)
      end
    end
  end
end
