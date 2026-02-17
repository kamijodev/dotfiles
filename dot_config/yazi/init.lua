require("bookmarks"):setup({
	persist = "all",
	desc_format = "parent",
	notify = {
		enable = true,
		timeout = 1,
		message = {
			new = "Bookmark '<key>' -> '<folder>'",
			delete = "Deleted bookmark '<key>'",
			delete_all = "Deleted all bookmarks",
		},
	},
})
