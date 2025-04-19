# Admin users
admin1 = User.find_or_create_by!(email: 'admin01@odds.team') do |u|
    u.password = 'Hf3tV4grPv93@uz'
    u.password_confirmation = 'Hf3tV4grPv93@uz'
    u.name = 'Admin01'
    u.phone_number = '0981527191'
end
admin1.add_role(:admin) unless admin1.has_role?(:admin)
puts "Admin01 user created successfully!"

admin2 = User.find_or_create_by!(email: 'admin02@odds.team') do |u|
    u.password = 'Hf3tV4grPv93@u2'
    u.password_confirmation = 'Hf3tV4grPv93@u2'
    u.name = 'Admin02'
    u.phone_number = '0631525851'
end
admin2.add_role(:admin) unless admin2.has_role?(:admin)
puts "Admin02 user created successfully!"

# Regular users
user3 = User.find_or_create_by!(email: 'user03@odds.team') do |u|
    u.password = 'P@ssw0rd123!'
    u.password_confirmation = 'P@ssw0rd123!'
    u.name = 'User03'
    u.phone_number = '0812345678'
end
user3.add_role(:user) unless user3.has_role?(:user)
puts "User03 created successfully!"

user4 = User.find_or_create_by!(email: 'user04@odds.team') do |u|
    u.password = 'P@ssw0rd456!'
    u.password_confirmation = 'P@ssw0rd456!'
    u.name = 'User04'
    u.phone_number = '0823456789'
end
user4.add_role(:user) unless user4.has_role?(:user)
puts "User04 created successfully!"

user5 = User.find_or_create_by!(email: 'user05@odds.team') do |u|
    u.password = 'P@ssw0rd789!'
    u.password_confirmation = 'P@ssw0rd789!'
    u.name = 'User05'
    u.phone_number = '0834567890'
end
user5.add_role(:user) unless user5.has_role?(:user)
puts "User05 created successfully!"

user6 = User.find_or_create_by!(email: 'user06@odds.team') do |u|
    u.password = 'P@ssw0rd012!'
    u.password_confirmation = 'P@ssw0rd012!'
    u.name = 'User06'
    u.phone_number = '0845678901'
end
user6.add_role(:user) unless user6.has_role?(:user)
puts "User06 created successfully!"

user7 = User.find_or_create_by!(email: 'user07@odds.team') do |u|
    u.password = 'P@ssw0rd345!'
    u.password_confirmation = 'P@ssw0rd345!'
    u.name = 'User07'
    u.phone_number = '0856789012'
end
user7.add_role(:user) unless user7.has_role?(:user)
puts "User07 created successfully!"

user8 = User.find_or_create_by!(email: 'user08@example.com') do |u|
    u.password = 'P@ssw0rd678!'
    u.password_confirmation = 'P@ssw0rd678!'
    u.name = 'User08'
    u.phone_number = '0867890123'
end
user8.add_role(:user) unless user8.has_role?(:user)
puts "User08 created successfully!"

user9 = User.find_or_create_by!(email: 'user09@example.com') do |u|
    u.password = 'P@ssw0rd901!'
    u.password_confirmation = 'P@ssw0rd901!'
    u.name = 'User09'
    u.phone_number = '0878901234'
end
user9.add_role(:user) unless user9.has_role?(:user)
puts "User09 created successfully!"

user10 = User.find_or_create_by!(email: 'user10@example.com') do |u|
    u.password = 'P@ssw0rd234!'
    u.password_confirmation = 'P@ssw0rd234!'
    u.name = 'User10'
    u.phone_number = '0889012345'
end
user10.add_role(:user) unless user10.has_role?(:user)
puts "User10 created successfully!"
