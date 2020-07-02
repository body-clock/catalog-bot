require "dotenv/load"
require "twitter"

require "rdf"
require "net/http/persistent"
require "sparql/client"

client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["CONSUMER_KEY"]
  config.consumer_secret = ENV["CONSUMER_SECRET"]
  config.access_token = ENV["ACCESS_TOKEN"]
  config.access_token_secret = ENV["ACCESS_TOKEN_SECRET"]
end

sparql = SPARQL::Client.new("https://sdbm.library.upenn.edu/sparql/sdbm/query")
sdbm = RDF::Vocabulary.new "https://sdbm.library.upenn.edu/"

query = sparql.select(:source).
  where(
  [:source, RDF.type, sdbm[:sources]]
).limit(10)

query.each_solution do |solution|
  puts solution.inspect
end
