# frozen_string_literal: true

require 'spec_helper'

describe Attributor::Flatpack::Config do
  let(:type) do
    Class.new(Attributor::Flatpack::Config) do
      keys do
        key :baz, String
        key :bar, String
        key :foo do
          key :bar, String, required: true
          key :bench, String
          key :deep do
            key :deeper do
              key :deepest, String
            end
          end
        end
        key :widget_factory, String
        key :defaults, String, default: 'Work'
        key :finale do
          key :explode, Attributor::Boolean
          key :implode, Attributor::Boolean
        end
      end
    end
  end

  let(:data) do
    {
      :baz => 'Baz',
      'bar' => 'Bar',
      :foo => {
        bar: 'Foobar'
      },
      :finale => {
        'implode' => true,
        'explode' => false
      }
    }
  end

  subject(:config) { type.load(data) }

  context 'simply loading' do
    it 'loads symbols' do
      expect(config.baz).to eq 'Baz'
    end
    it 'loads strings' do
      expect(config.bar).to eq 'Bar'
    end
    it 'loads boolean true' do
      expect(config.finale.implode).to be(true)
    end
    it 'loads boolean false' do
      expect(config.finale.explode).to be(false)
    end
  end

  context 'dumping to a hash' do
    subject(:dumped) { config.dump }
    its(%i[baz]) { should eq 'Baz' }
    its(%i[bar]) { should eq 'Bar' }
    its(%i[foo bar]) { should eq 'Foobar' }
    its(%i[finale implode]) { should be true }
    its(%i[finale explode]) { should be false }
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
        'WIDGET_FACTORY' => 'Factory of Widgets',
        'FOO_DEEP_DEEPER_DEEPEST' => 'down there',
        'FINALE_EXPLODE' => 'false',
        'FINALE_IMPLODE' => 'true'
      }
    end
    it 'unpacks names' do
      expect(config.foo.bar).to eq 'Bar of Foos'
      expect(config.foo.deep.deeper.deepest).to eq 'down there'
    end
    it 'still supports packed names' do
      expect(config.widget_factory).to eq 'Factory of Widgets'
    end
    it 'unpacks booleans' do
      expect(config.finale.explode).to be(false)
      expect(config.finale.implode).to be(true)
    end
  end
  context 'unpacking names using a custom separator' do
    let(:type) do
      Class.new(Attributor::Flatpack::Config) do
        separator '.'
        keys do
          key :foo do
            key :bar, String
            key :deep do
              key :deeper do
                key :deepest_enabled, String
              end
            end
          end
          key :widget_factory, String
        end
      end
    end

    let(:data) do
      {
        'FOO.BAR' => 'Bar of Foos',
        'WIDGET_FACTORY' => 'Factory of Widgets',
        'FOO.DEEP.DEEPER.DEEPEST_ENABLED' => 'down there'
      }
    end
    it 'unpacks names' do
      expect(config.foo.deep.deeper.deepest_enabled).to eq 'down there'
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
    let(:data) { { finale: { explode: true, implode: false } } }
    it 'creates handy ? methods' do
      expect(config.finale.explode).to be(true)
      expect(config.finale.implode).to be(false)

      expect(config.finale.explode?).to be(true)
      expect(config.finale.implode?).to be(false)
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

  context '.example' do
    subject(:example) { type.example }
    it 'generates objects that have dotted methods' do
      expect(example.foo.bar).to be_kind_of(String)
    end
    it 'generates objects that have bracket methods' do
      expect(example[:foo][:bar]).to be_kind_of(String)
    end
  end

  it 'returns an empty array for no errors' do
    expect(config.validate).to eq []
  end

  context '#validate' do
    let(:type) do
      Class.new(Attributor::Flatpack::Config) do
        keys allow_extra: false do
          key :baz, String
          key :foo do
            key :bar, String
          end
        end
      end
    end

    subject(:errors) { config.validate }

    context 'without extra keys in the data' do
      let(:data) { { baz: '1' } }
      it { should be_empty }
    end
    context 'with extra keys in the top-level data' do
      let(:data) { { invalid: '1' } }
      subject(:errors) { config.validate }

      it { should_not be_empty }
    end

    context 'recursively checks for extra keys' do
      let(:data) { { foo: { still_invalid: '1' } } }
      subject(:errors) { config.validate }

      it { should_not be_empty }
    end
  end

  context 'with data with invalid keys' do
    let(:data) do
      {
        { foo: :baz } => :bar
        :foo => :bar
      }
    end
    it 'should fail to initialize' do
      expect { subject }.to raise_error(ArgumentError)
    end
  end
end
