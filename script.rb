#!/usr/bin/env ruby
require 'rubygems'
require 'bundler'
Bundler.require(:default)

require 'las_reader'

unless ARGV[0] && ARGV[1] && ARGV[2] && ARGV[3]
  STDERR.puts <<EOF
Usage: script.rb filename raw_columns mapped_columns max_value
Example: script.rb source.las DEPT ZS1,ZS2 1
EOF
  exit(1)
end

filename = ARGV[0]
raw_values_curves = ARGV[1].split(',')
mapped_values_curves = ARGV[2].split(',')
max_mapped_value = ARGV[3].to_f

my_las = CWLSLas.new(filename)


RESULTS = {}

mapped_values_curves.each do |curve_name|
  STDERR.puts "Processing #{curve_name}..."
  c = my_las.curve(curve_name)
  max = c.log_data.compact.max
  min = c.log_data.compact.min
  step = ( max - min ) / max_mapped_value
  mapped_data = c.log_data.map do |value|
    if value.nil? || step == 0
      0.0
    else
      ((value - min) / step)
    end
  end

  RESULTS[curve_name] = mapped_data
end

require 'csv'


CSV.open('results.csv', 'w') do |csv|
  csv << (raw_values_curves + mapped_values_curves)
  rows_num = RESULTS.first[1].count
  rows_num.times do |i|
    mapped_values = RESULTS.map{|k,v| v[i]}
    raw_values = raw_values_curves.map do |curve_name|
      my_las.curve(curve_name).log_data[i]
    end
    csv << (raw_values + mapped_values)
  end
end
