# frozen_string_literal: true

require "json"
require "net/http"

require_relative "flatfile_api/version"
require_relative "flatfile_api/response"
require_relative "flatfile_api/paginated_response"
require_relative "flatfile_api/string_tools"

class FlatfileApi
	class Error < StandardError; end

	using StringTools

	PROTO = "https"
	HOST  = "api.us.flatfile.io"

	def initialize(access_key_id: ENV['FLATFILE_ACCESS_KEY_ID'], secret_access_key: ENV['FLATFILE_SECRET_ACCESS_KEY'], debug: false)
		@access_key_id = access_key_id
		@secret_access_key = secret_access_key
		@debug = debug
		@redirect_limit = 5

		@base_uri = URI "#{PROTO}://#{HOST}"
		@agent = Net::HTTP.new @base_uri.host, @base_uri.port
		@agent.use_ssl = PROTO == 'https'
		@agent.keep_alive_timeout = 10
		@agent.set_debug_output $stdout if @debug
	end

	def exchange_access_key_for_jwt(
		access_key_id:,
		expires_in:nil,
		secret_access_key:
	)

		request(
			:post,
			"/auth/access-key-exchange",
			body_params: {
				accessKeyId: access_key_id, # Access Key generated in app
				expiresIn: expires_in, # Sets an expiration (in seconds)
				secretAccessKey: secret_access_key, # Secret Access Key generated in app
			},
		)
	end

	def download_an_upload(
		batch_id:,
		type:
	)

		request(
			:get,
			"/batch/%<batchId>s/export.csv",
			path_params: {
				batchId: batch_id, # A valid UUID
			},
			query_params: {
				type: type, # File to download
			},
		)
	end

	def delete_an_upload(
		batch_id:
	)

		request(
			:delete,
			"/batch/%<batchId>s",
			path_params: {
				batchId: batch_id, # A valid UUID
			},
		)
	end

	def bulk_delete_uploads(
		older_than_quantity:,
		older_than_unit:,
		send_email:,
		team_id:
	)

		request(
			:get,
			"/delete/batches",
			query_params: {
				olderThanQuantity: older_than_quantity,
				olderThanUnit: older_than_unit,
				sendEmail: send_email,
				teamId: team_id,
			},
		)
	end

	def list_workspace_uploads(
		end_user_id:nil,
		environment_id:nil,
		license_key:,
		search:nil,
		skip:nil,
		take:nil,
		workspace_id:nil
	)

		request(
			:get,
			"/rest/batches",
			query_params: {
				endUserId: end_user_id, # Valid endUserId for the Workspace
				environmentId: environment_id, # Valid environmentId for the Workspace
				licenseKey: license_key, # A valid licenseKey for the Workspace
				search: search, # Searches fileName, originalFile, memo
				skip: skip, # The rows to skip before listing
				take: take, # The maximum number of rows to return
				workspaceId: workspace_id, # Valid workspaceId for the Workspace
			},
		)
	end

	def file_upload_meta_data(
		batch_id:
	)

		request(
			:get,
			"/rest/batch/%<batchId>s",
			path_params: {
				batchId: batch_id, # A valid UUID
			},
		)
	end

	def sheet_name_for_file_upload(
		upload_id:,
		license_key:nil
	)

		request(
			:get,
			"/upload/%<uploadId>s/dataSources",
			path_params: {
				uploadId: upload_id, # A valid UUID
			},
			query_params: {
				licenseKey: license_key, # A valid licenseKey for the Workspace
			},
		)
	end

	def records_for_file_upload(
		batch_id:,
		created_at_end_date:nil,
		created_at_start_date:nil,
		deleted:nil,
		skip:nil,
		take:nil,
		updated_at_end_date:nil,
		updated_at_start_date:nil,
		valid:nil
	)

		request(
			:get,
			"/rest/batch/%<batchId>s/rows",
			path_params: {
				batchId: batch_id, # A valid UUID
			},
			query_params: {
				createdAtEndDate: created_at_end_date, # The maximum createdAt date to return
				createdAtStartDate: created_at_start_date, # The minimum createdAt date to return
				deleted: deleted, # Return only deleted rows
				skip: skip, # The rows to skip before listing
				take: take, # The maximum number of rows to return
				updatedAtEndDate: updated_at_end_date, # The maximum updatedAt date to return
				updatedAtStartDate: updated_at_start_date, # The minimum updatedAt date to return
				valid: valid, # Return only valid rows
			},
		)
	end

	def upload_to_workspace_sheet(
		sheet_id:,
		workspace_id:
	)

		request(
			:post,
			"/workspace/%<workspaceId>s/sheet/%<sheetId>s/data",
			path_params: {
				sheetId: sheet_id, # A valid UUID
				workspaceId: workspace_id, # A valid UUID
			},
		)
	end

	def fetch_workspace_sheet_records(
		sheet_id:,
		workspace_id:,
		filter:nil,
		merge_id:nil,
		nested:nil,
		record_ids:nil,
		skip:nil,
		take:nil,
		valid:nil
	)

		request(
			:get,
			"/workspace/%<workspaceId>s/sheet/%<sheetId>s/records",
			path_params: {
				sheetId: sheet_id, # A valid UUID
				workspaceId: workspace_id, # A valid UUID
			},
			query_params: {
				filter: filter, # Return only the filtered rows
				mergeId: merge_id,
				nested: nested,
				recordIds: record_ids,
				skip: skip, # The rows to skip before listing
				take: take, # The maximum number of rows to return
				valid: valid, # Return only valid rows
			},
		)
	end

	def list_team_workspaces(
		team_id:,
		environment_id:nil,
		skip:nil,
		take:nil
	)

		request(
			:get,
			"/rest/teams/%<teamId>s/workspaces",
			path_params: {
				teamId: team_id,
			},
			query_params: {
				environmentId: environment_id, # Valid environmentId for the Workspace
				skip: skip, # The rows to skip before listing
				take: take, # The maximum number of rows to return
			},
		)
	end

	def detail_workspace(
		workspace_id:
	)

		request(
			:get,
			"/rest/workspace/%<workspaceId>s",
			path_params: {
				workspaceId: workspace_id, # A valid UUID
			},
		)
	end

	def invite_workspace_collaborator(
		team_id:,
		workspace_id:,
		email:
	)

		request(
			:post,
			"/rest/teams/%<teamId>s/workspaces/%<workspaceId>s/invitations",
			path_params: {
				teamId: team_id,
				workspaceId: workspace_id, # A valid UUID
			},
			body_params: {
				email: email, # Email address of invited collaborator
			},
		)
	end

	def list_workspace_invitations(
		team_id:,
		workspace_id:
	)

		request(
			:get,
			"/rest/teams/%<teamId>s/workspaces/%<workspaceId>s/invitations",
			path_params: {
				teamId: team_id,
				workspaceId: workspace_id, # A valid UUID
			},
		)
	end

	def list_workspace_collaborators(
		team_id:,
		workspace_id:
	)

		request(
			:get,
			"/rest/teams/%<teamId>s/workspaces/%<workspaceId>s/collaborators",
			path_params: {
				teamId: team_id,
				workspaceId: workspace_id, # A valid UUID
			},
		)
	end

	def revoke_workspace_invitation(
		team_id:,
		workspace_id:,
		email:
	)

		request(
			:delete,
			"/rest/teams/%<teamId>s/workspaces/%<workspaceId>s/invitations",
			path_params: {
				teamId: team_id,
				workspaceId: workspace_id, # A valid UUID
			},
			body_params: {
				email: email, # Email address of invited collaborator
			},
		)
	end

	def remove_workspace_collaborator(
		team_id:,
		user_id:,
		workspace_id:,
		email:
	)

		request(
			:delete,
			"/rest/teams/%<teamId>s/workspaces/%<workspaceId>s/collaborators/%<userId>s",
			path_params: {
				teamId: team_id,
				userId: user_id,
				workspaceId: workspace_id, # A valid UUID
			},
			body_params: {
				email: email, # Email address of collaborator
			},
		)
	end

	# def inspect
	# 	"#<#{self.class}:#{object_id}>"
	# end

	private

	def ouroboros(node)
		case node
		when Array
			node.map { |v| ouroboros(v) }
		when Hash
			node.each_with_object({}) { |(k, v), o| o[k.underscore.to_sym] = ouroboros(v) }
		else
			node
		end
	end

	def request(method, path, path_params: {}, body_params: {}, query_params: nil)
		uri = URI("#{PROTO}://#{HOST}")
		uri.path = path % path_params
		uri.query = URI.encode_www_form(query_params.compact) if query_params
		request_uri(
			method,
			uri,
			path_params: path_params,
			body_params: body_params,
			query_params: query_params
		)
	end

	def request_uri(method, uri, path_params: {}, body_params: {}, query_params: nil, redirects: 0)
		http             = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl     = true
		http.verify_mode = OpenSSL::SSL::VERIFY_PEER

		case method
		when :post
			request =  Net::HTTP::Post.new uri
			request['Content-Type'] = 'application/json; charset=UTF-8'
			request.body = JSON.generate body_params.compact
		when :get
			request = Net::HTTP::Get.new uri
		when :delete
			request = Net::HTTP::Delete.new uri
		else
			raise NotImplementedError.new "Bad http method: #{method}"
		end

		# puts "\e[1;32mDespatching request to #{uri.path}\e[0m" if @debug

		request["X-Api-Key"] = "#{@access_key_id}+#{@secret_access_key}"

		@session = @agent.start unless @agent.started?
		response = @session.request request

		# puts "\e[1;32mResponse received\e[0m" if @debug

		case response
		when Net::HTTPOK
			# Continue
		when Net::HTTPRedirection
			raise "Too many redirects" if redirects > @redirect_limit
			# It's probably a file
			next_uri = URI response['location']
			return request_uri(method, next_uri, redirects: redirects + 1)
		else
			raise Error.new "Error response from #{uri} -> #{response.read_body}"
		end

		case response['content-type']
		when /^application\/json/
			data = ouroboros JSON.parse response.read_body
		when /^text\/csv/, /^application\//
			return Response.new(response.body)
		else
			raise NotImplementedError.new "Don't know how to parse #{response['content-type']}"
		end

		if data.key?(:pagination)
			PaginatedResponse.new(
				data,
				self,
				method,
				uri.path,
				path_params: path_params,
				body_params: body_params,
				query_params: query_params
			)
		else
			Response.new data
		end

	end

end
