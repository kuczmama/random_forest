#!/usr/bin/env ruby

# frozen_string_literal: true

require 'set'
require 'pry'

# Make predictions with trees
class DecisionTree
  attr_accessor :root

  def initialize(training_data, label_name = :label)
    @label_name = label_name
    @root = build_tree(training_data)
  end

  # Decision Tree Node
  class Node
    attr_accessor :label, :value, :left, :right, :predictions

    def to_s
      result = ''
      unless label.nil? || value.nil?
        comparator = value.is_a?(Numeric) ? '>=' : '=='
        result += "Is #{label} #{comparator} #{value}"
      end
      result += "--> Predictions: #{predictions}" unless predictions.nil?
      result
    end
  end

  def to_s
    print_tree(@root)
  end

  def predict(features)
    predict_helper(features, @root)
  end

  private

  # unique_features: {:weight=>#<Set: {10, 3, 5}>, :color=>#<Set: {"Green", "Orange"}>}
  def find_unique_features(rows)
    unique_features = {}
    rows.each do |row|
      row.each do |label, v|
        next if label == @label_name # Ignore the label

        unique_features[label] = Set.new if unique_features[label].nil?
        unique_features[label] << v
      end
    end
    unique_features
  end

  def build_tree(rows)
    best_question = find_best_question(rows)
    info_gain = best_question[:info_gain]

    node = Node.new
    if info_gain.zero?
      node.predictions = labels(rows).uniq
      return node
    end
    node.label = best_question[:label]
    node.value = best_question[:value]
    left, right = partition(rows, best_question[:label], best_question[:value])
    node.left = build_tree(left)
    node.right = build_tree(right)

    node.label = best_question[:label]
    node.value = best_question[:value]
    node
  end

  def calc_weighted_uncertainty(left, right)
    left_weight = left.length / (left.length + right.length).to_f
    left_weight * gini(left) + (1 - left_weight) * gini(right)
  end

  def labels(rows)
    rows.map { |row| row[@label_name.to_sym] || row[@label_name.to_s] }
  end

  # { label: best_question_label, value: best_question_value }
  def find_best_question(rows)
    best_label = nil
    best_value = nil
    best_gain = 0.0
    current_uncertainty = gini(labels(rows))
    find_unique_features(rows).each do |label, values|
      values.each do |value|
        left, right = partition(rows, label, value)

        next if left.empty? || right.empty?

        info_gain = current_uncertainty - calc_weighted_uncertainty(labels(left), labels(right))
        next unless info_gain > best_gain

        best_gain = info_gain
        best_label = label
        best_value = value
      end
    end
    { label: best_label, value: best_value, info_gain: best_gain }
  end

  def gini(labels)
    label_counts = {}
    labels.each do |label|
      label_counts[label] = 0.0 if label_counts[label].nil?
      label_counts[label] += 1.0
    end

    result = 0.0
    labels.each do |label|
      result += 1.0 / labels.length * (1 - label_counts[label] / labels.length)
    end
    result
  end

  def match(value, question_value)
    return !value.nil? if question_value.nil?
    return !question_value.nil? if value.nil?

    return false if value.class != question_value.class
    if !!question_value == question_value
      return value == question_value
    end # boolean
    return value == question_value if question_value.is_a? String
    return value >= question_value if question_value.is_a? Numeric

    raise "typeof #{question_value.class} is not supported"
  end

  def partition(rows, label, question_value)
    trues = []
    falses = []
    rows.each do |row|
      if match(row[label], question_value)
        trues << row
      else
        falses << row
      end
    end
    [trues, falses]
  end

  def print_tree(root, spacing = '')
    return if root.nil?

    puts "#{spacing}#{root}"

    if root.left
      puts "#{spacing}-->true"
      print_tree(root.left, "#{spacing}\t")
    end

    if root.right
      puts "#{spacing}-->false:"
      print_tree(root.right, "#{spacing}\t")
    end
  end

  def predict_helper(features, root = nil)
    return root.predictions unless root.predictions.nil?

    question_value = root.value
    value = features[root.label]

    if match(value, question_value)
      predict_helper(features, root.left)
    else
      predict_helper(features, root.right)
    end
  end
end
