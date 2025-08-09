Recipe class:
variables:
key:string
input:table
result:table
sound:string
recipe_value:num
recipe_value_required:num
recipe_type:string
order:num
discovered:function|boolean
unlocked:function|boolean
calculate:function(used for custom calculate behavior leave as nil to be handled default way)
can_use:function(used for custom can_use behavior leave as nil to be handled default way)
use:function(used for custom use behavior leave as nil to be handled default way)


example recipe:
SMODS.recipes{
sound = "<mod_prefix>_crafting_sound"(You need to create the sound yourself)
name = "Grandma's cookie"(the recipe name here),
key = "",
prefix = "<mod_prefix>",
recipe_value_required = 1,(the requirement of the sum of all values given by input table)

input = {(the cards used by the recipe)
{
key = "c_Bakery Sugar"(not a real consumable just a example)
value = 1,(amount of the card it needs)
recipe_value = 1,(the value it increments to the recipe)
destroy_value = 1,(the amount of the card it'll destroy)
check_value="==",(the check operator to compare the amount of highlighted cards with the needed value)
},

{
key = "c_Bakery Cookie Dough"(not a real consumable just a example)
value = 1,
recipe_value = 1,
destroy_value = 1,
check_value="==",
},

}

result = {
{
value = 1,
key = "c_Cookie",(not a real consumable just a example)
area = "consumeables",(the area to be emplaced on)
set = "Grandma's candy",(not a real set just a example)
}

}
The above was a example of creating a recipe.
}
