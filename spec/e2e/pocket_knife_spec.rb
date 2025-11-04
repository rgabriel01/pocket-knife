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
      expect(output).to include('Usage: pocket-knife calc')
      expect(output).to include('Examples:')
      expect($CHILD_STATUS.exitstatus).to eq(0)
    end

    it 'displays help with -h flag' do
      output = `#{bin_path} -h`
      expect(output).to include('Usage: pocket-knife calc')
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
end
