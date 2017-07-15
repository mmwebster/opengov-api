# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

######################################################################
# Clear all previous entries
######################################################################
WebStatus.delete_all
WebDatum.delete_all

######################################################################
# Create all web_status entires
######################################################################
WebStatus.create(
  url: "https://www.cia.gov/library/publications/the-world-factbook/",
  is_parsed: false
)

######################################################################
# Create all web_datum entries
######################################################################
web_data = []
num_entries = 10
num_entries.times do
  web_data.push(
    WebDatum.create(
      key: "GDP", # always upper-case, delimeted by underscores
      value_i: rand(100000000)
    )
  )
end
puts "SEEDS::DEBUG => Inserted web_datum seeds"

######################################################################
# Relate all web_datum entries to each other
######################################################################
WebDatum.all.each do |web_datum|
  WebDatum.all.each do |other_web_datum|
    if not web_datum.id.equal? other_web_datum.id
      web_datum.related_keys << other_web_datum
    end
  end
end
puts "SEEDS::DEBUG => Related all web_datum seeds"

######################################################################
# Confirm success
######################################################################
success = true
WebDatum.all.each do |web_datum|
  if web_datum.related_keys.count != (num_entries - 1)
    success = false
  end
end

if success
  puts "SEEDS::DEBUG => SUCCESS"
else
  puts "SEEDS::DEBUG => FAILURE"
end
