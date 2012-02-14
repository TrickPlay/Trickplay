callable = DuckType {
	[type] = 'function',
	[indexable.is] = {
		function(self) return (getmetatable(self) or table.hole).__call end,
	}
}