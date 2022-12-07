# Appropriated from ActiveSupport/Inflector

class FlatfileApi
	module StringTools
		refine String do
			def underscore
				self.gsub(
					/([A-Z]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/
				) { ($1 || $2) << "_" }.tr(
					"-",
					"_"
				).downcase
			end
		end
	end
end
