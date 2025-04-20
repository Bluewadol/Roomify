# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Load all seed files from db/seeds directory
# Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |seed|
#   load seed i need user room
# end
# โหลด seeds แบบจัดลำดับ user ก่อน room
%w[
  users
  rooms
].each do |filename|
  seed_file = Rails.root.join("db", "seeds", "#{filename}.rb")
  if File.exist?(seed_file)
    puts "⏳ Loading seed: #{filename}.rb"
    load seed_file
  else
    puts "⚠️ Seed file not found: #{filename}.rb"
  end
end
