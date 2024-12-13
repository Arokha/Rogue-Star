//RS Edit Start
#define ROBOT_HAS_SPEED_SPRITE 0x1	//Ex:	/obj/item/borg/combat/mobility Replaces old has_speed_sprite
#define ROBOT_HAS_SHIELD_SPRITE 0x2	//Ex:	/obj/item/borg/combat/shield Replaces old has_shield_sprite
#define ROBOT_HAS_SHIELD_SPEED_SPRITE 0x4	//Ex: Has a sprite for when both is activated AND has /obj/item/borg/combat/mobility
#define ROBOT_HAS_LASER_SPRITE 0x8	//Ex:	/obj/item/weapon/gun/energy/retro/mounted Replaces old has_laser_sprite
#define ROBOT_HAS_TASER_SPRITE 0x10	//Ex:	/obj/item/weapon/gun/energy/taser/mounted/cyborg Replaces old has_taser_sprite
#define ROBOT_HAS_GUN_SPRITE 0x20	//Ex:	Has a general gun sprite. Replaces old has_gun_sprite
/// USE THESE SPARINGLY, ADDING TO THESE LISTS EXTENSIVELY AND PILING ON MORE TO LISTS /CAN/ BE RESOURCE INTENSIVE.
/// The only reason it's used here is for two reasons.
/// 1: Borg code was an abomination. A bunch of borgs used fancy snowflake code for what gun they all used instead of having a standardized gun.
/// 2: If I made the below code when it checks for what gun you have to add the overlay, it looks absolutely AWFUL (see the commented out ourborg.has_active_type below for example of how bad it looks)
/// Borg code when it comes to laser/taser/gun overlays needs to be revamped sometime in the future to make it even LESS resource intensive, but I don't feel like modularizing every single borg gun in the game.
/// So if you come across this and want to make it better, you can. And I implore you to do exactly that. Maybe one day we can have a gun/energy/borg that has a bunch of different effects and variable damage types and whatnot.
/// But that's outside the scope of the PR this was built for.
var/list/borg_lasers = list(/obj/item/weapon/gun/energy/retro/mounted,/obj/item/weapon/gun/energy/laser/mounted)
var/list/borg_tasers = list(/obj/item/weapon/gun/energy/taser/mounted/cyborg,/obj/item/weapon/gun/energy/taser/xeno/robot)
var/list/borg_guns = list(/obj/item/weapon/gun/energy/laser/mounted,/obj/item/weapon/gun/energy/taser/mounted/cyborg/ertgun,/obj/item/weapon/gun/energy/lasercannon/mounted,/obj/item/weapon/gun/energy/dakkalaser)
//RS Edit End

/datum/robot_sprite
	var/name
	var/module_type
	var/default_sprite = FALSE
	var/sprite_flags //RS Edit Start

	var/sprite_icon
	var/sprite_icon_state
	var/sprite_hud_icon_state

	var/has_eye_sprites = TRUE
	var/has_eye_light_sprites = FALSE
	var/has_custom_open_sprites = FALSE
	var/has_vore_belly_sprites = FALSE
	var/has_vore_belly_resting_sprites = FALSE
	var/has_sleeper_light_indicator = FALSE //Moved here because there's no reason lights should be limited to just medical borgs. Or redefined every time they ARE used.
	var/max_belly_size = 1 //If larger bellies are made, set this to the value of the largest size
	var/has_rest_sprites = FALSE
	var/list/rest_sprite_options
	var/has_dead_sprite = FALSE
	var/has_dead_sprite_overlay = FALSE
	var/has_extra_customization = FALSE
	var/has_custom_equipment_sprites = FALSE
	var/vis_height = 32
	var/pixel_x = 0

	var/is_whitelisted = FALSE
	var/whitelist_ckey

/// Determines if the borg has the proper flags to show an overlay.
/datum/robot_sprite/proc/sprite_flag_check(var/flag_to_check)
	return (sprite_flags & flag_to_check)

