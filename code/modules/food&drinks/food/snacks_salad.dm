//this category is very little but I think that it has great potential to grow
////////////////////////////////////////////SALAD////////////////////////////////////////////
/obj/item/weapon/reagent_containers/food/snacks/salad
	icon = 'icons/obj/food/soupsalad.dmi'
	trash = /obj/item/weapon/reagent_containers/glass/bowl
	bitesize = 3
	w_class = 3
	list_reagents = list("nutriment" = 7, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/salad/New()
	..()
	eatverb = pick("crunch","devour","nibble","gnaw","gobble","chomp")

/obj/item/weapon/reagent_containers/food/snacks/salad/aesirsalad
	name = "\improper Aesir salad"
	desc = "Probably too incredible for mortal men to fully enjoy."
	icon_state = "aesirsalad"
	list_reagents = list("omnizine" = 8, "vitamin" = 6)

/obj/item/weapon/reagent_containers/food/snacks/salad/herbsalad
	name = "herb salad"
	desc = "A tasty salad with apples on top."
	icon_state = "herbsalad"
	list_reagents = list("vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/validsalad
	name = "valid salad"
	desc = "It's just an herb salad with meatballs and fried potato slices. Nothing suspicious about it."
	icon_state = "validsalad"
	list_reagents = list("doctorsdelight" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/oatmeal
	name = "oatmeal"
	desc = "A nice bowl of oatmeal."
	icon_state = "oatmeal"
	list_reagents = list("nutriment" = 7, "milk" = 10, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/salad/fruit
	name = "fruit salad"
	desc = "Your standard fruit salad."
	icon_state = "fruitsalad"
	list_reagents = list("nutriment" = 2, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/jungle
	name = "jungle salad"
	desc = "Exotic fruits in a bowl."
	icon_state = "junglesalad"
	list_reagents = list("nutriment" = 7, "banana" = 5, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/citrusdelight
	name = "citrus delight"
	desc = "Citrus overload!"
	icon_state = "citrusdelight"
	list_reagents = list("nutriment" = 7, "vitamin" = 5)

/obj/item/weapon/reagent_containers/food/snacks/salad/ricebowl
	name = "ricebowl"
	desc = "A bowl of raw rice."
	icon_state = "ricebowl"
	cooked_type = /obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice
	list_reagents = list("nutriment" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/boiledrice
	name = "boiled rice"
	desc = "A warm bowl of rice."
	icon_state = "boiledrice"
	list_reagents = list("nutriment" = 1, "vitamin" = 1)

/obj/item/weapon/reagent_containers/food/snacks/salad/ricepudding
	name = "rice pudding"
	desc = "Everybody loves rice pudding!"
	icon_state = "ricepudding"
	list_reagents = list("nutriment" = 4, "vitamin" = 2)

/obj/item/weapon/reagent_containers/food/snacks/salad/ricepork
	name = "rice and pork"
	desc = "Well, it looks like pork..."
	icon_state = "riceporkbowl"
	list_reagents = list("nutriment" = 4, "vitamin" = 4)

/obj/item/weapon/reagent_containers/food/snacks/salad/eggbowl
	name = "egg bowl"
	desc = "A bowl of rice with a fried egg."
	icon_state = "eggbowl"
	list_reagents = list("nutriment" = 4, "vitamin" = 4)
