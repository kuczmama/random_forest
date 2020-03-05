#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative './decision_tree.rb'
require 'pry'
require 'csv'
require 'optparse'
require 'time'

Options = Struct.new(:max_input_size, :label, :verbose, :num_trees)

class RandomForest
  def initialize(training_data, options = {})
    @decision_trees = []
    sample_size = (training_data.length / options[:num_trees].to_f).to_i

    options[:num_trees].to_i.times do
      sample_offset = rand(training_data.length - sample_size).to_i
      puts "offset: #{sample_offset}"
      train = training_data[sample_offset..(sample_size + sample_size)]
      @decision_trees << DecisionTree.new(train, options.label.to_s)
    end
  end

  def predict(features)
    results = []
    @decision_trees.each do |decision_tree|
      results << decision_tree.predict(features)
    end

    results
  end
end

class Parser
  def self.parse(options)
    args = Options.new(nil, :label, false, 1)

    # TODO: add test_data
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} TRAINING_DATA.csv [options]"
      opts.on('-m ROWS', '--max-input-size=ROWS', 'Max rows to read in from the TRAINING_DATA csv, default read in all rows') do |max_input_size|
        args.max_input_size = max_input_size
      end

      opts.on('-h', '--help', 'Prints this help') do
        puts opts
        exit
      end

      opts.on('-v', '--verbose', 'Run verbosely') do
        args.verbose = true
      end

      opts.on('-l LABEL', '--label=LABEL', 'The column name that is the dependent variable. Default \'label\'') do |label|
        args.label = label
      end

      opts.on('-n NUM_TREES', '--num-decision-trees=NUM_TREES', 'Number of decision trees in the random forest') do |num_trees|
        args.num_trees = num_trees
      end
      # TODO: - date labels, regression, classifier
    end

    opt_parser.parse!(options)
    args
  end
end
options = Parser.parse(ARGV.length.zero? ? %w[--help] : ARGV)

class String
  def is_float?
    to_f.to_s == self
  end

  def is_int?
    to_i.to_s == self
  end

  def is_date?
    !Time.parse(self).nil?
  rescue StandardError
    false
  end
end

def date_features(date_time)
  methods = ['month', 'wday', 'yday', 'dst?', 'gmtoff', 'gmt_offset', 'utc_offset', 'utc?', 'gmt?', 'sunday?', 'tuesday?', 'monday?', 'thursday?', 'wednesday?', 'saturday?', 'friday?']
  features = {}
  methods.each do |method|
    features[method] = date_time.send(method)
  end
  features
end

input_data = []

# Read in random data to be loaded for each tree, in order

csv_size = rand(`wc -l #{ARGV[0]}`.split.first.to_i)
# TODO: change this...
max_input_size = options.max_input_size.nil? ? (csv_size.length * 0.9).to_i : options.max_input_size.to_i
# num_test_rows = (csv_size.length * 0.1).to_i

i = 0
CSV.foreach(ARGV[0], headers: true) do |csv_row|
  break if i >= max_input_size

  row = {}
  csv_row.each do |k, v|
    # TODO: handle dates
    row[k] = if v.nil?
               0
             elsif v.is_float? || v.is_int?
               v.to_f # Regression
             elsif v.is_date?
               date_time = Time.parse(v)
               features = date_features(date_time)
               row = row.merge(features)
             else
               v # Classifier - string
             end
  end
  input_data << row
  i += 1
end

if options[:verbose]
  puts "Creating a random forest with #{options[:num_trees]} trees from #{ARGV[0]}..."
end

train_size = (input_data.length * 0.9).to_i
training_data = input_data[0...train_size]
test_data = input_data[train_size..-1]

random_forest = RandomForest.new(training_data, options)

puts 'finding accuracy: '
test_data.each do |data|
  actual = data.delete(options.label.to_s)
  prediction = random_forest.predict(data)
  puts "actual: #{actual} prediction: #{prediction}"
end

# probability_tree = decision_tree.predict(training_data[0..1000])
# binding.pry

# puts predict(probability_tree, bid_size: 80.0, ask_size: 200.0, previous_price: 20.0)
