require 'color'
require 'nokogiri'
base_colors = ['#1e2936'].map{|x| Color::RGB.by_hex(x)}
Color::COLOR_TOLERANCE = 0.03

files = Dir.glob("#{__dir__}/*.svg").select{|x| x.match(/00022/)}.sort.map{|x| File.open(x)}
documents = files.map{|x| Nokogiri::XML.parse(x)}
svgs = documents.map do |x|
  x.children.last.children.select do |x|
    x.name == 'path'
  end.select do |x|
    color = Color::RGB.by_hex x.attr(:fill)
    base_colors.any?{|base| Color.equivalent?(base, color)}
  end
end

template =<<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<svg viewBox="0 0 1365 768" height="768.0pt" width="1365.0pt" xmlns="http://www.w3.org/2000/svg" version="1.1">
__placeholder__
</svg>
EOF

p svgs.map{|x| x.size}

files = svgs.map do |x|
  x.map{|x| x.set_attribute(:fill, '#1e2936')}
  template.gsub('__placeholder', x.map(&:to_s).join("\n"))
end

files.each_with_index do |x, i|
  File.open("#{__dir__}/#{i+1}.svg", 'w').write x
end
