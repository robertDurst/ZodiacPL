# frozen_string_literal: true

require './src/zodiac/parser'

describe Zodiac::Parser do
  describe '#parse' do
    context 'when empty input' do
      it 'returns an empty array of tokens' do
        input = ''
        parser = Zodiac::Parser.new(input)

        expected_output = []

        expect(parser.parse).to eq(expected_output)
      end
    end

    context 'when happy path' do
      context 'when symbol' do
        it 'parses symbols' do
          input = ":[]{}\"\"\'\'"
          parser = Zodiac::Parser.new(input)

          expected_output = [':', '[', ']', '{', '}', '"', '"', "'", "'"]

          expect(parser.parse).to eq(expected_output)
        end
      end

      context 'when word' do
        it 'fetchs whole word' do
          input = 'hello WorLD c4k3'
          parser = Zodiac::Parser.new(input)

          expected_output = %w[hello WorLD c4k3]

          expect(parser.parse).to eq(expected_output)
        end
      end
    end

    context 'when unexpected symbol' do
    end
  end
end
