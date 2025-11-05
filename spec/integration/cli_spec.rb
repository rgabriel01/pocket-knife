# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PocketKnife::CLI do
  describe '.run' do
    context 'with valid inputs' do
      it 'calculates and outputs result for integer inputs' do
        expect { described_class.run(%w[calc 100 20]) }
          .to output("20.00\n").to_stdout
      end

      it 'calculates and outputs result for decimal base' do
        expect { described_class.run(['calc', '99.99', '10']) }
          .to output("10.00\n").to_stdout
      end

      it 'handles zero percentage' do
        expect { described_class.run(%w[calc 100 0]) }
          .to output("0.00\n").to_stdout
      end

      it 'handles zero base' do
        expect { described_class.run(%w[calc 0 50]) }
          .to output("0.00\n").to_stdout
      end

      it 'calculates 15% of 200' do
        expect { described_class.run(%w[calc 200 15]) }
          .to output("30.00\n").to_stdout
      end

      it 'calculates 20% of 45.50' do
        expect { described_class.run(['calc', '45.50', '20']) }
          .to output("9.10\n").to_stdout
      end
    end

    context 'with invalid percentage' do
      it 'raises InvalidInputError for non-numeric percentage' do
        expect { described_class.run(%w[calc 100 abc]) }
          .to raise_error(PocketKnife::InvalidInputError, 'Invalid percentage. Please provide a whole number.')
      end

      it 'raises InvalidInputError for decimal percentage' do
        expect { described_class.run(['calc', '100', '12.5']) }
          .to raise_error(PocketKnife::InvalidInputError, 'Invalid percentage. Please provide a whole number.')
      end

      it 'raises InvalidInputError for percentage with % symbol' do
        expect { described_class.run(['calc', '100', '20%']) }
          .to raise_error(PocketKnife::InvalidInputError,
                          'Invalid percentage. Please provide a whole number without the % symbol.')
      end

      it 'raises InvalidInputError for negative percentage' do
        expect { described_class.run(['calc', '100', '-5']) }
          .to raise_error(PocketKnife::InvalidInputError, /cannot be negative/)
      end
    end

    context 'with invalid base' do
      it 'raises InvalidInputError for non-numeric base' do
        expect { described_class.run(%w[calc xyz 20]) }
          .to raise_error(PocketKnife::InvalidInputError, 'Invalid amount. Please provide a numeric value.')
      end
    end

    context 'with missing or wrong arguments' do
      it 'raises CLIError for missing subcommand' do
        expect { described_class.run(%w[100 20]) }
          .to raise_error(PocketKnife::CLIError, /Unknown subcommand/)
      end

      it 'raises CLIError for no arguments' do
        expect { described_class.run([]) }
          .to raise_error(PocketKnife::CLIError, /Missing subcommand/)
      end

      it 'raises CLIError for missing amount' do
        expect { described_class.run(%w[calc 100]) }
          .to raise_error(PocketKnife::CLIError, /Missing arguments/)
      end

      it 'raises CLIError for missing percentage' do
        expect { described_class.run(['calc']) }
          .to raise_error(PocketKnife::CLIError, /Missing arguments/)
      end

      it 'raises CLIError for too many arguments' do
        expect { described_class.run(%w[calc 100 20 extra]) }
          .to raise_error(PocketKnife::CLIError, /Too many arguments/)
      end

      it 'raises CLIError for wrong subcommand' do
        expect { described_class.run(%w[multiply 100 20]) }
          .to raise_error(PocketKnife::CLIError, /Unknown subcommand/)
      end
    end

    context 'with help flag' do
      it 'displays help with --help flag' do
        expect { described_class.run(['--help']) }
          .to output(/Usage:.*pocket-knife calc.*pocket-knife ask/m).to_stdout
          .and raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
      end

      it 'displays help with -h flag' do
        expect { described_class.run(['-h']) }
          .to output(/Usage:.*pocket-knife calc.*pocket-knife ask/m).to_stdout
          .and raise_error(SystemExit) { |error| expect(error.status).to eq(0) }
      end
    end
  end
end
