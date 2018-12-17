object @user
attribute :id, :email, :role, :name, :show_banner

node(:authentication_token, :unless => lambda { |obj| obj != current_user }) do |o|
	authentication_token
end

node(:errors, :unless => lambda { |obj| obj.errors.empty? }) do |o|
  o.errors.as_json
end
