require 'yaml'

endpoints = YAML.load_file('spec_2022-12-02.yaml')

def camel_to_snake(key)
  key.gsub(/(?<=[a-z0-9])([A-Z])/) { "_#{$1}" }.downcase
end

def snake_to_camel(key)
  key.gsub(/_([a-z0-9])/) { $1.upcase }
end

endpoints.each do |endpoint|
	method_name = endpoint[:description].gsub(/[^a-z0-9_]/i, '_').downcase
	combined_params = endpoint.values_at(
		:path_params,
		:query_params,
		:body_params
	).compact.flatten.each_with_object({}) do |param, o|
		key = camel_to_snake param['Name']
		puts "\e[31mOverwriting key: #{key}\e[0m" if o.key? key
		o[camel_to_snake param['Name']] = /true/i === param['Required']
	end

	print "def #{method_name}("
	puts "" if combined_params.any?
	puts(combined_params.map do |k, v|
		"	#{k}:#{v ? '' : 'nil'}"
	end.join(",\n"))
	puts ")"
	puts ""

	path = endpoint[:path].gsub(/\/:([a-z]+)\b/i) { ?/ + "\%<#{$1}>s" }

	puts "	request("
	puts "		:#{endpoint[:method].downcase},"
	puts "		\"#{path}\","

	[:path_params, :query_params, :body_params].each do |fields|
		next unless endpoint.key? fields
		puts "		#{fields}: {"
		endpoint[fields].each do |param|
			key = camel_to_snake param["Name"]
			print "			#{param["Name"]}: #{key},"
			print " # #{param["Description"]}" if param["Description"].length > 1
			puts ""
		end
		puts "		},"
	end
	puts "	)"
	puts "end"
	puts ""

end
