admin = User.find_by(email: 'admin01@odds.team')
puts "🔑 พบผู้ดูแลระบบ: #{admin.email}"

RoomAmenity.destroy_all
Room.destroy_all 

ActiveStorage::Blob.unattached.find_each do |blob|
    puts "Purging unused blob: #{blob.filename}"
    blob.purge
end

territory_1 = Room.find_or_create_by!(slug: "territory-1") do |room|
    room.name = "Territory 1"
    room.status = 0
    room.capacity_min = 5
    room.capacity_max = 8
    room.created_by_id = admin.id
    room.updated_by_id = admin.id
    room.description = "ห้อง Territory 1 สำหรับประชุมหรือใช้งานทั่วไป"
end

# Amenities
[
    { amenity_name: "TV", quantity: 1 },
    { amenity_name: "Whiteboard", quantity: 1 },
    { amenity_name: "Sofa", quantity: 3 },
    { amenity_name: "Table", quantity: 1 }
].each do |amenity_attrs|
    territory_1.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

# Attach image (ถ้ามีไฟล์)
image_path = Rails.root.join("app/assets/images/seeds/Territory-1.png")

if File.exist?(image_path)
    territory_1.images.attach(
        io: File.open(image_path),
        filename: "Territory-1.png",
        content_type: "image/png"
        )
    puts "🖼️ แนบรูปภาพ Territory-1.png แล้ว"
end

