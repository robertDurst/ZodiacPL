# frozen_string_literal: true

require './spec/spec_helper'
require './src/zodiac/lexer'

describe Zodiac::Lexer do
  describe '#lex' do
    context 'when empty input' do
      it 'returns an empty array of tokens' do
        input = ''
        lexer = described_class.new(input)

        expected_output = []

        expect(lexer.lex).to eq(expected_output)
      end
    end

    context 'when invalid input' do
      context 'when fails to lex a string' do
        it 'raises an error' do
          input = '"hello world'
          lexer = described_class.new(input)
          expect { lexer.lex }.to raise_error(Zodiac::LexError)
        end
      end
    end

    context 'when happy path' do
      it 'lexs symbols' do
        input = ':[ ]{}@~$!?:='
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'SYMBOL', value: ':' },
          { kind: 'SYMBOL', value: '[' },
          { kind: 'SYMBOL', value: ']' },
          { kind: 'SYMBOL', value: '{' },
          { kind: 'SYMBOL', value: '}' },
          { kind: 'SYMBOL', value: '@' },
          { kind: 'SYMBOL', value: '~' },
          { kind: 'SYMBOL', value: '$' },
          { kind: 'SYMBOL', value: '!' },
          { kind: 'SYMBOL', value: '?' },
          { kind: 'SYMBOL', value: ':' },
          { kind: 'SYMBOL', value: '=' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'lexs whole words' do
        input = 'hello WorLD c4k3 _r3d_foo'
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'IDENTIFIER', value: 'hello' },
          { kind: 'IDENTIFIER', value: 'WorLD' },
          { kind: 'IDENTIFIER', value: 'c4k3' },
          { kind: 'IDENTIFIER', value: '_r3d_foo' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'splits words on symbols' do
        input = 'hello:world'
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'IDENTIFIER', value: 'hello' },
          { kind: 'SYMBOL', value: ':' },
          { kind: 'IDENTIFIER', value: 'world' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'lexs operators' do
        input = '+ - * / % ** & | ^ << >> && ||   @@::..== === =~ +@ -@ [] <=>'
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'SYMBOL', value: '+' },
          { kind: 'SYMBOL', value: '-' },
          { kind: 'SYMBOL', value: '*' },
          { kind: 'SYMBOL', value: '/' },
          { kind: 'SYMBOL', value: '%' },
          { kind: 'SYMBOL', value: '**' },
          { kind: 'SYMBOL', value: '&' },
          { kind: 'SYMBOL', value: '|' },
          { kind: 'SYMBOL', value: '^' },
          { kind: 'SYMBOL', value: '<<' },
          { kind: 'SYMBOL', value: '>>' },
          { kind: 'SYMBOL', value: '&&' },
          { kind: 'SYMBOL', value: '||' },
          { kind: 'SYMBOL', value: '@@' },
          { kind: 'SYMBOL', value: '::' },
          { kind: 'SYMBOL', value: '..' },
          { kind: 'SYMBOL', value: '==' },
          { kind: 'SYMBOL', value: '===' },
          { kind: 'SYMBOL', value: '=~' },
          { kind: 'SYMBOL', value: '+@' },
          { kind: 'SYMBOL', value: '-@' },
          { kind: 'SYMBOL', value: '[]' },
          { kind: 'SYMBOL', value: '<=>' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'lexs operators with assignment' do
        input = '+= -= *= /= %= **= &= |= ^= <<= >>= &&= ||= []= >= <='
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'OP_ASGN', value: '+=' },
          { kind: 'OP_ASGN', value: '-=' },
          { kind: 'OP_ASGN', value: '*=' },
          { kind: 'OP_ASGN', value: '/=' },
          { kind: 'OP_ASGN', value: '%=' },
          { kind: 'OP_ASGN', value: '**=' },
          { kind: 'OP_ASGN', value: '&=' },
          { kind: 'OP_ASGN', value: '|=' },
          { kind: 'OP_ASGN', value: '^=' },
          { kind: 'OP_ASGN', value: '<<=' },
          { kind: 'OP_ASGN', value: '>>=' },
          { kind: 'OP_ASGN', value: '&&=' },
          { kind: 'OP_ASGN', value: '||=' },
          { kind: 'OP_ASGN', value: '[]=' },
          { kind: 'OP_ASGN', value: '>=' },
          { kind: 'OP_ASGN', value: '<=' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'lexs strings' do
        input = '"hello world" \'hello world\' `hello world`'
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'STRING', value: '"hello world"' },
          { kind: 'STRING', value: "'hello world'" },
          { kind: 'STRING', value: '`hello world`' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end

      it 'lexs numbers' do
        input = '123 123.456'
        lexer = described_class.new(input)

        expected_output = [
          { kind: 'NUMBER', value: '123' },
          { kind: 'NUMBER', value: '123.456' }
        ]

        expect(lexer.lex).to eq(expected_output)
      end
    end
  end
end
