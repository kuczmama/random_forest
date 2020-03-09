# frozen_string_literal: true

require 'csv'
require 'time'
require 'pry'

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

def csv_to_array_of_hashes(file_path, options = {})
  result = []
  csv_size = rand(`wc -l #{file_path}`.split.first.to_i)
  max_input_size = options[:max_input_size].nil? ? nil : options[:max_input_size].to_i

  i = 0
  CSV.foreach(file_path, headers: true) do |csv_row|
    break if !max_input_size.nil? && i >= max_input_size

    row = {}
    csv_row.each do |k, v|
      # TODO: handle dates
      row[k] = if v.nil?
                 nil
               elsif v.is_float? || v.is_int?
                 v.to_f # RegressionP
               elsif v.is_date?
                 date_time = Time.parse(v)
                 features = date_features(date_time)
                 row = row.merge(features)
               else
                 v # Classifier - string
               end
    end
    result << row
    i += 1
  end
  result
end
