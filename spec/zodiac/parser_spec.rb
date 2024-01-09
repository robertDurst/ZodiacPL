# frozen_string_literal: true

require './spec/spec_helper'
require './src/zodiac/parser'

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

    context 'when simple expression' do
      xit 'returns simple expression' do
        parser = described_class.new('1 + 2')

        actual = parser.parse
        expected = {
          kind: 'PROGRAM',
          cmp_stmts: []
        }

        expect(actual).to eq(expected)
      end
    end
  end

  describe '.parse_literal' do
    context 'when parse literal' do
      context 'when number' do
        it 'returns literal' do
          parser = described_class.new('1')

          actual = parser.parse_literal
          expected = {
            kind: 'LITERAL',
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
            kind: 'LITERAL',
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
            kind: 'LITERAL',
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
            kind: 'LITERAL',
            value: :hello
          }

          expect(actual).to eq(expected)
        end
      end
    end
  end
end
