require("app.views.Util")

STATE = CreateEnumTable({
	"kBorning",       -- 1
	"kBattle",
	"kDie",
	"kCanBeRemoved",
	"kUnmatched"
}, 0)