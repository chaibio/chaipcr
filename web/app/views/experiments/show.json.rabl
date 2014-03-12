object @experiment
attribute :id, :name, :qpcr, :run_at

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
	o.errors
end