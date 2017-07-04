/turf
	icon = 'icons/turf/floors.dmi'
	level = 1.0

	var/intact = 1
	var/cancable = 0
	var/baseturf = /turf/space

	//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

	//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

	//Properties for both
	var/temperature = T20C

	var/holy = 0 //Will be probably used for supernatural shit
	var/shuttle = 0 //If it counts as a shuttle tile for specific shuttles

	var/blocks_air = 0

	var/PathNode/PNode = null //associated PathNode in the A* algorithm

	var/slowdown = 0 //negative for faster, positive for slower

	flags = 0

	var/dynamic_lighting = 1

/turf/New()
	..()
	turfs.Add(src)
	for(var/atom/movable/AM in src)
		Entered(AM)
	set_opacity(src.opacity)
	reconsider_lights()
	return

// Adds the adjacent turfs to the current atmos processing
/turf/Del()
	turfs.Remove(src)
	set_opacity(0)
	reconsider_lights()
	lighting_overlay = null
	for(var/direction in cardinal)
		if(atmos_adjacent_turfs & direction)
			var/turf/simulated/T = get_step(src, direction)
			if(istype(T))
				SSair.add_to_active(T)
	..()

/turf/Destroy()
	return QDEL_HINT_HARDDEL_NOW

/turf/attack_hand(mob/user as mob)
	user.Move_Pulled(src)

