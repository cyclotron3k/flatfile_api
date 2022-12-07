# FlatfileApi

This software is an unofficial client for the Flatfile API, and is not endorsed by Flatfile.

It provides access to all available endpoints, but the documentation is patchy and most endpoints are untested. Use with caution.

If you can help document the endpoints, and provide example use cases, please feel free to send pull requests.

### A note on naming conventions

The Flatfile API typically uses `CamelCase` for parameters, and hash key names (but not always). This gem converts everything to `snake_case`.

### A note on pagination

Some of the endpoints are paginated; they can be identified as the ones that take `skip` and `take` as parameters. They are not required values and will default to `0` and `50` respectively. You can use these values to manage your own pagination, but you can also treat the response as an `Enumerable` and use `each`, `map`, `find`, etc. and it will automatically pull all results. Use with caution.

All the endpoints return either a `FlatfileApi::Response` or a `FlatfileApi::PaginatedResponse`.

On either response, use the `data` method to access the returned data.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add flatfile_api

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install flatfile_api

## Usage

### Get recent uploads

```ruby
require 'flatfile_api'

client = FlatfileApi.new access_key_id: '12345', secret_access_key: '1234-456790-1234'
uploads = client.list_workspace_uploads license_key: '9999-234234-2342'
# => <FlatfileApi::PaginatedResponse:0x00007f508bdd6020 ...>

# Access the page of results directly:
uploads.data.first
# => {
#  :license_id=>938427,
#  :team_id=>10483,
#  :environment_id=>"4248-585628-1322",
#  :workspace_id=>nil,
#  :schema_id=>nil,
#  :embed_id=>nil,
#  :end_user_id=>"6776-278654-6823",
#  :filename=>
#   "license-9999-234234-2342/batch-4752-164173-1238/upload-9663-680238-0901.csv",
#  :source=>nil,
#  :memo=>nil,
#  :validated_in=>nil,
#  :original_file=>"my upload.csv",
#  ...

# Make use of the convenience functions:

# GOOD - it won't request more pages than it needs
uploads.take_while { |t| ... }

# NOT SO GOOD - using select like this forces every page to be fetched
uploads.select { |t| ... }

# PRETTY AWESOME - using Enumerable#lazy to postpone filtering
uploads.lazy.select { |t| /\.csv$/ === t[:original_file] }.first 5

# Just get all the uploads:
uploads.to_a

```

## Methods

### exchange_access_key_for_jwt
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| access_key_id | true | string |  | Access Key generated in app |
| expires_in |  | number | 43200 (default) | Sets an expiration (in seconds) |
| secret_access_key | true | string |  | Secret Access Key generated in app |

Response: `FlatfileApi::Response`


### download_an_upload
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| batch_id | true | string |  | A valid UUID |
| type | true | string | Enum: original, processed | File to download |

Response: `FlatfileApi::Response`


### delete_an_upload
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| batch_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### bulk_delete_uploads
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| older_than_quantity | true | string |  |  |
| older_than_unit | true | string | Enum: minute, hour, day, week, month |  |
| send_email | true | string | Enum: true, false |  |
| team_id | true | string |  |  |

Response: `FlatfileApi::Response`


### list_workspace_uploads
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| end_user_id |  | string |  | Valid endUserId for the Workspace |
| environment_id |  | string |  | Valid environmentId for the Workspace |
| license_key | true | string |  | A valid licenseKey for the Workspace |
| search |  | string |  | Searches fileName, originalFile, memo |
| skip |  | number | 0 (default) | The rows to skip before listing |
| take |  | number | 50 (default) | The maximum number of rows to return |
| workspace_id |  | string |  | Valid workspaceId for the Workspace |

Response: `FlatfileApi::PaginatedResponse`


### file_upload_meta_data
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| batch_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### sheet_name_for_file_upload
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| license_key |  | string |  | A valid licenseKey for the Workspace |
| upload_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### records_for_file_upload
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| batch_id | true | string |  | A valid UUID |
| created_at_end_date |  | string | ISO 8601 | The maximum createdAt date to return |
| created_at_start_date |  | string | ISO 8601 | The minimum createdAt date to return |
| deleted |  | string | Enum: true, t, y, false, f, n | Return only deleted rows |
| skip |  | number | 0 (default) | The rows to skip before listing |
| take |  | number | 50 (default) | The maximum number of rows to return |
| updated_at_end_date |  | string | ISO 8601 | The maximum updatedAt date to return |
| updated_at_start_date |  | string | ISO 8601 | The minimum updatedAt date to return |
| valid |  | string | Enum: true, t, y, false, f, n | Return only valid rows |

Response: `FlatfileApi::PaginatedResponse`


### upload_to_workspace_sheet
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| sheet_id | true | string |  | A valid UUID |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### fetch_workspace_sheet_records
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| filter |  | string | Enum: review, dismissed, accepted | Return only the filtered rows |
| merge_id |  | string |  |  |
| nested |  | boolean |  |  |
| record_ids |  | string[] |  |  |
| sheet_id | true | string |  | A valid UUID |
| skip |  | number | 0 (default) | The rows to skip before listing |
| take |  | number | 50 (default) | The maximum number of rows to return |
| valid |  | string | Enum: true, t, y, false, f, n | Return only valid rows |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::PaginatedResponse`


### list_team_workspaces
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| environment_id |  | string |  | Valid environmentId for the Workspace |
| skip |  | number | 0 (default) | The rows to skip before listing |
| take |  | number | 50 (default) | The maximum number of rows to return |
| team_id | true | string |  |  |

Response: `FlatfileApi::PaginatedResponse`


### detail_workspace
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### invite_workspace_collaborator
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| email | true | string |  | Email address of invited collaborator |
| team_id | true | string |  |  |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### list_workspace_invitations
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| team_id | true | string |  |  |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### list_workspace_collaborators
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| team_id | true | string |  |  |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### revoke_workspace_invitation
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| email | true | string |  | Email address of invited collaborator |
| team_id | true | string |  |  |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


### remove_workspace_collaborator
| Name | Required | Type | Value | Description |
| ---- | -------- | ---- | ----- | ----------- |
| email | true | string |  | Email address of collaborator |
| team_id | true | string |  |  |
| user_id | true | string |  |  |
| workspace_id | true | string |  | A valid UUID |

Response: `FlatfileApi::Response`


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cyclotron3k/flatfile_api.
