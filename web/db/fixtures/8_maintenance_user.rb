User.unscoped.seed_once(:email) do |s|
  s.role = User::ROLE_MAINTENANCE
  s.name = "Maintenance"
  s.email = "maintenance@chaibio.com"
  s.password = "notused"
  s.password_confirmation = "notused"
end
