object @settings => :settings
attribute :time_zone, :debug
node(:time_zone_offset) {|obj| obj.time_zone_offset}
node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors.as_json
end