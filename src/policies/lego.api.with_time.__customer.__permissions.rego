package lego.api.with_time.__customer.__permissions

import future.keywords.every
import future.keywords.in

default allowed = false

allowed {
   user = ds.object({
    "type": "user",
    "key": input.user.email
  })
  customer = ds.object({
    "type": "customer",
    "key": input.resource.customer
  })
  Links := user.properties.Links

  some i
  Link := Links[i]

  check_valid_time(Link)

  # Check that the user is allowed to access this part of the hierarchy:
	has_access_to_customer(Link, input.resource.customer)
  permissions = get_input_permissions()
	check_permissions(user,customer,permissions)
}

check_permissions(user, customer, permissions) {
  every permission in permissions {
    ds.check_permission({
      "sub_id": user.id,
      "obj_type": "customer",
      "permission": permission,
      "obj_id": customer.id
    })
  }
}

get_input_permissions() = input.resource.permissions {
  input.resource.permissions
} else = [] {
  true
}

has_access_to_customer(Link, target_customer) {
  user_customer := Link.Customers[_]
  parent = ds.object({
    "type": "customer",
    "key": user_customer
  })
  child = ds.object({
    "type": "customer",
    "key": target_customer
  })
  is_parent(parent.id, child.id)
} else = false {
  true
}

is_parent(parentID, childID) {
  parentID == childID
} else {
  ds.check_relation({
    "sub_id": parentID,
    "obj_type": "customer",
    "relation": "customer-parent",
    "obj_id": childID
  })
} else = false {
  true
}

check_valid_time(Link) = true {
  now := time.now_ns()
  check_valid_from(Link, now)
  check_valid_to(Link, now)
} else = false {
  true
}

check_valid_from(Link, now) = time.parse_rfc3339_ns(from) <= now {
  from := Link.ValidFrom
} else = true {
  # No valid from specified, so assume OK:
  true
}

check_valid_to(Link, now) = now <= time.parse_rfc3339_ns(to) {
  to := Link.ValidTo
} else = true {
  # No valid to specified, so assume OK:
  true
}
