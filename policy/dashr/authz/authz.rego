# Application authorization for dashr-nova, queried at
#   POST /v1/data/dashr/authz/allow   {"input": {...}}
#
# input (built by dashr-nova lib/opa.ts):
#   user.roles  array of role names
#   action      e.g. "read"
package dashr.authz

default allow := false

allow if "platform-admin" in input.user.roles

allow if {
	input.action == "read"
	"researcher" in input.user.roles
}
