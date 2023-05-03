require 'rails_helper'

RSpec.describe ApplicationJobWorker, type: :worker do
  let(:worker) { ApplicationJobWorker.new }

  describe '#perform' do
    it 'NotImplementedErrorが発生する' do
      expect { worker.perform }.to raise_error(NotImplementedError)
    end
  end

  describe '#parse_arguments_to_deep_symbols' do
    let(:arguments) do
      {
        'key1' => 'value1',
        'key2' => {
          'nested_key1' => 'nested_value1',
          'nested_key2' => 'nested_value2'
        }
      }
    end

    let(:expected_result) do
      {
        key1: 'value1',
        key2: {
          nested_key1: 'nested_value1',
          nested_key2: 'nested_value2'
        }
      }
    end

    it 'ハッシュのキーをシンボルに変換して正しくパースできる' do
      result = worker.parse_arguments_to_deep_symbols(arguments)
      expect(result).to eq(expected_result)
    end
  end
end
