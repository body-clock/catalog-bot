require "dotenv/load"
require "twitter"

require "rdf"
require "sparql/client"
require "date"

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
  }
]

sources = []
sparql.query(query).each_solution do |solution|
  data = {}
  data[:title] = "#{solution[:source_title]}"
  data[:link] = "#{solution[:source]}"
  
  data[:date] = Date.parse("#{solution[:source_date]}")
  sources << data
end

random_source = sources[rand(0..sources.length)]

tweet = "Check out #{random_source[:title]} released on #{random_source[:date]}! #{random_source[:link]}"
puts tweet
#client.update(tweet)