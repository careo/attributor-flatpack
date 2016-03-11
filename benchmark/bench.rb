require 'bundler/setup'
Bundler.require

class ConfigHash  < Attributor::Hash
  keys allow_extra: true do
    key 'HOME', String
    key 'PATH', String
  end
end

class ConfigFlatpack < Attributor::Flatpack::Config
  keys do
    key :home, String
    key :path, String
  end
end

class ConfigModel < Attributor::Model
  attributes do
    attribute :home, String
    attribute :path, String
  end
end

ConfigStruct = Struct.new(:home, :path)

class Poro
  attr_accessor :home, :path
  def initialize(home, path)
    @home = home
    @path = path
  end
end

HOME = ENV['HOME']
PATH = ENV['PATH']

config_hash = ConfigHash.load(ENV)
config_flatpack = ConfigFlatpack.load(ENV)
config_model = ConfigModel.load(home: HOME, path: PATH)
config_struct = ConfigStruct.new(HOME, PATH)
poro = Poro.new(HOME, PATH)

puts RUBY_DESCRIPTION

Benchmark.ips do |x|
  x.report 'constants' do |i|
    i.times do
      HOME == PATH
    end
  end

  x.report 'ENV' do |i|
    i.times do
      ENV['HOME'] == ENV['PATH']
    end
  end

  x.report 'Attributor::Hash' do |i|
    i.times do
      config_hash['HOME'] == config_hash['PATH']
    end
  end

  x.report 'Attributor::Flatpack' do |i|
    i.times do
      config_flatpack.home == config_flatpack.path
    end
  end

  x.report 'Attributor::Model' do |i|
    i.times do
      config_model.home == config_model.path
    end
  end

  x.report 'Ruby Struct' do |i|
    i.times do
      config_struct.home == config_struct.path
    end
  end

  x.report 'PORO' do |i|
    i.times do
      poro.home == poro.path
    end
  end

  x.compare!
end
