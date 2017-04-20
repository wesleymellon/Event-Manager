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

def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone_number)
  phone_number.gsub!(/[^0-9]/, "")
  phone_number_length = phone_number.length

  if phone_number_length < 10 || phone_number_length > 11
    "0000000000"
  elsif phone_number_length == 11 && phone_number[0] == "1"
    phone_number.slice!(0)
  else
    phone_number
  end
end

def find_peak(counts)
  counts.key(counts.values.max)
end

def add_to_counts(counts, item)
  if counts[item]
    counts[item] += 1
  else
    counts[item] = 1
  end
end

def find_hour_of_day(reg_date)
  date = DateTime.strptime(reg_date, "%m/%d/%y %H:%M")
  date.hour
end

def find_day_of_week(reg_date)
  date = DateTime.strptime(reg_date, "%m/%d/%y %H:%M")
  date.cwday
end

def convert_day(weekday)
  case weekday
  when 1
    "Monday"
  when 2
    "Tuesday"
  when 3
    "Wednesday"
  when 4 
    "Thursday"
  when 5 
    "Friday"
  when 6
    "Saturday"
  when 7 
    "Sunday"
  end
end

contents = CSV.open 'event_attendees.csv', headers: true, \
                                           header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hours = {}
days = {}

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone(row[:homephone])

  hour = find_hour_of_day(row[:regdate])
  add_to_counts(hours, hour)

  day = convert_day(find_day_of_week(row[:regdate]))
  add_to_counts(days, day)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end

peak_hour = find_peak(hours)
peak_day = find_peak(days)

puts "The peak registration hour was #{peak_hour}"
puts "The peak registration day was #{peak_day}"


