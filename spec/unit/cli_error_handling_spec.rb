# frozen_string_literal: true

# rubocop:disable RSpec/SubjectStub, RSpec/NestedGroups
# These are disabled because we're testing error handling methods
# which requires stubbing exit and warn_with_fallback on the subject

require 'spec_helper'
require_relative '../../lib/pocket_knife/cli'

RSpec.describe PocketKnife::CLI do
  subject(:cli) { described_class.new(['ask', 'test query']) }

  context 'when handling errors' do
    describe '#warn_with_fallback' do
      it 'outputs error messages to stderr' do
        expect { cli.send(:warn_with_fallback, 'Error message', 'Suggestion 1', 'Suggestion 2') }
          .to output(/Error: Error message.*Suggestion 1.*Suggestion 2/m).to_stderr
      end

      it 'formats first message with Error prefix' do
        expect { cli.send(:warn_with_fallback, 'Main error') }
          .to output(/\nError: Main error/).to_stderr
      end

      it 'indents subsequent messages' do
        expect { cli.send(:warn_with_fallback, 'Error', 'Suggestion') }
          .to output(/  Suggestion/).to_stderr
      end
    end

    describe '#handle_llm_api_error' do
      before do
        allow(cli).to receive(:warn_with_fallback)
        allow(cli).to receive(:exit)
      end

      context 'with authentication errors' do
        it 'handles api key error' do
          error = StandardError.new('Invalid API key provided')

          expect(cli).to receive(:warn_with_fallback).with(
            'Authentication failed: Invalid or expired API key.',
            'Please verify your GEMINI_API_KEY is correct.',
            'Get a new key at: https://makersuite.google.com/app/apikey',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(1)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles authentication error' do
          error = StandardError.new('Authentication failed')

          expect(cli).to receive(:warn_with_fallback).with(
            'Authentication failed: Invalid or expired API key.',
            'Please verify your GEMINI_API_KEY is correct.',
            'Get a new key at: https://makersuite.google.com/app/apikey',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(1)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles unauthorized error' do
          error = StandardError.new('Unauthorized access')

          expect(cli).to receive(:warn_with_fallback).with(
            'Authentication failed: Invalid or expired API key.',
            'Please verify your GEMINI_API_KEY is correct.',
            'Get a new key at: https://makersuite.google.com/app/apikey',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(1)

          cli.send(:handle_llm_api_error, error)
        end
      end

      context 'with rate limit errors' do
        it 'handles rate limit error' do
          error = StandardError.new('Rate limit exceeded')

          expect(cli).to receive(:warn_with_fallback).with(
            'Rate limit exceeded: Too many requests to Gemini API.',
            'Please wait a moment and try again, or upgrade your API plan.',
            'For immediate results, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(2)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles quota error' do
          error = StandardError.new('Quota exceeded')

          expect(cli).to receive(:warn_with_fallback).with(
            'Rate limit exceeded: Too many requests to Gemini API.',
            'Please wait a moment and try again, or upgrade your API plan.',
            'For immediate results, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(2)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles resource exhausted error' do
          error = StandardError.new('Resource exhausted')

          expect(cli).to receive(:warn_with_fallback).with(
            'Rate limit exceeded: Too many requests to Gemini API.',
            'Please wait a moment and try again, or upgrade your API plan.',
            'For immediate results, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(2)

          cli.send(:handle_llm_api_error, error)
        end
      end

      context 'with model/configuration errors' do
        it 'handles unknown model error' do
          error = StandardError.new('Unknown model specified')

          expect(cli).to receive(:warn_with_fallback).with(
            'Configuration error: Invalid model or provider settings.',
            'Please check your RubyLLM configuration.',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>',
            '(Error: StandardError: Unknown model specified)'
          )
          expect(cli).to receive(:exit).with(1)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles model configuration error' do
          error = StandardError.new('Model configuration invalid')

          expect(cli).to receive(:warn_with_fallback).with(
            'Configuration error: Invalid model or provider settings.',
            'Please check your RubyLLM configuration.',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>',
            '(Error: StandardError: Model configuration invalid)'
          )
          expect(cli).to receive(:exit).with(1)

          cli.send(:handle_llm_api_error, error)
        end
      end

      context 'with generic errors' do
        it 'handles unexpected error' do
          error = StandardError.new('Unexpected failure')

          expect(cli).to receive(:warn_with_fallback).with(
            'LLM error: Unexpected failure',
            'An unexpected error occurred while processing your request.',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(2)

          cli.send(:handle_llm_api_error, error)
        end

        it 'handles error without message' do
          error = StandardError.new

          expect(cli).to receive(:warn_with_fallback).with(
            'LLM error: StandardError',
            'An unexpected error occurred while processing your request.',
            'For direct calculations, use: pocket-knife calc <amount> <percentage>'
          )
          expect(cli).to receive(:exit).with(2)

          cli.send(:handle_llm_api_error, error)
        end
      end
    end
  end
end
# rubocop:enable RSpec/SubjectStub, RSpec/NestedGroups
