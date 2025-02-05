local f = require("core.flatten_table")
local eq = assert.are.same

local t = {
	level1 = {
		level2 = {
			level3 = {
				level4 = "hi just here",
				level4a = {
					theend = "just ended",
				},
			},
		},
	},
}

describe("flatten_table", function()
	it("it should flat table with prefix .", function()
		local flatted = f.flat(t, ".")
		eq(flatted["level1.level2.level3.level4"], "hi just here")
		eq(flatted["level1.level2.level3.level4a.theend"], "just ended")
	end)

	it("it should flat table with prefix __", function()
		local flatted = f.flat(t, "__")
		eq(flatted["level1__level2__level3__level4"], "hi just here")
		eq(flatted["level1__level2__level3__level4a__theend"], "just ended")
	end)

	it(
		"it should return expected table of { ['level1__level2__level3__level4'] = 'hi just here', ['level1__level2__level3__level4a__theend'] = 'just ended' }",
		function()
			local flatted = f.flat(t, "__")
			eq(flatted, {
				["level1__level2__level3__level4"] = "hi just here",
				["level1__level2__level3__level4a__theend"] = "just ended",
			})
		end
	)

	it("it should flat array value to [1, 2, 3, 4]", function()
		local flatted = f.flat({ nested = { array = { 1, 2, 3, 4 } } }, "-")
		eq(flatted, { ["nested-array"] = "[1, 2, 3, 4]" })
	end)
end)
