//shit used in surplus ops' loadouts
/obj/random_item_spawner/surplus //for sake of organization, extend the path

///obj/surplus_spawner

//ammo!


/obj/random_item_spawner/surplus/plinkerrounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_22/smartgun,
	/obj/item/ammo/bullets/bullet_22, //repeats, as a hacky way to alter the weight of some items without using rare_items2spawn
	/obj/item/ammo/bullets/bullet_22,
	/obj/item/ammo/bullets/bullet_22HP)

/obj/random_item_spawner/surplus/pistolrounds
	amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/bullet_9mm,
	/obj/item/ammo/bullets/nine_mm_NATO)

/obj/random_item_spawner/surplus/revolverrounds
	amt2spawn = 3
	items2spawn = list(/obj/item/ammo/bullets/a357,
		/obj/item/ammo/bullets/a357/AP,
		/obj/item/ammo/bullets/a38,
		/obj/item/ammo/bullets/a38,
		/obj/item/ammo/bullets/a38/AP,
		/obj/item/ammo/bullets/a38/stun)

/obj/random_item_spawner/surplus/riflerounds
	min_amt2spawn = 3
	max_amt2spawn = 4
	items2spawn = list(/obj/item/ammo/bullets/assault_rifle,
		/obj/item/ammo/bullets/assault_rifle,
		/obj/item/ammo/bullets/assault_rifle/armor_piercing)

/obj/random_item_spawner/surplus/shotgunshells
	min_amt2spawn = 4
	max_amt2spawn = 5
	items2spawn = list(/obj/item/ammo/bullets/buckshot_burst,
	/obj/item/ammo/bullets/pipeshot/scrap,
	/obj/item/ammo/bullets/abg,
	/obj/item/ammo/bullets/flare,
	/obj/item/ammo/bullets/a12/weak)
	rare_items2spawn = list(/obj/item/ammo/bullets/pipeshot/scrap,
		/obj/item/ammo/bullets/a12)

/obj/random_item_spawner/surplus/energycells
	amt2spawn = 2
	items2spawn = list(/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/med_power,
		/obj/item/ammo/power_cell/self_charging/disruptor)
	rare_items2spawn = list(/obj/item/ammo/power_cell/high_power)

//weapons

/obj/random_item_spawner/surplus/longgun //not necessarily 2 handed, but powerful. Very pricey.
	amt2spawn = 1
	items2spawn = list( //sorta out of place but it's more out of place in the shortguns
		/obj/item/gun/kinetic/spes,
		/obj/item/gun/kinetic/assault_rifle,
		/obj/item/gun/energy/egun,
		/obj/item/gun/energy/plasma_gun,
		/obj/item/gun/energy/alastor,
		/obj/item/gun/energy/blaster_smg)
	rare_items2spawn = list(/obj/item/gun/kinetic/riotgun,
	/obj/item/gun/kinetic/grenade_launcher)

/obj/random_item_spawner/surplus/shortgun //PRAY TO RNJESUS, SONNY
	amt2spawn = 1
	items2spawn = list(/obj/item/gun/kinetic/riot40mm,
		/obj/item/gun/kinetic/pistol,
		/obj/item/gun/kinetic/pistol/smart/mkII,
		/obj/item/gun/kinetic/sawnoff,
		/obj/item/gun/kinetic/silenced_22,
		/obj/item/gun/kinetic/clock_188,
		/obj/item/gun/kinetic/detectiverevolver,
		/obj/item/gun/kinetic/derringer,
		/obj/item/gun/energy/laser_gun,
		/obj/item/gun/energy/phaser_gun,
	///obj/item/gun/energy/blaster_pod_wars/syndicate
	)

	rare_items2spawn = list(
	/obj/item/gun/kinetic/slamgun, //lol
	/obj/item/gun/kinetic/zipgun, //lmao, even
	/obj/item/gun/kinetic/revolver)

/obj/random_item_spawner/surplus/melee //if anything's going to break convention the most it's gonna be this one
	amt2spawn = 1
	items2spawn = list(/obj/item/ratstick,
		/obj/item/bat,
		/obj/item/katana_sheath/reverse,
		/obj/item/breaching_hammer,
		/obj/item/experimental/melee/spear/plaswood,
		/obj/item/sword/discount,
		/obj/item/survival_machete/syndicate,
		/obj/item/dagger/syndicate/specialist,
		/obj/item/deconstructor,
		/obj/item/circular_saw,
		/obj/item/wrench/battle,
		/obj/item/mining_tool/powerhammer,
		/obj/item/brick,
		/obj/item/rods/steel
	)

//utility
/obj/random_item_spawner/surplus/grenades
	amt2spawn = 3
	items2spawn = list(/obj/item/chem_grenade/incendiary,
		/obj/item/chem_grenade/flashbang,
		/obj/item/chem_grenade/napalm, //I am very much so aware that this does nothing without a light
		/obj/item/pipebomb/bomb/miniature_syndicate,
		/obj/item/old_grenade/stinger,
		/obj/item/old_grenade/high_explosive,
		/obj/item/old_grenade/stinger/frag,
		/obj/item/chem_grenade/shock,
		/obj/item/old_grenade/spawner/wasp,
		/obj/item/old_grenade/sawfly,
		/obj/item/old_grenade/emp)

	rare_items2spawn = list(/obj/item/old_grenade/spawner/sawflycluster,
		/obj/item/chem_grenade/pepper,
		/obj/item/chem_grenade/fog,
		/obj/item/gimmickbomb/butt)
