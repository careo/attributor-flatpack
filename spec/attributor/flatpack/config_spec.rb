require 'spec_helper'

describe Attributor::Flatpack::Config do
  let(:type) do
    Class.new(Attributor::Flatpack::Config) do
      keys do
        key :baz, String
        key :bar, String
        key :foo do
          key :bar, String
          key :bench, String
        end
        key :widget_factory, String
      end
    end
  end

  let(:data) do
  end

  subject(:config) { type.load(data) }

  context 'simply loading' do
    let(:data) { {:baz => 'Baz', 'bar' => 'Bar'} }
    it 'loads symbols' do
      expect(config.baz).to eq 'Baz'
    end
    it 'loads strings' do
      expect(config.bar).to eq 'Bar'
    end
  end

  context 'case insensitivity' do
    let(:data) { {"BAZ" => 'Baz', :Bar => 'Bar'} }
    it 'loads from uppercase' do
      expect(config.baz).to eq 'Baz'
    end
    it 'loads from mixed cases' do
      expect(config.bar).to eq 'Bar'
    end
  end

  context 'unpacking names' do
    let(:data) { {'FOO_BAR' => 'Bar of Foos', "WIDGET_FACTORY" => "Factory of Widgets"} }
    it 'unpacks names' do
      expect(config.foo.bar).to eq 'Bar of Foos'
    end
    it 'still supports packed names' do
      expect(config.widget_factory).to eq 'Factory of Widgets'
    end
  end

  context 'merging names' do
    let(:data) do
      {
        :foo => '{"bar": "Serialized Bar"}',
        'FOO_BENCH' => "Bench of the Foos"
      }
    end

    it 'loads serialized stuff' do
      expect(config.foo.bar).to eq 'Serialized Bar'
    end
    it 'fetches packed names still' do
      expect(config.foo.bench).to eq 'Bench of the Foos'
    end

  end

end
