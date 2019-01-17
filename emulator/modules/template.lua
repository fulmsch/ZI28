local module = {}

function module.new()
	local self = {
		val = 42
	}

	local read = function(address)
		print(self.val)
	end

	local write = function(address, value)
		print"write"
	end

	return {
		read = read,
		write = write
	}
end

return module
