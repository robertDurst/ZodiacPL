# frozen_string_literal: true

require './src/zodiac/cli'

describe Zodiac::CLI do
  describe '#compile?' do
    context 'when passed compile run command' do
      it 'evaluates to true' do
        args = ['compile']
        expect(Zodiac::CLI.new(args).compile?).to be true
      end
    end
  end
end
