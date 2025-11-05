# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/pocket_knife/llm_config'

RSpec.describe PocketKnife::LLMConfig do
  describe '.llm_available?' do
    context 'when ruby_llm gem is available' do
      it 'returns true' do
        expect(described_class.llm_available?).to be true
      end
    end

    context 'when ruby_llm gem is not available' do
      it 'returns false' do
        allow(described_class).to receive(:require).with('ruby_llm').and_raise(LoadError)
        expect(described_class.llm_available?).to be false
      end
    end
  end

  describe '.configured?' do
    context 'when GEMINI_API_KEY is set' do
      it 'returns true' do
        ENV['GEMINI_API_KEY'] = 'test-gemini-key-123'
        expect(described_class.configured?).to be true
        ENV.delete('GEMINI_API_KEY')
      end
    end

    context 'when no API key is set' do
      it 'returns false' do
        ENV.delete('GEMINI_API_KEY')
        expect(described_class.configured?).to be false
      end
    end

    context 'when API key is empty string' do
      it 'returns false' do
        ENV['GEMINI_API_KEY'] = ''
        expect(described_class.configured?).to be false
        ENV.delete('GEMINI_API_KEY')
      end
    end

    context 'when API key is whitespace only' do
      it 'returns false' do
        ENV['GEMINI_API_KEY'] = '   '
        expect(described_class.configured?).to be false
        ENV.delete('GEMINI_API_KEY')
      end
    end

    context 'when API key has invalid format' do
      it 'returns false for key with quotes' do
        ENV['GEMINI_API_KEY'] = '"test-key"'
        expect(described_class.configured?).to be false
        ENV.delete('GEMINI_API_KEY')
      end

      it 'returns false for key with special characters' do
        ENV['GEMINI_API_KEY'] = 'test@key!'
        expect(described_class.configured?).to be false
        ENV.delete('GEMINI_API_KEY')
      end

      it 'returns false for key with spaces' do
        ENV['GEMINI_API_KEY'] = 'test key with spaces'
        expect(described_class.configured?).to be false
        ENV.delete('GEMINI_API_KEY')
      end
    end
  end

  describe '.configure!' do
    before do
      ENV.delete('GEMINI_API_KEY')
    end

    context 'when ruby_llm is not available' do
      it 'returns without error' do
        allow(described_class).to receive(:llm_available?).and_return(false)
        expect { described_class.configure! }.not_to raise_error
      end
    end

    context 'when no API key is configured' do
      it 'raises MissingAPIKeyError' do
        allow(described_class).to receive(:llm_available?).and_return(true)
        expect { described_class.configure! }.to raise_error(
          PocketKnife::MissingAPIKeyError,
          'No API key configured. Set GEMINI_API_KEY'
        )
      end
    end

    context 'when GEMINI_API_KEY is set' do
      it 'configures RubyLLM with Gemini key' do
        ENV['GEMINI_API_KEY'] = 'test-gemini-key-123'
        allow(described_class).to receive(:llm_available?).and_return(true)

        # Mock RubyLLM configuration
        config_double = double('config')
        expect(config_double).to receive(:gemini_api_key=).with('test-gemini-key-123')

        # Stub RubyLLM constant
        ruby_llm_stub = double('RubyLLM')
        allow(ruby_llm_stub).to receive(:configure).and_yield(config_double)
        stub_const('RubyLLM', ruby_llm_stub)

        described_class.configure!
        ENV.delete('GEMINI_API_KEY')
      end
    end

    context 'when API key has leading/trailing whitespace' do
      it 'strips whitespace before configuration' do
        ENV['GEMINI_API_KEY'] = '  test-gemini-key-123  '
        allow(described_class).to receive(:llm_available?).and_return(true)

        config_double = double('config')
        expect(config_double).to receive(:gemini_api_key=).with('test-gemini-key-123')

        # Stub RubyLLM constant
        ruby_llm_stub = double('RubyLLM')
        allow(ruby_llm_stub).to receive(:configure).and_yield(config_double)
        stub_const('RubyLLM', ruby_llm_stub)

        described_class.configure!
        ENV.delete('GEMINI_API_KEY')
      end
    end

    context 'when API key format is invalid' do
      it 'raises InvalidAPIKeyError for key with quotes' do
        ENV['GEMINI_API_KEY'] = '"test-key"'
        allow(described_class).to receive(:llm_available?).and_return(true)

        expect { described_class.configure! }.to raise_error(
          PocketKnife::InvalidAPIKeyError,
          'Invalid API key format. Remove quotes and ensure no extra spaces.'
        )
        ENV.delete('GEMINI_API_KEY')
      end

      it 'raises InvalidAPIKeyError for key with special characters' do
        ENV['GEMINI_API_KEY'] = 'test@key!'
        allow(described_class).to receive(:llm_available?).and_return(true)

        expect { described_class.configure! }.to raise_error(
          PocketKnife::InvalidAPIKeyError
        )
        ENV.delete('GEMINI_API_KEY')
      end
    end
  end
end
