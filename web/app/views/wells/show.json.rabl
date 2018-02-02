object @well
attribute :well_num, :well_type, :sample_name, :notes

node :targets do |obj|
  [obj.target1, obj.target2]
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end