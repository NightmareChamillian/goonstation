/* file for all objects pertaining to sawfly that don't really go anywhere else
 -->Includes:
-All grenades- cluster and normal
-The remote
-The limb that does the damage

-->Things it DOES NOT include that are sawfly-related, and where they can be found:
-The pouch of sawflies for nukies at the bottom of ammo pouches.dm
-Their AI, which can be found in mob/living/critter/ai/sawflyai.dm
-The critter itself, which is in mob/living/critter/sawfly.dm
*/

// -------------------grenades-------------
/obj/item/old_grenade/sawfly

	name = "Compact sawfly"
	desc = "A self-deploying antipersonnel robot. It's folded up and offline..."
	det_time = 1.5 SECONDS
	throwforce = 7
	icon = 'icons/obj/items/sawfly.dmi'
	icon_state = "sawfly"
	icon_state_armed = "sawflyunfolding"
	sound_armed = 'sound/machines/sawflyrev.ogg'

	is_dangerous = TRUE
	is_syndicate = TRUE
	issawfly = TRUE //used to tell the sawfly remote if it can or can't prime() the grenade
	mats = list("MET-2"=7, "CON-1"=7, "POW-1"=5)
	contraband = 2
	overlays = null
	state = 0

	//used in dictating behavior when deployed from grenade
	var/mob/living/critter/robotic/sawfly/heldfly = null
	var/obj/item/organ/brain/currentbrain = null
	var/mob/currentuser = null
	var/isopen = FALSE
	var/playercontrolled = FALSE

	attack_self(mob/user as mob) //full on overriding priming in hopes of no jank
		logGrenade(user)
		user = currentuser
		if(isopen)
			if(playercontrolled)
				if(tgui_alert(src, "Are you sure you want to eject the conciousness?", "Sawfly Brain", list("Yes", "No")) == "Yes")
					ejectbrain(currentbrain)
					return
			else
				return //eventually this will be something, but for now simply return
		else
			boutput(user, "<span class='alert'>You prime [src]! [det_time/10] seconds!</span>")
			icon_state = icon_state_armed
			playsound(src.loc, src.sound_armed, 75, 1, -3)
			src.add_fingerprint(user)
			SPAWN(src.det_time)
				if (src) prime(user)
				return


	prime()
		var/turf/T =  get_turf(src)
		if (T)
			heldfly.set_loc(T)
			heldfly.is_npc = TRUE
			heldfly.isgrenade = FALSE
		if(!playercontrolled)
			if(issawflybuddy(currentuser))
				heldfly.ai = new /datum/aiHolder/sawfly(heldfly)
			else
				heldfly.ai = new /datum/aiHolder/wanderer(heldfly)
		else
			heldfly.ai = null
		qdel(src)

	attackby(obj/item/W, mob/user)

		if (isscrewingtool(W)) //basic open/close actions
			if(isopen)
				isopen = FALSE
				overlays -= "open-overlay"
			else
				isopen = TRUE
				overlays += "open-overlay"
		if((istype(W, /obj/item/organ/brain/latejoin)) && isopen)
			insertbrain( W, src, heldfly)
			boutput(user, "You insert the [W] into the [src]. Please wait a maximum of 40 seconds for the [heldfly]'s systems to initalize.")

	proc/insertbrain( obj/item/brain, obj/item/sawflygrenade, mob/living/user)
		src.currentbrain = brain
		var/ghost_delay = 100
		var/list/text_messages = list()
		var/place = get_turf(src)
		var/mob/living/critter/robotic/sawfly/oursawfly = null

		text_messages.Add("Would you like to be resurrected as a traitor's sawfly? You may be randomly selected from the list of candidates.")
		text_messages.Add("You are eligible to be resurrected as a traitor's sawfly. You have [ghost_delay / 10] seconds to respond to the offer.")
		text_messages.Add("You have been added to the list of eligible candidates. Please wait for the game to choose, good luck!")

		var/list/datum/mind/candidates = dead_player_list(1, ghost_delay, text_messages, allow_dead_antags = 1)
		if (!candidates)
			sawflygrenade.visible_message("<span class='alert'> The [src.heldfly] ejects the [currentbrain] and beeps: \" could not initialize consciousness pool! Please try again later. \"")
			src.ejectbrain(currentbrain)
			return

		var/datum/mind/lucky_dude = pick(candidates)
		playsound(src.loc, 'sound/machines/tone_beep.ogg', 30, FALSE) //intentionally use the same sound mechscanners do to avoid detection
		boutput(user, "<span class='success'> The [oursawfly] emits a pleasant chime as begins to glow with sapience!")

		SPAWN(2 SECONDS) //wait two seconds for recognition
			if (lucky_dude) // incredibly hacky workaround time- I have just not had any luck transfering the mind to the existing sawfly in the grenade.
				src.set_loc(get_turf(src))
				oursawfly = new /mob/living/critter/robotic/sawfly(place)
				oursawfly.name = src.name
				lucky_dude.transfer_to(oursawfly)
				brain.set_loc(oursawfly)
				oursawfly.foldself()
				lucky_dude.special_role = ROLE_SAWFLY
				boutput(oursawfly, "<h1><font color=red>You have awoken as a sawfly! Your duty is to serve your master to the best of your ability!")
				oursawfly.antagonist_overlay_refresh(1, 0)
				user.put_in_hand_or_drop(oursawfly.ourgrenade) //certified ref moment
				qdel(src)
			else
				sawflygrenade.visible_message("<span class='alert'>The [oursawfly] makes an upset beep! Something went wrong!")
				src.ejectbrain(currentbrain)
				return
		if(!oursawfly.mind)
			sawflygrenade.visible_message("<h1>Something went SUPER wrong!!! Contact #imcoder, make a bug report, and/or ping Millian!")

	proc/ejectbrain(/obj/item/organ/brain/currentbrain)
		if(!isopen)
			isopen = TRUE
		if(currentbrain)
			if(currentbrain.owner)
				boutput(currentbrain.owner, "You have been booted from your sawfly and are now a disconnected ghost!")
				SPAWN(1) //give them a second to read
					heldfly.ghostize()
					currentbrain.owner = null

			currentbrain.set_loc(get_turf(src))
			src.playercontrolled = FALSE