/datum/robot_sprite/proc/handle_extra_icon_updates(var/mob/living/silicon/robot/ourborg)
	if(sprite_flag_check(ROBOT_HAS_SHIELD_SPEED_SPRITE))
		if(ourborg.has_active_type(/obj/item/borg/combat/shield) && ourborg.has_active_type(/obj/item/borg/combat/mobility))
			ourborg.add_overlay("[sprite_icon_state]-speed_shield")
			return //Stop here. No need to add more overlays. Nothing else is compatible.

	if(sprite_flag_check(ROBOT_HAS_SPEED_SPRITE) && ourborg.has_active_type(/obj/item/borg/combat/mobility))
		ourborg.icon_state = "[sprite_icon_state]-roll"
		return //Stop here. No need to add more overlays. Nothing else is compatible.

	if(sprite_flag_check(ROBOT_HAS_SHIELD_SPRITE))
		if(ourborg.has_active_type(/obj/item/borg/combat/shield))
			var/obj/item/borg/combat/shield/shield = locate() in ourborg
			if(shield && shield.active)
				ourborg.add_overlay("[sprite_icon_state]-shield")

	if(sprite_flag_check(ROBOT_HAS_GUN_SPRITE) && (ourborg.has_active_type_list(borg_guns)))
		ourborg.add_overlay("[sprite_icon_state]-gun")
	if(sprite_flag_check(ROBOT_HAS_LASER_SPRITE) && (ourborg.has_active_type_list(borg_lasers)))
		ourborg.add_overlay("[sprite_icon_state]-laser")
	if(sprite_flag_check(ROBOT_HAS_TASER_SPRITE) && (ourborg.has_active_type_list(borg_tasers)))
		ourborg.add_overlay("[sprite_icon_state]-taser")
	return

/datum/robot_sprite/proc/get_belly_overlay(var/mob/living/silicon/robot/ourborg, var/size = 1)
	//Size
	if(has_sleeper_light_indicator)
		var/sleeperColor = "g"
		if(ourborg.sleeper_state == 1) // Is our belly safe, or gurgling cuties?
			sleeperColor = "r"
		return "[sprite_icon_state]-sleeper-[size]-[sleeperColor]"
	return "[sprite_icon_state]-sleeper-[size]"

/datum/robot_sprite/proc/get_belly_resting_overlay(var/mob/living/silicon/robot/ourborg, var/size = 1)
	if(!(ourborg.rest_style in rest_sprite_options))
		ourborg.rest_style = "Default"
	switch(ourborg.rest_style)
		if("Sit")
			return "[get_belly_overlay(ourborg, size)]-sit"
		if("Bellyup")
			return "[get_belly_overlay(ourborg, size)]-bellyup"
		else
			return "[get_belly_overlay(ourborg, size)]-rest"

/datum/robot_sprite/proc/get_eyes_overlay(var/mob/living/silicon/robot/ourborg)
	if(!(ourborg.resting && has_rest_sprites))
		return "[sprite_icon_state]-eyes"
	else
		return

/datum/robot_sprite/proc/get_eye_light_overlay(var/mob/living/silicon/robot/ourborg)
	if(!(ourborg.resting && has_rest_sprites))
		return "[sprite_icon_state]-lights"
	else
		return

/datum/robot_sprite/proc/get_rest_sprite(var/mob/living/silicon/robot/ourborg)
	if(!(ourborg.rest_style in rest_sprite_options))
		ourborg.rest_style = "Default"
	switch(ourborg.rest_style)
		if("Sit")
			return "[sprite_icon_state]-sit"
		if("Bellyup")
			return "[sprite_icon_state]-bellyup"
		else
			return "[sprite_icon_state]-rest"

/datum/robot_sprite/proc/get_dead_sprite(var/mob/living/silicon/robot/ourborg)
	return "[sprite_icon_state]-wreck"

/datum/robot_sprite/proc/get_dead_sprite_overlay(var/mob/living/silicon/robot/ourborg)
	return "wreck-overlay"

