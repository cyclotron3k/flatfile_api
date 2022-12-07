class FlatfileApi
	class PaginatedResponse
		include Enumerable
		# :pagination=>{:current_page=>1, :limit=>50, :offset=>0, :on_page=>50, :next_offset=>50, :total_count=>3918, :page_count=>79}

		def initialize(response, client, method, path, path_params: {}, body_params: {}, query_params: nil)
			@response     = response
			@client       = client
			@method       = method
			@path         = path
			@path_params  = path_params
			@body_params  = body_params
			@query_params = query_params
		end

		def data
			@response[:data]
		end

		alias :page :data

		def each(&block)
			@response[:data].each { |item| block.call item }
			next_page.each(&block) unless last_page?
		end

		private

		def last_page?
			@response[:pagination][:current_page] >= @response[:pagination][:page_count]
		end

		def next_page
			@client.send(
				:request,
				@method,
				@path,
				path_params:  @path_params,
				body_params:  @body_params,
				query_params: @query_params.merge(skip: @response[:pagination][:next_offset])
			)
		end

	end

end
