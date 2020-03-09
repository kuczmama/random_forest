#!/usr/bin/env ruby

# frozen_string_literal: true

require 'optparse'
require_relative 'csv_helper'
require_relative './random_forest'
require_relative 'kaggle_errors'

Options = Struct.new(:max_input_size, :label, :verbose, :num_trees, :rows_per_tree)

class Parser
  def self.parse(options)
    args = Options.new(nil, :label, false, 1, nil)

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

      opts.on('-n ROWS_PER_TREE', '--num-rows-per-tree=ROWS_PER_TREE', 'The number of rows to be used for each tree. Default read all of them') do |rows_per_tree|
        args.rows_per_tree = rows_per_tree
      end
      # TODO: - date labels, regression, classifier
    end

    opt_parser.parse!(options)
    args
  end
end
options = Parser.parse(ARGV.length.zero? ? %w[--help] : ARGV)

training_data = csv_to_array_of_hashes(ARGV[0], { max_input_size: options[:max_input_size] })

# # Read in random data to be loaded for each tree, in order

if options[:verbose]
  puts "Creating a random forest with #{options[:num_trees]} trees from #{ARGV[0]}..."
end

random_forest = RandomForest.new(training_data, options)
validation = csv_to_array_of_hashes('Valid.csv')
valid_solution = csv_to_array_of_hashes('ValidSolution.csv')

puts 'Write kaggle submission data...'
predictions = []
actuals = []
File.open('kaggle-submission.csv', 'w') do |f|
  f.write "SalesID,SalePrice\n"

  validation.each_with_index do |data, i|
    prediction = random_forest.predict(data).flatten.inject(:+).to_f
    f.write "#{data['SalesID']},#{prediction}\n"
    predictions << prediction
    actuals << valid_solution[i]['SalePrice']
  end
end

puts 'calculate rmse...'
puts "RMSLE: #{rmsle(predictions, actuals)}"
