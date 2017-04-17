require "csv"
require "sunlight/congress"
require "erb"

template_letter = File.read "form_letter.html"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "Event Manager Initialized!"

# First try. Doesn't use csv
# lines = File.readlines "event_attendees.csv"
# lines.each_with_index do |line, index|
#   next if index == 0
#   columns = line.split(",")
#   name = columns[2]
#   puts name
# end

# Second try. Refactored code to use csv
# contents = CSV.open "event_attendees.csv", headers: true, header_converters: :symbol
# contents.each do |row|
#   name = row[:first_name]
#   zipcode = row[:zipcode]

#   if zipcode.nil?
#     zipcode = "00000"
#   elsif zipcode.length < 5
#     zipcode = zipcode.rjust 5, "0"
#   elsif zipcode.length > 5
#     zipcode = zipcode.slice(0..4)
#   end

#   puts "#{name} #{zipcode}"
# end


# Third try. Refactors code to be in a method.
# def clean_zipcode(zipcode)
#   if zipcode.nil?
#     "00000"
#   elsif zipcode.length < 5
#     zipcode.rjust(5, "0")
#   elsif zipcode.length > 5
#     zipcode[0..4]
#   else zipcode
#   end
# end

# New clean_zipcode method. Just a simplified version
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
  puts form_letter
end


