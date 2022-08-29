package lego.simple.__customer.__relation

default allowed = false

allowed {
	user = ds.object({
		"type": "user",
		"key": input.user.email,
	})

	customer = ds.object({
		"type": "customer",
		"key": input.resource.customer,
	})

	ds.check_relation({
		"sub_id": user.id,
		"obj_type": "customer",
		"relation": input.resource.relation,
		"obj_id": customer.id,
	})
}