image_path2 = Rails.root.join("app/assets/images/seeds/image_2.png")
if File.exist?(image_path2)
    territory_1.images.attach(
        io: File.open(image_path2),
        filename: "image_2.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ image_2.png แล้ว"
end

puts "✅ Seeded Territory 1 พร้อม amenities แล้ว"

territory_2 = Room.find_or_create_by!(slug: "territory-2") do |room|
    room.name = "Territory 2"
    room.status = 0
    room.capacity_min = 5
    room.capacity_max = 8
    room.created_by_id = admin.id
    room.updated_by_id = admin.id
    room.description = "ห้อง Territory 2 สำหรับประชุมหรือใช้งานทั่วไป"
end

# Amenities
[
    { amenity_name: "TV", quantity: 1 },
    { amenity_name: "Whiteboard", quantity: 1 },
    { amenity_name: "Sofa", quantity: 3 },
    { amenity_name: "Table", quantity: 1 }
].each do |amenity_attrs|
    territory_2.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

# Attach image (ถ้ามีไฟล์)
image_path = Rails.root.join("app/assets/images/seeds/Territory-2.png")

if File.exist?(image_path)
    territory_2.images.attach(
        io: File.open(image_path),
        filename: "Territory-2.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ Territory-2.png แล้ว"
end

image_path2 = Rails.root.join("app/assets/images/seeds/image_4.png")
if File.exist?(image_path2)
    territory_2.images.attach(
        io: File.open(image_path2),
        filename: "image_4.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ image_4.png แล้ว"
end

puts "✅ Seeded Territory 2 พร้อม amenities แล้ว"


# Create sample rooms
rooms = [
  {
    name: 'Territory 3',
    slug: 'territory-3',
    description: 'This room for studio',
    capacity_min: 4,
    capacity_max: 8,
    status: 1
  },
  {
    name: 'All Nighter 1',
    slug: 'all-nighter-1',
    description: 'work all night',
    capacity_min: 36,
    capacity_max: 45,
    status: 0
  },
  {
    name: 'All Nighter 2',
    slug: 'all-nighter-2',
    description: 'work space for all night',
    capacity_min: 38,
    capacity_max: 45,
    status: 0
  },
  {
    name: 'Global',
    slug: 'global',
    description: 'This room for global',
    capacity_min: 40,
    capacity_max: 50,
    status: 0
  },
  {
    name: 'Meeting 1',
    slug: 'meeting-1',
    description: 'This room for meeting',
    capacity_min: 6,
    capacity_max: 6,
    status: 0
  },
  {
    name: 'Meeting 2',
    slug: 'meeting-2',
    description: 'This room for meeting',
    capacity_min: 4,
    capacity_max: 6,
    status: 0
  }
]

rooms.each do |room_attrs|
  room = Room.find_or_create_by!(slug: room_attrs[:slug]) do |r|
    r.name = room_attrs[:name]
    r.description = room_attrs[:description]
    r.capacity_min = room_attrs[:capacity_min]
    r.capacity_max = room_attrs[:capacity_max]
    r.status = room_attrs[:status]
    r.created_by_id = admin.id
    r.updated_by_id = admin.id
  end
  puts "🔑 สร้างห้องประชุม: #{room.name}"
end

puts "Created #{rooms.size} rooms successfully!"

# Create amenities for each room
# Amenities
territory_3 = Room.find_by(slug: "territory-3")
[
    { amenity_name: "Glass wall", quantity: 1 },
    { amenity_name: "Whiteboard", quantity: 1 },
    { amenity_name: "Chair", quantity: 3 },
    { amenity_name: "Table", quantity: 1 },
    { amenity_name: "Projector", quantity: 1 },
    { amenity_name: "Screen", quantity: 1 },
    { amenity_name: "Speaker", quantity: 1 },
    { amenity_name: "Microphone", quantity: 1 }
].each do |amenity_attrs|
    territory_3.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded Territory 3 พร้อม amenities แล้ว"

# Attach image (ถ้ามีไฟล์)
image_path = Rails.root.join("app/assets/images/seeds/Territory-3.png")

if File.exist?(image_path)
    territory_3.images.attach(
        io: File.open(image_path),
        filename: "Territory-3.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ Territory-3.png แล้ว"
end

image_path2 = Rails.root.join("app/assets/images/seeds/image_1.png")
if File.exist?(image_path2)
    territory_3.images.attach(
        io: File.open(image_path2),
        filename: "image_1.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ image_1.png แล้ว"
end

all_nighter_1 = Room.find_by(slug: "all-nighter-1")
[
    { amenity_name: "Chair", quantity: 36 },
    { amenity_name: "Whiteboard", quantity: 4 },
    { amenity_name: "Table", quantity: 5 },
    { amenity_name: "Document Room", quantity: 1 }
].each do |amenity_attrs|
    all_nighter_1.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded All Nighter 1 พร้อม amenities แล้ว"

image_path = Rails.root.join("app/assets/images/seeds/All-Nighter-1.png")
if File.exist?(image_path)
    all_nighter_1.images.attach(
        io: File.open(image_path),
        filename: "All-Nighter-1.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ All-Nighter-1.png แล้ว"
end

all_nighter_2 = Room.find_by(slug: "all-nighter-2")
[
    { amenity_name: "Chair", quantity: 38 },
    { amenity_name: "Whiteboard", quantity: 2 },
    { amenity_name: "Table", quantity: 7 },
    { amenity_name: "Document Room", quantity: 1 },
    { amenity_name: "TV", quantity: 1 },
    { amenity_name: "Microphone", quantity: 3 },
    { amenity_name: "Projector", quantity: 1 },
    { amenity_name: "Screen", quantity: 1 }
].each do |amenity_attrs|
    all_nighter_2.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded All Nighter 2 พร้อม amenities แล้ว"

image_path = Rails.root.join("app/assets/images/seeds/All-Nighter-2.png")
if File.exist?(image_path)
    all_nighter_2.images.attach(
        io: File.open(image_path),
        filename: "All-Nighter-2.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ All-Nighter-2.png แล้ว"
end

global = Room.find_by(slug: "global")
[
    { amenity_name: "Chair", quantity: 40 },
    { amenity_name: "Whiteboard", quantity: 4 },
    { amenity_name: "Table", quantity: 10 },
    { amenity_name: "TV", quantity: 2 },
    { amenity_name: "Microphone", quantity: 2 },
    { amenity_name: "Projector", quantity: 1 },
    { amenity_name: "Screen", quantity: 1 }
].each do |amenity_attrs|
    global.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded Global พร้อม amenities แล้ว"

image_path = Rails.root.join("app/assets/images/seeds/Global.png")
if File.exist?(image_path)
    global.images.attach(
        io: File.open(image_path),
        filename: "Global.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ Global.png แล้ว"
end

image_path2 = Rails.root.join("app/assets/images/seeds/image_3.png")
if File.exist?(image_path2)
    global.images.attach(
        io: File.open(image_path2),
        filename: "image_3.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ image_3.png แล้ว"
end

meeting_1 = Room.find_by(slug: "meeting-1")
[
    { amenity_name: "Chair", quantity: 6 },
    { amenity_name: "Whiteboard", quantity: 1 },
    { amenity_name: "Table", quantity: 1 },
    { amenity_name: "TV", quantity: 1 }
].each do |amenity_attrs|
    meeting_1.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded Meeting 1 พร้อม amenities แล้ว"

image_path = Rails.root.join("app/assets/images/seeds/Meeting-1.png")
if File.exist?(image_path)
    meeting_1.images.attach(
        io: File.open(image_path),
        filename: "Meeting-1.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ Meeting-1.png แล้ว"
end

image_path2 = Rails.root.join("app/assets/images/seeds/image_2.jpg")
if File.exist?(image_path2)
    meeting_1.images.attach(
        io: File.open(image_path2),
        filename: "image_2.jpg",
        content_type: "image/jpg"
    )
    puts "🖼️ แนบรูปภาพ image_2.jpg แล้ว"
end

meeting_2 = Room.find_by(slug: "meeting-2")
[
    { amenity_name: "Chair", quantity: 4 },
    { amenity_name: "Whiteboard", quantity: 1 },
    { amenity_name: "Table", quantity: 1 },
    { amenity_name: "TV", quantity: 1 }
].each do |amenity_attrs|
    meeting_2.room_amenities.find_or_create_by!(amenity_name: amenity_attrs[:amenity_name]) do |amenity|
        amenity.quantity = amenity_attrs[:quantity]
    end
end

puts "✅ Seeded Meeting 2 พร้อม amenities แล้ว"

image_path = Rails.root.join("app/assets/images/seeds/Meeting-2.png")
if File.exist?(image_path)
    meeting_2.images.attach(
        io: File.open(image_path),
        filename: "Meeting-2.png",
        content_type: "image/png"
    )
    puts "🖼️ แนบรูปภาพ Meeting-2.png แล้ว"
end
