/datum/ore_cloud_data
	var/amount
	var/price
	var/for_sale
	var/stats

/obj/machinery/ore_cloud_storage_container
	name = "Rockbox™ Ore Cloud Storage Container"
	desc = "This thing stores ore in \"the cloud\" for the station to use. Best not to think about it too hard."
	icon = 'icons/obj/mining_cloud_storage.dmi'
	icon_state = "ore_storage_unit"
	density = 1
	anchored = 1
	event_handler_flags = USE_FLUID_ENTER | NO_MOUSEDROP_QOL

	var/list/ores = list()

	var/health = 100
	var/broken = 0
	var/sound/sound_load = sound('sound/items/Deconstruct.ogg')

	var/output_target = null

	New()
		. = ..()
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	MouseDrop(over_object, src_location, over_location)
		if(!istype(usr,/mob/living/))
			boutput(usr, "<span class='alert'>Only living mobs are able to set the output target for [src].</span>")
			return

		if(get_dist(over_object,src) > 1)
			boutput(usr, "<span class='alert'>[src] is too far away from the target!</span>")
			return

		if(get_dist(over_object,usr) > 1)
			boutput(usr, "<span class='alert'>You are too far away from the target!</span>")
			return

		if (istype(over_object,/obj/storage/crate/))
			var/obj/storage/crate/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable crate as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		if (istype(over_object,/obj/storage/cart/))
			var/obj/storage/cart/C = over_object
			if (C.locked || C.welded)
				boutput(usr, "<span class='alert'>You can't use a currently unopenable cart as an output target.</span>")
			else
				src.output_target = over_object
				boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else if (istype(over_object,/obj/table/) || istype(over_object,/obj/rack/))
			var/obj/O = over_object
			src.output_target = O.loc
			boutput(usr, "<span class='notice'>You set [src] to output on top of [O]!</span>")

		else if (istype(over_object,/turf) && !over_object:density)
			src.output_target = over_object
			boutput(usr, "<span class='notice'>You set [src] to output to [over_object]!</span>")

		else
			boutput(usr, "<span class='alert'>You can't use that as an output target.</span>")
		return

	MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)

		if (!O || !user)
			return

		if(!isliving(user))
			boutput(user, "<span class='alert'>Only living mobs are able to use the storage container's quick-load feature.</span>")
			return

		if (!isobj(O))
			boutput(user, "<span class='alert'>You can't quick-load that.</span>")
			return

		if(!IN_RANGE(O, user, 1))
			boutput(user, "<span class='alert'>You are too far away!</span>")
			return

		if(!src.accept_loading(user,1))
			boutput(user,"<span class='alert'>The storage container's quick-load system rejects you!</span>")
			return

		else if (istype(O, /obj/storage/crate/)  || istype(O, /obj/storage/cart/))
			var/obj/storage/crate/C = O
			if(istype(C) && (C.welded || C.locked))
				boutput(user, "<span class='alert'>You cannot load from a crate that cannot open!</span>")
				return
			var/obj/storage/cart/Ct = O
			if(istype(Ct) && (Ct.welded || Ct.locked))
				boutput(user, "<span class='alert'>You cannot load from a cart that cannot open!</span>")
				return

			user.visible_message("<span class='notice'>[user] uses [src]'s automatic loader on [O]!</span>", "<span class='notice'>You use [src]'s automatic loader on [O].</span>")
			var/amtload = 0
			var/rejected = 0
			for (var/obj/item/raw_material/M in O.contents)
				if(M.material?.name != M.initial_material_name)
					rejected += M.amount
					continue
				amtload += M.amount
				src.load_item(M)

			if(rejected)
				boutput(user, "<span class='alert'>[src] rejects [rejected] anomalous ore(s).</span>")
			if (amtload)
				boutput(user, "<span class='notice'>[amtload] ores loaded from [O]!</span>")
			else boutput(user, "<span class='alert'>No ore loaded!</span>")

		else if (isitem(O))
			quickload(user,O)
		else
			..()

		src.updateUsrDialog()

	proc/quickload(var/mob/living/user,var/obj/item/O)
		if (!user || !O)
			return
		if(istype(O,/obj/item/raw_material/))
			var/obj/item/raw_material/R = O
			if(R.material?.name != R.initial_material_name)
				boutput(user, "<span class='alert'>[src] rejects the anomalous ore.</span>")
				return
		user.visible_message("<span class='notice'>[user] begins quickly stuffing [O] into [src]!</span>")
		var/staystill = user.loc
		for(var/obj/item/raw_material/M in view(1,user))
			if (!M)
				continue
			if (M.type != O.type)
				continue
			if(!isSameMaterial(O.material,M.material))
				continue
			if(M.material?.name != M.initial_material_name)
				continue
			if (O.loc == user)
				continue
			if (O in user.contents)
				continue
			src.load_item(M)
			M.set_loc(src)
			playsound(src, sound_load, 40, 1)
			sleep(0.5)
			if (user.loc != staystill) break
		boutput(user, "<span class='notice'>You finish stuffing [O] into [src]!</span>")
		return

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, /obj/item/ore_scoop))
			var/obj/item/ore_scoop/scoop = W
			W = scoop.satchel

		if (istype(W, /obj/item/raw_material/) && src.accept_loading(user))
			var/obj/item/raw_material/R = W
			if(R.material?.name != R.initial_material_name)
				boutput(user, "<span class='alert'>[src] rejects the anomalous ore.</span>")
				return
			user.visible_message("<span class='notice'>[user] loads [W] into the [src].</span>", "<span class='notice'>You load [W] into the [src].</span>")
			src.load_item(W,user)
		else if (istype(W, /obj/item/satchel/mining))
			var/obj/item/satchel/mining/satchel = W
			user.visible_message("<span class='notice'>[user] starts dumping [satchel] into [src].</span>", "<span class='notice'>You start dumping [satchel] into [src].</span>")
			var/amtload = 0
			for (var/obj/item/loading in W.contents)
				var/obj/item/raw_material/R = loading
				if (R.material?.name != R.initial_material_name)
					continue
				src.load_item(R, user)
				amtload++
			satchel.UpdateIcon()
			if (amtload) boutput(user, "<span class='notice'>[amtload] materials loaded from [satchel]!</span>")
			else boutput(user, "<span class='alert'>[satchel] is empty!</span>")

		else
			src.health = max(src.health-W.force,0)
			src.check_health()
			..()

	proc/check_health()
		if(!src.health && !broken)
			src.broken = 1
			src.visible_message("<span class='alert'>[src] breaks!</span>")
			src.icon_state = "ore_storage_unit-broken"

	proc/load_item(var/obj/item/raw_material/R,var/mob/living/user)
		if (!R)
			return
		var/amount_loaded = 0
		if(R.amount == 1)
			R.set_loc(src)
			amount_loaded++
			if (user && R)
				user.u_equip(R)
				R.dropped()
		else if(R.amount>1)
			R.set_loc(src)
			for(R.amount,R.amount > 0, R.amount--)
				var/obj/item/raw_material/new_mat = new R.type
				new_mat.set_loc(src)
				amount_loaded++
			if (user && R)
				user.u_equip(R)
				R.dropped()
			qdel(R)
		update_ore_amount(R.material_name,amount_loaded,R)
		tgui_process.update_uis(src)


	proc/accept_loading(var/mob/user,var/allow_silicon = 0)
		if (!user)
			return 0
		if (src.status & BROKEN || src.status & NOPOWER)
			return 0
		if (!istype(user, /mob/living/))
			return 0
		if (istype(user, /mob/living/silicon) && !allow_silicon)
			return 0
		var/mob/living/L = user
		if (!isalive(L) || L.transforming)
			return 0
		return 1

	proc/update_ore_amount(var/material_name,var/delta,var/obj/item/raw_material/ore)
		if(ores[material_name])
			var/datum/ore_cloud_data/OCD = ores[material_name]
			OCD.amount += delta
			OCD.amount = max(OCD.amount,0)
		else if (delta > 0)
			var/datum/ore_cloud_data/OCD = new /datum/ore_cloud_data
			OCD.amount += delta
			OCD.for_sale = 0
			OCD.price = 0
			OCD.stats = get_ore_properties(ore)
			ores[material_name] = OCD

	proc/get_ore_properties(var/obj/item/raw_material/ore)
		if (!ore?.material)
			return
		if (istype(ore, /obj/item/raw_material/gemstone)) return "varied levels of hardness and density"
		var/list/stat_list = list()
		for(var/datum/material_property/stat in ore.material.properties)
			stat_list += stat.getAdjective(ore.material)
		if (!stat_list.len) return "no properties"
		return stat_list.Join(", ")


	proc/update_ore_for_sale(var/material_name,var/new_for_sale)
		if(ores[material_name])
			var/datum/ore_cloud_data/OCD = ores[material_name]
			if(isnull(new_for_sale))
				OCD.for_sale = !OCD.for_sale
			else
				OCD.for_sale = new_for_sale
		return

	proc/update_ore_price(var/material_name,var/new_price)
		if(ores[material_name])
			var/datum/ore_cloud_data/OCD = ores[material_name]
			OCD.price = max(0,new_price)
		return

	proc/eject_ores(var/ore, var/eject_location, var/ejectamt, var/transmit = 0, var/user as mob)
		var/amount_ejected = 0
		if(!eject_location)
			eject_location = get_output_location()
		for(var/obj/item/raw_material/R in src.contents)
			if (R.material_name == ore)
				R.set_loc(eject_location)
				ejectamt--
				amount_ejected++
				if (ejectamt <= 0)
					break
		if(transmit)
			flick("ore_storage_unit-transmit",src)
			showswirl(eject_location)
			leaveresidual(eject_location)

		update_ore_amount(ore,-amount_ejected)

	proc/get_output_location()
		if (!src.output_target)
			return src.loc

		if (get_dist(src.output_target,src) > 1)
			src.output_target = null
			return src.loc

		if (istype(src.output_target,/obj/storage/crate/))
			var/obj/storage/crate/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C
		if (istype(src.output_target,/obj/storage/cart/))
			var/obj/storage/cart/C = src.output_target
			if (C.locked || C.welded)
				src.output_target = null
				return src.loc
			else
				if (C.open)
					return C.loc
				else
					return C

		if (istype(src.output_target,/turf/))
			return src.output_target

		return src.loc

	ui_interact(mob/user, datum/tgui/ui)
		ui = tgui_process.try_update_ui(user, src, ui)
		if (!ui)
			ui = new(user, src, "Rockbox")
			ui.open()

	ui_data(mob/user)
		var/ore_list = list()
		for(var/O as anything in ores)
			var/datum/ore_cloud_data/OCD = ores[O]

			ore_list += list(list(
				"name" = O,
				"amount" = OCD.amount,
				"price" = OCD.price,
				"forSale" = OCD.for_sale,
				"stats" = OCD.stats
			))

		. = list(
			"ores" = ore_list
		)
	ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
		. = ..()
		if(.)
			return
		switch(action)
			if("dispense-ore")
				eject_ores(params["ore"], null, params["take"])
				. = TRUE
			if("toggle-ore-sell-status")
				var/ore = params["ore"]
				update_ore_for_sale(ore)
				. = TRUE
			if("set-ore-price")
				var/ore = params["ore"]
				var/price = params["newPrice"]
				update_ore_price(ore, price)
				. = TRUE

