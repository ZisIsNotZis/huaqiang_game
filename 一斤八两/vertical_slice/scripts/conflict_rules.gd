class_name ConflictRules
extends RefCounted


static func resolve_escape(
	exit_prepared: bool,
	helper_blocked: bool,
	merchant_support: int,
) -> Dictionary:
	var active_opponents := maxi(merchant_support, 1)
	if exit_prepared and helper_blocked:
		return {
			"outcome": "controlled_escape",
			"injury": "none",
			"active_opponents": 1,
		}
	if exit_prepared or helper_blocked or active_opponents <= 1:
		return {
			"outcome": "injured_escape",
			"injury": "minor",
			"active_opponents": active_opponents,
		}
	return {
		"outcome": "injured_escape",
		"injury": "severe",
		"active_opponents": active_opponents,
	}
