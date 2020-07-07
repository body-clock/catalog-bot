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
    FILTER (?source_title!="Provenance update")
  }
]

def trim_title title, tweet, max_length = 270 
  # get the length of the tweet
  # remove words from the title until the length of the tweet is less that the max_length
  tweet_length = tweet.length
  title_array = title.split
  while tweet_length > max_length
    title_array.pop
  end
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

date = random_source[:date].strftime("%A, %B %-d, %Y")

#TODO: make sure tweet isn't too long
tweet = "Check out '#{random_source[:title]}' released on #{date}! #{random_source[:link]}"
puts tweet
#client.update(tweet)