/obj/machinery/ore_terminal
	name = "Rockbox™ Ore Cloud Access Terminal"
	desc = "A terminal for the rockbox cloud that lets you buy raw materials with just your ID. All sales are final."
	icon = 'icons/obj/mining_cloud_storage.dmi'
	icon_state = "ore_terminal"
	density = 1
	anchored = 1
	mats = 20

	var/obj/item/card/id/scan = null
	var/temp = null
	var/list/dat = list()
	var/net_id = null

	New()
		. = ..()
		src.net_id = generate_net_id(src)
		START_TRACKING

	disposing()
		. = ..()
		STOP_TRACKING

	attack_hand(var/mob/user as mob) //html- if there's anything else that can be gutted, PLEASE do let me know

		var/HTML = {"
		<title>[src.name]</title>
		<title>[src.name]</title>
		<style type='text/css'>

			/* will probaby break chui, dont care */
			body { background: #222; color: white; font-family: Tahoma, sans-serif; }
			a { color: #88f; }

			.l { text-align: left; } .r { text-align: right; } .c { text-align: center; }
			.buttonlink { background: #66c; min-width: 1.1em; height: 1.2em; padding: 0.2em 0.2em; margin-bottom: 2px; border-radius: 4px; font-size: 90%; color: white; text-decoration: none; display: inline-block; vertical-align: middle; }
			thead { background: #555555; }

			table {
				border-collapse: collapse;
				width: 100%;
				}
			td, th { padding: 0.2em; 0.5em; }
			.outline td, .outline th {
				border: 1px solid #666;
			}

			img, a img {
				border: 0;
				}

			#info {
				position: absolute;
				right: 0.5em;
				top: 0;
				width: 25%;
				padding: 0.5em;
				}

			#products {
				position: absolute;
				left: 0;
				top: 0;
				width: 73%;
				padding: 0.25em;
			}

			.queue, .product {
				position: relative;
				display: inline-block;
				width: 12em;
				padding: 0.25em 0.5em;
				border-radius: 5px;
				margin: 0.5em;
				background: #555;
				box-shadow: 3px 3px 0 2px #000;
				}

			.queue {
				vertical-align: middle;
				clear: both;
				}
			.queue .icon {
				float: left;
				margin: 0.2em;
				}
			.product {
				vertical-align: top;
				text-align: center;
				}

			.product .icon {
				display: block;
				height: 64px;
				width: 64px;
				margin: 0.2em auto 0.5em auto;
				-ms-interpolation-mode: nearest-neighbor; /* pixels go cronch */
				}
			.product.disabled {
				background: #333;
				color: #aaa;
			}
			.required {
				display: none;
				}


			.required div {
				position: absolute;
				top: 0;
				left: 0;
				right: 0;
				background: #333;
				border: 1px solid #888888;
				padding: 0.25em 0.5em;
				margin: 0.25em 0.5em;
				font-size: 80%;
				text-align: left;
				border-radius: 5px;
				}
			.mat-missing {
				color: #f66;
			}
		</style>
		<script type="text/javascript">
			function product(ref) {
				window.location = "?src=\ref[src];disp=" + ref;
			}

			function delete_product(ref) {
				window.location = "?src=\ref[src];delete=1;disp=" + ref;
			}
		</script>
		"}

		var/list/dat = list()
		dat +="<B>Scanned Card:</B> <A href='?src=\ref[src];card=1'>([src.scan])</A><BR>"
		if(scan)
			var/datum/db_record/account = null
			account = FindBankAccountByName(src.scan.registered)
			if (account)
				dat+="<B>Current Funds</B>: [account["current_money"]] Credits<br>"
		dat+= src.temp
		dat += "<HR><B>Ores Available for Purchase:</B><br><small>"
		for_by_tcl(S, /obj/machinery/ore_cloud_storage_container)
			if(S.broken)
				continue
			dat += "<B>[S.name] at [get_area(S)]:</B><br>"
			var/list/ores = S.ores
			for(var/ore in ores)
				var/datum/ore_cloud_data/OCD = ores[ore]
				if(!OCD.for_sale || !OCD.amount)
					continue
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(OCD.price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget
				dat += "[ore]: [OCD.amount] ($[OCD.price+taxes+(!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0)]/ore) (<A href='?src=\ref[src];purchase=1;storage=\ref[S];ore=[ore]'>Purchase</A>)<br>"

		dat += "</small><HR>"
		user.Browse(HTML + dat.Join(), "window=manufact;size=1111x600")
		onclose(user, "manufact")
		interact_particle(user,src)


//procs
	proc/scan_card(var/obj/item/I)
		if (istype(I, /obj/item/device/pda2))
			var/obj/item/device/pda2/P = I
			if(P.ID_card)
				I = P.ID_card
		if (istype(I, /obj/item/card/id))
			var/obj/item/card/id/ID = I
			boutput(usr, "<span class='notice'>You swipe the ID card in the card reader.</span>")
			var/datum/db_record/account = null
			account = FindBankAccountByName(ID.registered)
			if(account)
				var/enterpin = usr.enter_pin("Card Reader")
				if (enterpin == ID.pin)
					boutput(usr, "<span class='notice'>Card authorized.</span>")
					src.scan = ID
					return 1
				else
					boutput(usr, "<span class='alert'>Pin number incorrect.</span>")
					src.scan = null
			else
				boutput(usr, "<span class='alert'>No bank account associated with this ID found.</span>")
				src.scan = null
		return 0

	proc/get_output_location()
		return src.loc // fuck you, work


// html interaction
	Topic(href, href_list)
		if ((usr.contents.Find(src) || ((get_dist(src, usr) <= 1 || isAI(usr)) && istype(src.loc, /turf))))
			src.add_dialog(usr)
			if (href_list["card"])
				if (src.scan) src.scan = null
				else
					var/obj/item/I = usr.equipped()
					src.scan_card(I)

			if (href_list["purchase"])
				var/obj/machinery/ore_cloud_storage_container/storage = locate(href_list["storage"])
				var/ore = href_list["ore"]
				var/datum/ore_cloud_data/OCD = storage.ores[ore]
				var/price = OCD.price
				var/taxes = round(max(rockbox_globals.rockbox_client_fee_min,abs(price*rockbox_globals.rockbox_client_fee_pct/100)),0.01) //transaction taxes for the station budget

				if(storage?.broken)
					return

				if(!scan)
					src.temp = {"You have to scan a card in first.<BR>"}
					src.updateUsrDialog()
					return
				else
					src.temp = null
				if (src.scan.registered in FrozenAccounts)
					boutput(usr, "<span class='alert'>Your account cannot currently be liquidated due to active borrows.</span>")
					return
				var/datum/db_record/account = null
				account = FindBankAccountByName(src.scan.registered)
				if (account)
					var/quantity = 1
					quantity = max(0, input("How many units do you want to purchase?", "Ore Purchase", null, null) as num)
					if(!isnum_safe(quantity))
						return

					if(OCD.amount >= quantity && quantity > 0)
						var/subtotal = round(price * quantity)
						var/sum_taxes = round(taxes * quantity)
						var/rockbox_fees = (!rockbox_globals.rockbox_premium_purchased ? rockbox_globals.rockbox_standard_fee : 0) * quantity
						var/total = subtotal + sum_taxes + rockbox_fees
						if(account["current_money"] >= total)
							account["current_money"] -= total
							storage.eject_ores(ore, get_output_location(), quantity, transmit=1, user=usr)

							 // This next bit is stolen from PTL Code
							var/list/accounts = \
								data_core.bank.find_records("job", "Chief Engineer") + \
								data_core.bank.find_records("job", "Chief Engineer") + \
								data_core.bank.find_records("job", "Engineer")


							var/datum/signal/minerSignal = get_free_signal()
							minerSignal.source = src
							//any non-divisible amounts go to the shipping budget
							var/leftovers = 0
							if(length(accounts))
								leftovers = subtotal % length(accounts)
								var/divisible_amount = subtotal - leftovers
								if(divisible_amount)
									var/amount_per_account = divisible_amount/length(accounts)
									for(var/datum/db_record/t as anything in accounts)
										t["current_money"] += amount_per_account
									minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [amount_per_account] credits earned from Rockbox&trade; sale, deposited to your account.")
							else
								leftovers = subtotal
								minerSignal.data = list("address_1"="00000000", "command"="text_message", "sender_name"="ROCKBOX&trade;-MAILBOT",  "group"=list(MGD_MINING, MGA_SALES), "sender"=src.net_id, "message"="Notification: [leftovers + sum_taxes] credits earned from Rockbox&trade; sale, deposited to the shipping budget.")
							wagesystem.shipping_budget += (leftovers + sum_taxes)
							SEND_SIGNAL(src, COMSIG_MOVABLE_POST_RADIO_PACKET, minerSignal)

							src.temp = {"Enjoy your purchase!<BR>"}
						else
							src.temp = {"You don't have enough dosh, bucko.<BR>"}
					else
						if(quantity > 0)
							src.temp = {"I don't have that many for sale, champ.<BR>"}
						else
							src.temp = {"Enter some actual valid number, you doofus!<BR>"}
				else
					src.temp = {"That card doesn't have an account anymore, you might wanna get that checked out.<BR>"}

			src.updateUsrDialog()
		return
