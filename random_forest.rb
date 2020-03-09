#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative './decision_tree.rb'

class RandomForest
  def initialize(training_data, options = {})
    @decision_trees = []

    # TODO: either bootrap selection of data... where you take randomly rows
    # from the training data... or take n contiguous sections from the training data
    # for now, just do contiguous sections

    # Bootstrap
    options[:num_trees].to_i.times do
      train = training_data.sample(options[:rows_per_tree].nil? ? training_data.length : options[:rows_per_tree])

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
