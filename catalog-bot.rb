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
sdbm = RDF::Vocabulary.new "https://sdbm.library.upenn.edu/"

# query = sparql.select(:source).
#   where(
#   [:source, RDF.type, sdbm[:sources]],
#   [sdbm[:sources_date], RDF.value, :sources_date]
#   ).limit(10)

query2 = "
  PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
  PREFIX sdbm: <https://sdbm.library.upenn.edu/>

  SELECT ?source ?source_date ?source_type WHERE {
    #VALUES ?source_type {<https://sdbm.library.upenn.edu/source_types/1>} .
    ?source a sdbm:sources ;
      sdbm:sources_date ?source_date.
  }
"

puts query2

sparql.query(query2).each_solution do |solution|
  puts solution[:source]
  puts solution[:source_date]
end

