# frozen_string_literal: true

require './spec/spec_helper'
require './src/zodiac/parser'
require './src/zodiac/parse_error'

describe Zodiac::Parser do
  describe '.parse' do
    context 'when empty program' do
      it 'returns empty program' do
        parser = described_class.new('')

        actual = parser.parse
        expected = { kind: 'PROGRAM', cmp_stmts: [] }

        expect(actual).to eq(expected)
      end
    end
  end

  describe '.parse_term' do
    it 'parses newline' do
      parser = described_class.new("\n")

      actual = parser.parse_term
      expected = { kind: 'TERM', value: "\n" }

      expect(actual).to eq(expected)
    end

    it 'parses semicolon' do
      parser = described_class.new(';')

      actual = parser.parse_term
      expected = { kind: 'TERM', value: ';' }

      expect(actual).to eq(expected)
    end

    it 'raises error when not newline or semicolon' do
      expect do
        described_class.new('1').parse_term
      end.to raise_error(Zodiac::ParseError)
    end
  end

  describe '.parse_literal' do
    context 'when parse literal' do
      context 'when number' do
        it 'returns literal' do
          parser = described_class.new('1')

          actual = parser.parse_literal
          expected = {
            kind: 'LITERAL_NUMBER',
            value: 1
          }

          expect(actual).to eq(expected)
        end
      end

      context 'when decimal' do
        it 'returns literal' do
          parser = described_class.new('1.1')

          actual = parser.parse_literal
          expected = {
            kind: 'LITERAL_DECIMAL',
            value: 1.1
          }

          expect(actual).to eq(expected)
        end
      end

      context 'when string' do
        it 'returns literal' do
          parser = described_class.new('"hello"')

          actual = parser.parse_literal
          expected = {
            kind: 'LITERAL_STRING',
            value: 'hello'
          }

          expect(actual).to eq(expected)
        end
      end

      context 'when symbol' do
        it 'returns literal' do
          parser = described_class.new(':hello')

          actual = parser.parse_literal
          expected = {
            kind: 'LITERAL_SYMBOL',
            value: :hello
          }

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
