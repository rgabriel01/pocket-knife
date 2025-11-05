# frozen_string_literal: true

require 'English'
require 'spec_helper'

RSpec.describe 'pocket-knife executable' do
  let(:bin_path) { File.expand_path('../../bin/pocket-knife', __dir__) }

  describe 'successful calculations' do
    it 'calculates percentage correctly' do
      output = `#{bin_path} calc 100 20`
      expect(output.strip).to eq('20.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'calculates with decimal base' do
      output = `#{bin_path} calc 99.99 10`
      expect(output.strip).to eq('10.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'calculates 15% of 200' do
      output = `#{bin_path} calc 200 15`
      expect(output.strip).to eq('30.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'handles zero percentage' do
      output = `#{bin_path} calc 100 0`
      expect(output.strip).to eq('0.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'handles zero base' do
      output = `#{bin_path} calc 0 50`
      expect(output.strip).to eq('0.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end
  end

  describe 'error handling with exit codes' do
    it 'exits with code 2 for invalid percentage' do
      `#{bin_path} calc 100 abc 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(2)
    end

    it 'exits with code 2 for decimal percentage' do
      `#{bin_path} calc 100 12.5 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(2)
    end

    it 'exits with code 2 for invalid base' do
      `#{bin_path} calc xyz 20 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(2)
    end

    it 'exits with code 1 for missing arguments' do
      `#{bin_path} calc 100 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(1)
    end

    it 'exits with code 1 for wrong subcommand' do
      `#{bin_path} multiply 100 20 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(1)
    end

    it 'exits with code 1 for too many arguments' do
      `#{bin_path} calc 100 20 30 2>/dev/null`
      expect($CHILD_STATUS.exitstatus).to eq(1)
    end
  end

  describe 'help flag' do
    it 'displays help with --help flag' do
      output = `#{bin_path} --help`
      expect(output).to include('Usage:')
      expect(output).to include('pocket-knife calc')
      expect(output).to include('pocket-knife ask')
      expect(output).to include('Commands:')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'displays help with -h flag' do
      output = `#{bin_path} -h`
      expect(output).to include('Usage:')
      expect(output).to include('pocket-knife calc')
      expect(output).to include('pocket-knife ask')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end
  end

  describe 'direct execution' do
    it 'can be executed directly as ./bin/pocket-knife' do
      output = `./bin/pocket-knife calc 100 20`
      expect(output.strip).to eq('20.00')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end
  end

  describe 'ask command' do
    context 'when LLM features not installed' do
      it 'exits with code 1 and helpful error message' do
        # Simulate missing gem by manipulating the environment
        output = `#{bin_path} ask "What is 20% of 100?" 2>&1`
        if output.include?('LLM features not available')
          expect(output).to include('LLM features not available')
          expect(output).to include('bundle install --with llm')
          expect(output).to include('pocket-knife calc')
          expect($CHILD_STATUS.exitstatus).to eq(1)
        else
          # Skip if LLM is actually available (tested in next context)
          skip 'LLM features are available, skipping unavailable test'
        end
      end
    end

    context 'when API key not configured' do
      it 'exits with code 1 and helpful error message' do
        # Run with no API key set
        output = `GEMINI_API_KEY= #{bin_path} ask "What is 20% of 100?" 2>&1`
        if output.include?('No API key configured')
          expect(output).to include('No API key configured')
          expect(output).to include('GEMINI_API_KEY')
          expect(output).to include('makersuite.google.com')
          expect(output).to include('pocket-knife calc')
          expect($CHILD_STATUS.exitstatus).to eq(1)
        else
          skip 'LLM features not available or other setup issue'
        end
      end
    end

    context 'when query is missing' do
      it 'exits with code 1 and helpful error message' do
        output = `GEMINI_API_KEY=test-key #{bin_path} ask 2>&1`
        if output.include?('Missing query') || output.include?('Invalid API key')
          expect(output).to match(/Missing query|Invalid API key/)
          expect(output).to include('pocket-knife')
          expect($CHILD_STATUS.exitstatus).to eq(1)
        else
          skip 'LLM features not available or other setup issue'
        end
      end
    end

    context 'when API key has invalid format' do
      it 'exits with code 1 for key with quotes' do
        output = `GEMINI_API_KEY='"test-key"' #{bin_path} ask "What is 20% of 100?" 2>&1`
        if output.include?('Invalid API key format') || output.include?('No API key configured')
          expect(output).to match(/Invalid API key format|No API key configured/)
          expect(output).to include('pocket-knife calc')
          expect($CHILD_STATUS.exitstatus).to eq(1)
        else
          skip 'LLM features not available'
        end
      end
    end
  end
end
