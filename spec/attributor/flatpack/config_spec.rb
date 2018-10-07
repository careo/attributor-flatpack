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
        key :defaults, String, default: 'Work'
        key :explode, Attributor::Boolean
        key :implode, Attributor::Boolean
      end
    end
  end

  let(:data) { { :baz => 'Baz', 'bar' => 'Bar' } }
  subject(:config) { type.load(data) }

  context 'simply loading' do
    it 'loads symbols' do
      expect(config.baz).to eq 'Baz'
    end
    it 'loads strings' do
      expect(config.bar).to eq 'Bar'
    end
  end

  context 'case insensitivity' do
    let(:data) { { 'BAZ' => 'Baz', :Bar => 'Bar' } }
    it 'loads from uppercase' do
      expect(config.baz).to eq 'Baz'
    end
    it 'loads from mixed cases' do
      expect(config.bar).to eq 'Bar'
    end
  end

  context 'unpacking names' do
    let(:data) do
      {
        'FOO_BAR' => 'Bar of Foos',
        'WIDGET_FACTORY' => 'Factory of Widgets'
      }
    end
    it 'unpacks names' do
      expect(config.foo.bar).to eq 'Bar of Foos'
    end
    it 'still supports packed names' do
      expect(config.widget_factory).to eq 'Factory of Widgets'
    end
  end

  context 'unpacking names using a custom separator' do
    let(:type) do
      Class.new(Attributor::Flatpack::Config) do
        separator '.'
        keys do
          key :foo do
            key :bar, String
          end
          key :widget_factory, String
        end
      end
    end

    let(:data) do
      {
        'FOO.BAR' => 'Bar of Foos',
        'WIDGET_FACTORY' => 'Factory of Widgets'
      }
    end
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
        'FOO_BENCH' => 'Bench of the Foos'
      }
    end

    it 'loads serialized stuff' do
      expect(config.foo.bar).to eq 'Serialized Bar'
    end
    it 'fetches packed names still' do
      expect(config.foo.bench).to eq 'Bench of the Foos'
    end
  end

  context 'default values' do
    it 'still work' do
      expect(config.defaults).to eq 'Work'
    end
  end

  context 'setting values' do
    it 'works with defined keys' do
      config.baz = 'New Baz'
      expect(config.baz).to eq 'New Baz'
    end
  end
  context 'boolean readers' do
    let(:data) { { explode: true, implode: false } }
    it 'creates handy ? methods' do
      expect(config.explode).to be(true)
      expect(config.implode).to be(false)

      expect(config.explode?).to be(true)
      expect(config.implode?).to be(false)
    end
  end

  it 'retrieving an undefined key raises an exception' do
    expect { config.get('missing') }.to \
      raise_error(Attributor::Flatpack::UndefinedKey)
  end

  context 'validating definitions' do
    it 'ensures defined keys are symbols' do
      type = Class.new(Attributor::Flatpack::Config) do
        keys do
          key 'invalid string', String
        end
      end
      expect { type.attributes }.to raise_error(ArgumentError)
    end
  end

  it 'supports [] and []=' do
    expect(config[:baz]).to eq 'Baz'
    config[:baz] = 'New Baz'
    expect(config[:baz]).to eq 'New Baz'
  end

  it 'returns an empty array for no errors' do
    expect(config.validate).to eq []
  end
end