/datum/random_event/major/antag/sawflytest
	name = "Sawfly grenade test"
	disabled = TRUE
	var/place = null
	var/obj/item/old_grenade/sawfly/firsttime/baby = null
	var/obj/item/organ/brain/latejoin/brain = null

	event_effect()
		place = pick_landmark(LANDMARK_LATEJOIN)
		baby = new /obj/item/old_grenade/sawfly(place)
		brain = new /obj/item/organ/brain/latejoin(place)
		SPAWN(1)
			baby.insertbrain(brain, baby, baby.heldfly)

/obj/item/old_grenade/sawfly/firsttime//super important- traitor uplinks and sawfly pouches use this specific version
	New()

		heldfly = new /mob/living/critter/robotic/sawfly(src.loc)
		heldfly.ourgrenade = src
		heldfly.set_loc(src)
		..()

/obj/item/old_grenade/sawfly/firsttime/withremote // for traitor menu
	New()
		new /obj/item/remote/sawflyremote(src.loc)
		..()


/obj/item/old_grenade/spawner/sawflycluster
	name = "Cluster sawfly"
	desc = "A whole lot of little angry robots at the end of the stick, ready to shred whoever stands in their way."
	det_time = 2 SECONDS // more reasonable reaction time

	force = 7
	throwforce = 10
	stamina_damage = 35
	stamina_cost = 20
	stamina_crit_chance = 35
	sound_armed = 'sound/machines/sawflyrev.ogg'
	icon_state = "clusterflyA"
	icon_state_armed = "clusterflyA1"
	payload = /mob/living/critter/robotic/sawfly/ai_controlled
	is_dangerous = TRUE
	is_syndicate = TRUE
	issawfly = TRUE
	contraband = 5

	New()
		..()
		src.setItemSpecial(/datum/item_special/swipe)
		new /obj/item/remote/sawflyremote(src.loc)
		if (prob(50)) // give em some sprite variety
			icon_state = "clusterflyB"
			icon_state_armed = "clusterflyB1"

// -------------------controller---------------

