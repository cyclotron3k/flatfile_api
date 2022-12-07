# frozen_string_literal: true

require_relative "lib/flatfile_api/version"

Gem::Specification.new do |spec|
	spec.name = "flatfile_api"
	spec.version = FlatfileApi::VERSION
	spec.authors = ["cyclotron3k"]
	spec.email = ["aidan.samuel@gmail.com"]

	spec.summary = "Flatfile API client"
	spec.description = "A thin wrapper around the Flatfile RESTful API"
	spec.homepage = "https://github.com/cyclotron3k/flatfile_api"
	spec.required_ruby_version = ">= 2.6.0"

	spec.metadata["bug_tracker_uri"]   = "https://github.com/cyclotron3k/flatfile_api/issues"
	spec.metadata["changelog_uri"]     = "https://github.com/cyclotron3k/flatfile_api/blob/master/CHANGELOG.md"
	spec.metadata["documentation_uri"] = "https://github.com/cyclotron3k/flatfile_api/blob/v#{FlatfileApi::VERSION}/README.md"
	spec.metadata["homepage_uri"]      = spec.homepage
	spec.metadata["source_code_uri"]   = 'https://github.com/cyclotron3k/flatfile_api'

	# Specify which files should be added to the gem when it is released.
	# The `git ls-files -z` loads the files in the RubyGem that have been added into git.
	spec.files = Dir.chdir(__dir__) do
		`git ls-files -z`.split("\x0").reject do |f|
			(f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
		end
	end
	spec.bindir = "exe"
	spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
	spec.require_paths = ["lib"]

end
