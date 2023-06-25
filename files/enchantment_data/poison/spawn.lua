dofile( "data/scripts/lib/utilities.lua" )
dofile( "mods/evaisa.enchantments/files/scripts/utils.lua" )

local projectile_entity = GetUpdatedEntityID()

EntityAddComponent2(projectile_entity, "HitEffectComponent", {
	effect_hit="LOAD_GAME_EFFECT",
	value_string="mods/evaisa.enchantments/files/enchantment_data/poison/effect_poison.xml"
})