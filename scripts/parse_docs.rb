require 'nokogiri'
require 'yaml'
require 'open-uri'

def body_params?(pointer)
	/Request Body:/i === pointer.text
end

def example_response?(pointer)
	/Example Reponse:/i === pointer.text
end

def extract_header(pointer)
	/(POST|GET|DELETE|PATCH|PUT)\s+(.+)/ === pointer.text.strip.gsub(/[\u200B-\u200D\uFEFF]/, '')
	$~.captures
end

def extract_params(pointer)
	header, *rows = pointer.css('tr')
	headers = header.css('th').map(&:text)
	rows.each_with_object([]) do |row, o|
		o << Hash[headers.zip(row.css('td').map(&:text))]
	end
end

def extract_path(pointer)
	/Endpoint:\s+(.*)/i === pointer.text&.strip
	$~.captures.first
end

def header?(pointer)
	/POST|GET|DELETE|PATCH|PUT/ === pointer.at_css('code')&.text
end

def param_table?(pointer)
	/Name/i === pointer.at_css('th')&.text
end

def path?(pointer)
	/Endpoint:\s+(.*)/i === pointer.text
end

def path_params?(pointer)
	/Path Variables:/i === pointer.text
end

def query_params?(pointer)
	/Query Params:/i === pointer.text
end

url = "https://flatfile.com/docs/api-reference/"
doc = Nokogiri::HTML(URI.open(url))
pointer = doc.at_css('#endpoints')

endpoints = []
context = nil
spec = nil
while pointer = pointer.next_sibling
	case
	when header?(pointer)
		context = nil
		spec = {}
		endpoints << spec
		spec[:method], spec[:description] = extract_header(pointer)
	when path?(pointer)
		spec[:path] = extract_path(pointer)
	when body_params?(pointer)
		context = :body_params
	when path_params?(pointer)
		context = :path_params
	when query_params?(pointer)
		context = :query_params
	when param_table?(pointer)
		spec[context] = extract_params(pointer)
		context = nil
	when example_response?(pointer)
		context = nil
	else
		# puts "Don't know how to handle: #{pointer.text}"
	end
end

puts endpoints.to_yaml
