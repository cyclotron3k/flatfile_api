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

	puts "\n\n### #{method_name}\n"
	combined_params = endpoint.values_at(
		:path_params,
		:query_params,
		:body_params
	).compact.flatten

	combined_params.sort_by { |param|
		camel_to_snake param['Name']
	}.tap { |params|
		if params.any?
			puts "| Name | Required | Type | Value | Description |"
			puts "| ---- | -------- | ---- | ----- | ----------- |"
		end
	}.each do |param, o|
		key = camel_to_snake param['Name']
		puts "| #{key} | #{param['Required']} | #{param['Type']} | #{param['Value']} | #{param['Description']} |"
	end

	paginated = combined_params.map { |x| x['Name'] }.include? 'take'
	puts "\nResponse: `FlatfileApi::" + ( paginated ? 'Paginated' : '' ) + 'Response`'

end