/obj/item/remote/sawflyremote
	name = "Sawfly remote"
	desc = "A small device that can be used to fold or deploy sawflies in range."
	w_class = W_CLASS_TINY
	flags = FPRINT | TABLEPASS
	object_flags = NO_GHOSTCRITTER
	icon = 'icons/obj/items/device.dmi'
	inhand_image_icon = 'icons/mob/inhand/tools/omnitool.dmi'
	icon_state = "sawflycontr"

	attack_self(mob/user as mob)
		for (var/mob/living/critter/robotic/sawfly/S in range(get_turf(src), 5)) // folds active sawflies
			SPAWN(0.1 SECONDS)
				S.foldself()

		for(var/obj/item/old_grenade/S in range(get_turf(src), 4)) // unfolds passive sawflies
			if (S.issawfly == TRUE) //check if we're allowed to prime the grenade
				if (istype(S, /obj/item/old_grenade/sawfly))
					S.visible_message("<span class='alert'>[S] suddenly springs open as its engine purrs to a start!</span>")
					S.icon_state = "sawflyunfolding"
					SPAWN(S.det_time)
						if(S)
							S.prime()

				if (istype(S, /obj/item/old_grenade/spawner/sawflycluster))
					S.visible_message("<span class='alert'>The [S] suddenly begins beeping as it is primed!</span>")
					if (S.icon_state=="clusterflyA")
						S.icon_state = "clusterflyA1"
					else
						S.icon_state = "clusterflyB1"
					SPAWN(S.det_time)
						if(S)
							S.prime()
			else
				continue


// ---------------limb---------------
/datum/limb/sawfly_blades


	//due to not having intent hotkeys and also being AI controlled we only need the one proc
	harm(mob/living/target, var/mob/living/critter/robotic/sawfly/user) //will this cause issues down the line when someone eventually makes a child of this? hopefully not
		if(!ON_COOLDOWN(user, "sawfly_attackCD", 0.8 SECONDS))
			if(issawflybuddy(target))
				return
			user.visible_message("<b class='alert'>[user] [pick(list("gouges", "carves", "cleaves", "lacerates", "shreds", "cuts", "tears", "saws", "mutilates", "hacks", "slashes",))] [target]!</b>")
			playsound(user, 'sound/machines/chainsaw_green.ogg', 50, 1)
			if(prob(3))
				user.communalbeep()
			take_bleeding_damage(target, null, 10, DAMAGE_STAB)
			random_brute_damage(target, 14, TRUE)
			target.was_harmed(user)

	attack_hand(atom/target, var/mob/user, var/reach)
		if (ismob(target))
			..()
		..()
//sawfly ability
/datum/targetable/critter/sawflydeploy
	name = "(Un)deploy"
	desc = "Toggle your mob/item state! Can also be used to escape containers."
	icon_state = "sawfly-deploy"
	cooldown = 10


	cast(mob/target)

		var/mob/living/critter/robotic/sawfly/M = holder.owner



		if(M.isgrenade == TRUE) //we're in a grenade, time to un-grenade ourselfes!
			if(istype(M.ourgrenade.loc, /obj/item/storage))
				actions.start(/datum/action/bar/private/icon/sawflyescape, src)
				return
			else
				M.visible_message("<span class='alert'>[M] suddenly springs open as its engine purrs to a start!</span>")
				playsound(M, pick(M.beeps), 40, 1)
				if(get_turf(M))
					M.ourgrenade.prime()
		else
			M.foldself()

/datum/action/bar/private/icon/sawflyescape
	duration = 200
	interrupt_flags = INTERRUPT_MOVE | INTERRUPT_ACT | INTERRUPT_STUNNED | INTERRUPT_ACTION
	id = "sawflyescape"
	icon_state = "backpack"
	icon = 'icons/mob/inhand/hand_storage.dmi'
	New(var/dur)
		duration = dur
		..()

	onStart()
		..()

		var/mob/living/critter/robotic/sawfly/M = owner
		boutput(M, "<span class='notice'>You start to make your way out of [M.loc].</span>")

	onInterrupt(var/flag)
		..()
		boutput(owner, "<span class='alert'>Your attempt to escape was interrupted!</span>")
		if(!(flag & INTERRUPT_ACTION))
			src.resumable = FALSE

	onEnd()
		..()
		var/mob/living/critter/robotic/sawfly/M = owner
		M.ourgrenade.loc = get_turf(M.ourgrenade.loc)//thanks to the precondition for calling this, we can be sure their loc is going to be in a container
