require "dotenv/load"
require "twitter"

require "rdf"
require "sparql/client"

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

regex = 


query = %Q[
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  PREFIX sdbm: <https://sdbm.library.upenn.edu/>

  SELECT ?source ?source_date ?source_type WHERE {
    ?source a sdbm:sources ;
    sdbm:sources_date ?source_date.

    FILTER regex(?source_date,  "\\\\d{4,4}#{month_day}")
  }
]

puts query

sparql.query(query).each_solution do |solution|
  puts solution[:source]
  puts solution[:source_date]
end

