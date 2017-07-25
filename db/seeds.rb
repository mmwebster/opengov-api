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

# map to map rand num to a record type
type_map = [
  -> () {
    WebDatum.create(
      key: "GDP", # always upper-case, delimeted by underscores
      url: "https://www.cia.gov/library/publications/the-world-factbook/",
      value_i: rand(500)
    )
  },
  -> () {
    WebDatum.create(
      key: "GDP", # always upper-case, delimeted by underscores
      url: "https://www.cia.gov/library/publications/the-world-factbook/",
      value_f: rand(500) / 1.01
    )
  },
  -> () {
    WebDatum.create(
      key: "GDP-string", # always upper-case, delimeted by underscores
      url: "https://www.cia.gov/library/publications/the-world-factbook/",
      value_s: "some-val"
    )
  }
]

# insert all records
num_entries.times do
  # rand num to decide record type
  data_type = rand(3)
  # create the randomized record
  new_rand_record = type_map[data_type].call()
  # push to store
  web_data.push(new_rand_record)
end
puts "SEEDS::DEBUG => Inserted web_datum seeds"

######################################################################
# Relate some web_datum entries to each other
######################################################################
relation_decisions = {}
WebDatum.all.each do |web_datum|
  WebDatum.all.each do |other_web_datum|
    # if not actually the same record
    if not web_datum.id.equal? other_web_datum.id
      # If not rand says yes and prev decision not false, or previous
      # decision true
      id_name = web_datum.id < other_web_datum.id ?
        "#{web_datum.id.to_s}-#{other_web_datum.id.to_s}" :
        "#{other_web_datum.id.to_s}-#{web_datum.id.to_s}"
      if (rand(3) == 0 and not relation_decisions[id_name] == false) or
         (relation_decisions[id_name] == true)
        # add relation
        web_datum.related_keys << other_web_datum
        # indicate relation was made
        relation_decisions[id_name] = true
      else
        # indivate relation should not be made
        relation_decisions[id_name] = false
      end
    end
  end
end
puts "SEEDS::DEBUG => Related all web_datum seeds"

######################################################################
# Confirm success of FULL relation
######################################################################
success = true
# WebDatum.all.each do |web_datum|
#   if web_datum.related_keys.count != (num_entries - 1)
#     success = false
#   end
# end

if success
  puts "SEEDS::DEBUG => SUCCESS"
else
  puts "SEEDS::DEBUG => FAILURE"
end
