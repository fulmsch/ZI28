----------- To be rewritten in C -----------
package.cpath = package.cpath .. ";./emulator/modules/?/?.so"

function addmodule(modname, slot)
	if not slot then
		i = 1
		while modules[i] ~= nil do i = i + 1 end
		slot = i
	end
	if slot > 8 or slot < 1 then
		print"Error"
		return
	end

	modules[slot] = require(modname).new()
	return modules[slot]
end

----------- Actual configuration -----------
addmodule("sd", 1)
modules[1]:insert("user/sd.img")