/turf/attackby(obj/item/C, mob/user, params)
	if(cancable && istype(C, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/coil = C
		for(var/obj/structure/cable/LC in src)
			if((LC.d1==0)||(LC.d2==0))
				LC.attackby(C,user)
				return
		coil.place_turf(src, user)
		return 1

	return 0

/turf/Enter(atom/movable/mover as mob|obj, atom/forget as mob|obj|turf|area)
	if (!mover)
		return 1
	// First, make sure it can leave its square
	if(isturf(mover.loc))
		// Nothing but border objects stop you from leaving a tile, only one loop is needed
		for(var/obj/obstacle in mover.loc)
			if(!obstacle.CheckExit(mover, src) && obstacle != mover && obstacle != forget)
				mover.Bump(obstacle, 1)
				return 0

	var/list/large_dense = list()
	//Next, check objects to block entry that are on the border
	for(var/atom/movable/border_obstacle in src)
		if(border_obstacle.flags&ON_BORDER)
			if(!border_obstacle.CanPass(mover, mover.loc, 1) && (forget != border_obstacle))
				mover.Bump(border_obstacle, 1)
				return 0
		else
			large_dense += border_obstacle

	//Then, check the turf itself
	if (!src.CanPass(mover, src))
		mover.Bump(src, 1)
		return 0

	//Finally, check objects/mobs to block entry that are not on the border
	for(var/atom/movable/obstacle in large_dense)
		if(!obstacle.CanPass(mover, mover.loc, 1) && (forget != obstacle))
			mover.Bump(obstacle, 1)
			return 0
	return 1 //Nothing found to block so return success!

/turf/Entered(atom/movable/M)
	if(ismob(M))
		var/mob/O = M
		if(!O.lastarea)
			O.lastarea = get_area(O.loc)
//		O.update_gravity(O.mob_has_gravity())

	var/loopsanity = 100
	for(var/atom/A in range(1))
		if(loopsanity == 0)
			break
		loopsanity--
		A.HasProximity(M, 1)

/turf/proc/is_plasteel_floor()
	return 0
/turf/proc/return_siding_icon_state()		//used for grass floors, which have siding.
	return 0

/turf/proc/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(src.intact)

// override for space turfs, since they should never hide anything
/turf/space/levelupdate()
	for(var/obj/O in src)
		if(O.level == 1)
			O.hide(0)

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if(L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(var/path)
	if(!path)			return
	if(path == type)	return src
	var/list/old_affecting_lights = affecting_lights
	var/atom/movable/lighting_overlay/old_lighting_overlay = lighting_overlay


	var/old_baseturf = baseturf
	SSair.remove_from_active(src)

	var/turf/W = new path(src)
	W.baseturf = old_baseturf
	W.affecting_lights = old_affecting_lights
	W.lighting_overlay = old_lighting_overlay
	if(!istype(W, /turf/space))
		W.lighting_build_overlays()
	else
		W.lighting_clear_overlays()


	if(istype(W, /turf/simulated))
		W:Assimilate_Air()
		W.RemoveLattice()

	for(var/turf/space/S in range(W,1))
		S.update_starlight()

	W.levelupdate()
	W.CalculateAdjacentTurfs()
	W.update_overlay()


	universe.OnTurfChange(W)
	return W

//////Assimilate Air//////
/turf/simulated/proc/Assimilate_Air()
	if(air)
		var/aoxy = 0//Holders to assimilate air from nearby turfs
		var/anitro = 0
		var/aco = 0
		var/atox = 0
		var/atemp = 0
		var/turf_count = 0

		for(var/direction in cardinal)//Only use cardinals to cut down on lag
			var/turf/T = get_step(src,direction)
			if(istype(T,/turf/space))//Counted as no air
				turf_count++//Considered a valid turf for air calcs
				continue
			else if(istype(T,/turf/simulated/floor))
				var/turf/simulated/S = T
				if(S.air)//Add the air's contents to the holders
					aoxy += S.air.oxygen
					anitro += S.air.nitrogen
					aco += S.air.carbon_dioxide
					atox += S.air.toxins
					atemp += S.air.temperature
				turf_count ++
		air.oxygen = (aoxy/max(turf_count,1))//Averages contents of the turfs, ignoring walls and the like
		air.nitrogen = (anitro/max(turf_count,1))
		air.carbon_dioxide = (aco/max(turf_count,1))
		air.toxins = (atox/max(turf_count,1))
		air.temperature = (atemp/max(turf_count,1))//Trace gases can get bant
		SSair.add_to_active(src)

/turf/proc/ReplaceWithLattice()
	src.ChangeTurf(baseturf)
	if(istype(src, /turf/space))
		new /obj/structure/lattice(locate(src.x, src.y, src.z) )

/turf/proc/ReplaceWithCatwalk()
	src.ChangeTurf(baseturf)
	if(istype(src, /turf/space))
		src.cancable = 1//so cables can be laid
		new /obj/structure/lattice/catwalk(locate(src.x, src.y, src.z) )

/turf/proc/phase_damage_creatures(damage,mob/U = null)//>Ninja Code. Hurts and knocks out creatures on this turf //NINJACODE
	for(var/mob/living/M in src)
		if(M==U)
			continue//Will not harm U. Since null != M, can be excluded to kill everyone.
		M.adjustBruteLoss(damage)
		M.Paralyse(damage/5)
	for(var/obj/mecha/M in src)
		M.take_damage(damage*2, "brute")

/turf/proc/Bless()
	flags |= NOJAUNT

/turf/storage_contents_dump_act(obj/item/weapon/storage/src_object, mob/user)
	for(var/obj/item/I in src_object)
		src_object.remove_from_storage(I, src) //No check needed, put everything inside
	return 1

//////////////////////////////
//Distance procs
//////////////////////////////

//Distance associates with all directions movement
/turf/proc/Distance(var/turf/T)
	return get_dist(src,T)

//  This Distance proc assumes that only cardinal movement is
//  possible. It results in more efficient (CPU-wise) pathing
//  for bots and anything else that only moves in cardinal dirs.
/turf/proc/Distance_cardinal(turf/T)
	if(!src || !T) return 0
	return abs(src.x - T.x) + abs(src.y - T.y)

////////////////////////////////////////////////////

/turf/handle_fall(mob/faller, forced)
	faller.lying = pick(90, 270)
	if(!forced)
		return
	if(has_gravity(src))
		playsound(src, "bodyfall", 50, 1)

/turf/handle_slip(mob/slipper, s_amount, w_amount, obj/O, lube)
	if(has_gravity(src))
		var/mob/living/carbon/M = slipper
		if (M.m_intent=="walk" && (lube&NO_SLIP_WHEN_WALKING))
			return 0
		if(!M.lying && (M.status_flags & CANWEAKEN)) // we slip those who are standing and can fall.
			var/olddir = M.dir
			M.Stun(s_amount)
			M.Weaken(w_amount)
			M.stop_pulling()
			if(lube&SLIDE)
				for(var/i=1, i<5, i++)
					spawn (i)
						step(M, olddir)
						M.spin(1,1)
				if(M.lying) //did I fall over?
					M.adjustBruteLoss(2)
			if(lube&BLUESPACE_SLIPPERY)
				do_teleport(M, get_turf(M), 3, asoundin = 'sound/effects/phasein.ogg')
			if(O)
				M << "<span class='notice'>You slipped on the [O.name]!</span>"
			else
				M << "<span class='notice'>You slipped!</span>"
			playsound(M.loc, 'sound/misc/slip.ogg', 50, 1, -3)
			return 1
	return 0 // no success. Used in clown pda and wet floors

/turf/singularity_act()
	if(intact)
		for(var/obj/O in contents) //this is for deleting things like wires contained in the turf
			if(O.level != 1)
				continue
			if(O.invisibility == 101)
				O.singularity_act()
	ChangeTurf(/turf/space)
	return(2)

/turf/rift_act(rift)
	var/turf/T = src
	var/obj/singularity/narsie/large/exit/R = rift
	var/dist = get_dist(T, R)
	if (dist <= R.consume_range && T.density)
		T.density = 0

	for (var/atom/movable/AM in T.contents)
		if (AM == R) // This is the snowflake.
			continue

		if (dist <= R.consume_range)
			R.consume(AM)
			continue


/turf/indestructible
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	density = 1
	blocks_air = 1
	opacity = 1

/turf/indestructible/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen.dmi'
	icon_state = "title"
	layer = FLY_LAYER

/turf/indestructible/riveted
	icon_state = "riveted"

/turf/indestructible/riveted/New()
	..()
	if(smooth)
		smooth_icon(src)
		icon_state = ""
/turf/indestructible/riveted/uranium
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium"
	smooth = 1
	canSmoothWith = null

/turf/indestructible/abductor
	icon_state = "alien1"
	shuttle = 1

/turf/indestructible/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0

/turf/indestructible/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/Doorele.dmi'
	icon_state = "door_closed"