/datum/robot_sprite/proc/get_open_sprite(var/mob/living/silicon/robot/ourborg)
	if(!ourborg.opened)
		return
	if(ourborg.wiresexposed)
		. = "openpanel_w"
	else if(ourborg.cell)
		. = "openpanel_c"
	else
		. = "openpanel_nc"

	if(has_custom_open_sprites)
		. = "[sprite_icon_state]-[.]"

	return

/datum/robot_sprite/proc/handle_extra_customization(var/mob/living/silicon/robot/ourborg)
	return

/datum/robot_sprite/proc/do_equipment_glamour(var/obj/item/weapon/robot_module/module)
	return

// Dogborgs and not-dogborgs that use dogborg stuff. Oh no.
// Not really necessary to be used by any specific sprite actually, even newly added dogborgs.
// Mostly a combination of all features dogborgs had prior to conversion to datums for convinience of conversion itself.

/datum/robot_sprite/dogborg
	has_vore_belly_sprites = TRUE
	has_rest_sprites = TRUE
	rest_sprite_options = list("Default", "Sit", "Bellyup")
	has_dead_sprite = TRUE
	has_dead_sprite_overlay = TRUE
	has_custom_equipment_sprites = TRUE
	pixel_x = -16
/* //Does not need to be dogborg-only, letting all borgs use these -Reo
/datum/robot_sprite/dogborg/get_rest_sprite(var/mob/living/silicon/robot/ourborg)
	if(!(ourborg.rest_style in rest_sprite_options))
		ourborg.rest_style = "Default"
	switch(ourborg.rest_style)
		if("Sit")
			return "[sprite_icon_state]-sit"
		if("Bellyup")
			return "[sprite_icon_state]-bellyup"
		else
			return "[sprite_icon_state]-rest"

/datum/robot_sprite/dogborg/get_belly_overlay(var/mob/living/silicon/robot/ourborg)
	return "[sprite_icon_state]-sleeper"
*/
/datum/robot_sprite/dogborg/do_equipment_glamour(var/obj/item/weapon/robot_module/module)
	if(!has_custom_equipment_sprites)
		return

	var/obj/item/weapon/tool/crowbar/cyborg/C = locate() in module.modules
	if(C)
		C.name = "puppy jaws"
		C.desc = "The jaws of a small dog. Still strong enough to pry things."
		C.icon = 'icons/mob/dogborg_vr.dmi'
		C.icon_state = "smalljaws_textless"
		C.hitsound = 'sound/weapons/bite.ogg'
		C.attack_verb = list("nibbled", "bit", "gnawed", "chomped", "nommed")

	var/obj/item/device/boop_module/D = locate() in module.modules
	if(D)
		D.name = "boop module"
		D.desc = "The BOOP module, a simple reagent and atmosphere scanner."
		D.icon = 'icons/mob/dogborg_vr.dmi'
		D.icon_state = "nose"
		D.attack_verb = list("nuzzled", "nosed", "booped")

	var/obj/item/device/robot_tongue/E = locate() in module.modules
	if(E)
		E.name = "synthetic tongue"
		E.desc = "Useful for slurping mess off the floor before affectionately licking the crew members in the face."
		E.icon_state = "synthtongue"
		E.hitsound = 'sound/effects/attackblob.ogg'
		E.dogfluff = TRUE

	var/obj/item/weapon/dogborg/pounce/SA = locate() in module.emag
	if(SA)
		SA.name = "pounce"
		SA.icon_state = "pounce"

/datum/robot_sprite/dogborg/tall
	has_dead_sprite_overlay = FALSE
	vis_height = 64


// Default module sprite

/datum/robot_sprite/default
	name = DEFAULT_ROBOT_SPRITE_NAME
	module_type = "Default"
	sprite_icon = 'icons/mob/robot/default.dmi'
	sprite_icon_state = "default"
	default_sprite = TRUE
