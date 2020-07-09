require "dotenv/load"
require "twitter"

require "rdf"
require "sparql/client"
require "date"
require "pry"

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

sparql = SPARQL::Client.new("https://sdbm.library.upenn.edu/sparql/sdbm/query")

time = Time.new
month = time.month
day = time.day
month_day = sprintf "%02d%02d", month, day

query = %Q[
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  PREFIX sdbm: <https://sdbm.library.upenn.edu/>

  SELECT ?source ?source_date ?source_title WHERE {
    ?source a sdbm:sources ;
    sdbm:sources_date ?source_date ;
    sdbm:sources_title ?source_title .

    FILTER regex(?source_date,  "\\\\d{4,4}#{month_day}")
    FILTER (?source_title!="Provenance update")
  }
]

def trim_title title, max_length = 165
  return title if title.length <= max_length
  title_length = title.length
  while title_length > max_length
    title_array = title.split
    title_array.pop
    title = title_array.join " " 
    title_length = title.length + 3
  end
  title + '...'
end

sources = []
sparql.query(query).each_solution do |solution|
  data = {}
  data[:title] = solution[:source_title].to_s
  data[:link] = solution[:source].to_s
  data[:date] = Date.parse(solution[:source_date].to_s)
  sources << data
end

random_source = sources[rand(0..sources.length)]
# random_source = {
#   :title => "This is definitely too long of a title. I'm actually really surprised that we can't find one naturally. It must be that none exists on today's date. It actually has to be even longer, because the function isn't even shortening the title. That's because the title was too short previously. Now, with all this extra text on the end, it sholdn't be too short.",
#   :link => "https://sdbm.library.upenn.edu/sources/10277",
#   :date => Date.parse("20200909")
# }

date = random_source[:date].strftime("%A, %B %-d, %Y")

title = trim_title(random_source[:title])

tweet = "Check out '#{title}' released on #{date}! #{random_source[:link]}"

puts tweet
puts tweet.length
#client.update(tweet)