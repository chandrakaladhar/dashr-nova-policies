package dashr.authz_test

import data.dashr.authz

test_admin_can_do_anything if {
	authz.allow with input as {"user": {"roles": ["platform-admin"]}, "action": "delete"}
}

test_researcher_can_read if {
	authz.allow with input as {"user": {"roles": ["researcher"]}, "action": "read"}
}

test_researcher_cannot_write if {
	not authz.allow with input as {"user": {"roles": ["researcher"]}, "action": "write"}
}

test_unknown_role_denied if {
	not authz.allow with input as {"user": {"roles": ["guest"]}, "action": "read"}
}

test_missing_user_denied if {
	not authz.allow with input as {"action": "read"}
}

test_empty_input_denied if {
	not authz.allow with input as {}
}
