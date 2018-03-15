require 'las_reader'

unless ARGV[0]
  STDERR.puts 'Specify las filename as first argument'
  exit(1)
end

filename = ARGV[0]

my_las = CWLSLas.new(filename)

zs_curves = (1..54).map{|n| "ZS#{n}"}
zl_curves = (1..54).map{|n| "ZL#{n}"}
CURVES = zs_curves + zl_curves

RESULTS = {}

CURVES.each do |curve_name|
  c = my_las.curve(curve_name)
  max = c.log_data.max
  min = c.log_data.min
  step = ( max - min ) / 10.0
  mapped_data = c.log_data.map do |value|
    if step == 0
      0.0
    else
      ((value - min) / step)
    end
  end

  RESULTS[curve_name] = mapped_data
end

require 'csv'

CSV.open('results.csv', 'w') do |csv|
  csv << CURVES
  rows_num = RESULTS.first[1].count
  rows_num.times do |i|
    values = RESULTS.map{|k,v| v[i]}
    csv << values
  end
end
