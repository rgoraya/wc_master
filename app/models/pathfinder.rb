class PathFinder
	include ActiveModel::Validations

	validates_presence_of :source
	attr_accessor :source, :destination

	def initialize(source, destination=0)
		@source = source
		@destination = destination
	end

	# Placeholder for path algorithms here
	# These will either return a single path or 
	# a bunch of them, depending on API call
	# Wanted to separate from graph logic to make it more modular.
end
