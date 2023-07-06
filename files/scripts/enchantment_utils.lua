dofile("data/scripts/gun/gun_enums.lua")
dofile_once("mods/evaisa.enchantments/files/scripts/utils.lua");
local pretty_print = dofile_once("mods/evaisa.enchantments/files/scripts/pretty_print.lua");
dofile_once("data/scripts/lib/utilities.lua");
dofile_once("mods/evaisa.enchantments/files/scripts/enchantment_list.lua");


function WeightedRandomIndex(tbl)
	local total_weight = 0
	for k, v in ipairs(tbl) do
		total_weight = total_weight + (v.weight * 100)
	end

	local choice = nil
	local rand = Random() * total_weight
	for k, v in ipairs(tbl) do
		if rand < (v.weight * 100) then
			choice = k
			break
		end
		rand = rand - (v.weight * 100)
	end

	return choice
end

function GetEnchantmentMap(entity_id)
	local existing_enchantments = EntityGetVariable(entity_id, "enchantments", "string") or ""

	local list = Split(existing_enchantments, literalize(","))

	local enchantment_map = {}
	for k, v in ipairs(list) do
		local enchantment = GetEnchantmentWithId(v)
		if (enchantment_map[v] == nil) then
			enchantment_map[v] = { 1, enchantment }
		else
			enchantment_map[v][1] = enchantment_map[v][1] + 1
		end
	end

	return enchantment_map
end

function tableIncludes(tbl, func)
	for k, v in ipairs(tbl) do
		if func(v) then
			return true
		end
	end
	return false
end

function GetRandomEnchantments(entity_id, iterations, added_enchantments)
	added_enchantments = added_enchantments or {}

	if (#enchantments == 0) then
		return nil;
	end

	local enchantment_map = GetEnchantmentMap(entity_id)

	local temp_enchantments = {};

	local action_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent")
	if (action_comp ~= nil) then
		reading_name = true
		dofile("data/scripts/gun/gun_actions.lua")
		local action_id = ComponentGetValue2(action_comp, "action_id")
		for _, action in ipairs(actions) do
			if (action_id == action.id) then
				for k, v in ipairs(enchantments) do
					local allow_add = true

					if (not v.check(action)) then
						allow_add = false
					end
					local is_valid_type = false
					if (v.valid_spell_types ~= nil and #v.valid_spell_types ~= 0) then
						for k2, v2 in ipairs(v.valid_spell_types) do
							if (v2 == action.type) then
								is_valid_type = true
								break
							end
						end
					else
						is_valid_type = true
					end
					if (not is_valid_type) then
						allow_add = false
					end
					if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
						allow_add = false
					end
					if ((v.is_stackable == nil or not v.is_stackable) and tableIncludes(added_enchantments, function(e) return e
								.id == v.id end)) then
						allow_add = false
					end

					if ((v.is_stackable == nil or not v.is_stackable) and enchantment_map[v.id] ~= nil) then
						allow_add = false
					end
					if (allow_add) then
						table.insert(temp_enchantments, v);
					end
				end
				break
			end
		end
	end

	if (#temp_enchantments == 0) then
		return {};
	end
	if (#temp_enchantments == 1) then
		return { temp_enchantments[1] };
	end
	if (#temp_enchantments == 2 and iterations > 2) then
		return { temp_enchantments[1], temp_enchantments[2] };
	end
	local enchantment = temp_enchantments[WeightedRandomIndex(temp_enchantments)];
	iterations = iterations - 1;
	table.insert(added_enchantments, enchantment)

	if (iterations == 0) then
		return added_enchantments;
	else
		return GetRandomEnchantments(entity_id, iterations, added_enchantments);
	end
end

function GetRandomEnchantment(entity_id)
	if (#enchantments == 0) then
		return nil;
	end

	local enchantment_map = GetEnchantmentMap(entity_id)

	local temp_enchantments = {};

	local action_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent")
	if (action_comp ~= nil) then
		reading_name = true
		dofile("data/scripts/gun/gun_actions.lua")
		local action_id = ComponentGetValue2(action_comp, "action_id")
		for _, action in ipairs(actions) do
			if (action_id == action.id) then
				for k, v in ipairs(enchantments) do
					local allow_add = true

					if (not v.check(action)) then
						allow_add = false
					end
					local is_valid_type = false
					if (v.valid_spell_types ~= nil and #v.valid_spell_types ~= 0) then
						for k2, v2 in ipairs(v.valid_spell_types) do
							if (v2 == action.type) then
								is_valid_type = true
								break
							end
						end
					else
						is_valid_type = true
					end
					if (not is_valid_type) then
						allow_add = false
					end
					if (HasSettingFlag("enchantments_" .. v.id .. "_disabled")) then
						allow_add = false
					end
					if ((v.is_stackable == nil or not v.is_stackable) and enchantment_map[v.id]) then
						allow_add = false
					end
					if (allow_add) then
						table.insert(temp_enchantments, v);
					end
				end
				break
			end
		end
	end
	if (#temp_enchantments == 0) then
		return nil;
	end
	local enchantment = temp_enchantments[WeightedRandomIndex(temp_enchantments)];
	return enchantment;
end

function GetEnchantmentWithId(id)
	for k, v in ipairs(enchantments) do
		if (v.id == id) then
			return v;
		end
	end
	return nil;
end

local level_strings = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X",
	"XI",
	"XII",
	"XIII",
	"XIV",
	"XV",
	"XVI",
	"XVII",
	"XVIII",
	"XIX",
	"XX",
	"XXI",
	"XXII",
	"XXIII",
	"XXIV",
	"XXV",
	"XXVI",
	"XXVII",
	"XXVIII",
	"XXIX",
	"XXX",
}


function GetEnchantmentString(csv_enchantments)
	local list = Split(csv_enchantments, literalize(","))

	local enchantment_map = {}
	for k, v in ipairs(list) do
		local enchantment = GetEnchantmentWithId(v)
		if (enchantment_map[v] == nil) then
			enchantment_map[v] = { 1, enchantment }
		else
			enchantment_map[v][1] = enchantment_map[v][1] + 1
		end
	end
	local enchantment_string = ""

	for _, e in pairs(enchantment_map) do
		enchantment_string = enchantment_string ..
		"(" .. GameTextGetTranslatedOrNot(e[2].name) .. " " .. tostring(level_strings[e[1]]) .. ") "
	end

	return enchantment_string
end

function AppendEnchantmentString(entity_id)
	local action_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemActionComponent")
	if (action_comp ~= nil) then
		local item_comp = EntityGetFirstComponentIncludingDisabled(entity_id, "ItemComponent")
		if (item_comp ~= nil) then
			local action_id = ComponentGetValue2(action_comp, "action_id")
			local enchantment_string = ""

			local enchantment_map = GetEnchantmentMap(entity_id)

			for _, e in pairs(enchantment_map) do
				-- enchantment_string = enchantment_string .. "(" .. GameTextGetTranslatedOrNot(e[2].name) .. " " .. tostring(level_strings[e[1]]) .. ") "
				enchantment_string = enchantment_string .. "(" .. GameTextGetTranslatedOrNot(e[2].name) .. ") "
			end

			reading_name = true
			dofile("data/scripts/gun/gun_actions.lua")
			for k, a in ipairs(actions) do
				if (a.id == action_id) then
					ComponentSetValue2(item_comp, "always_use_item_name_in_ui", true)
					ComponentSetValue2(item_comp, "item_name", enchantment_string .. GameTextGetTranslatedOrNot(a.name))
					local ability_component = EntityGetFirstComponentIncludingDisabled(entity_id, "AbilityComponent")
					if (ability_component ~= nil) then
						ComponentSetValue2(ability_component, "ui_name", enchantment_string .. GameTextGetTranslatedOrNot(a.name))
					end
					break
				end
			end
		end
	end
end

function AssignRandomEnchantment(entity_id)
	local enchantment = GetRandomEnchantment(entity_id);

	if (enchantment == nil) then
		return;
	end

	AssignEnchantment(entity_id, enchantment.id);

	return enchantment
end

function AssignRandomEnchantments(entity_id, count)
	local enchantment_table = {}
	for i = 1, count do
		local enchantment = AssignRandomEnchantment(entity_id);
		table.insert(enchantment_table, enchantment);
	end
	return enchantment_table
end

function AssignEnchantment(entity_id, enchantment_id, count)
	count = count or 1

	local enchantment = GetEnchantmentWithId(enchantment_id)

	if (enchantment == nil) then
		return;
	end

	local enchantment_map = GetEnchantmentMap(entity_id)

	if (enchantment_map[enchantment_id] ~= nil) then
		if (enchantment_map[enchantment_id][1] < count) then
			count = 0
		elseif (enchantment_map[enchantment_id][1] == count) then
			count = 1
		else
			count = count - enchantment_map[enchantment_id][1]
		end
	end
	local existing_enchantments = EntityGetVariable(entity_id, "enchantments", "string") or ""

	local enchantment_table = {}
	local new_enchantment_table = {}

	for id in string.gmatch(existing_enchantments, '([^,]+)') do
		local old_enchantment = GetEnchantmentWithId(id)
		table.insert(enchantment_table, old_enchantment)
	end

	for i = 1, count do
		local x, y = EntityGetTransform(entity_id);

		local banned_components = {
			SpriteComponent = true,
			InheritTransformComponent = true,
			ItemComponent = true,
			HitboxComponent = true,
			SimplePhysicsComponent = true,
			VelocityComponent = true,
			ItemActionComponent = true,
			SpriteOffsetAnimatorComponent = true,
		}

		local old_component_map = {}
		local old_components = EntityGetAllComponents(entity_id)
		for k, v in pairs(old_components) do
			old_component_map[v] = true
		end

		for k, v in ipairs(enchantment.card_extra_entities) do
			EntityLoadToEntity(v, entity_id);
		end

		local new_components = EntityGetAllComponents(entity_id)

		for k, v in pairs(new_components) do
			if (old_component_map[v] == nil) then
				if (banned_components[ComponentGetTypeName(v)]) then
					EntityRemoveComponent(entity_id, v)
				end
			end
		end

		local inherit_transform_components = EntityGetComponentIncludingDisabled(entity_id, "InheritTransformComponent")
		if (inherit_transform_components ~= nil) then
			for k, v in ipairs(inherit_transform_components) do
				EntityRemoveComponent(entity_id, v)
			end
		end

		EntityLoadToEntity("mods/evaisa.enchantments/files/entities/enchantment_table/inherit_transform.xml", entity_id)

		local existing_enchantments = EntityGetVariable(entity_id, "enchantments", "string") or ""
		local new_enchantments = existing_enchantments .. enchantment.id .. ","

		EntitySetVariable(entity_id, "enchantments", "string", new_enchantments);

		table.insert(enchantment_table, enchantment);
		table.insert(new_enchantment_table, enchantment);
	end

	local card_entities = EntityGetAllDecendants(entity_id)
	table.insert(card_entities, entity_id)

	for k, v in pairs(card_entities) do
		if (EntityGetIsAlive(v)) then
			EntitySetComponentsWithTagEnabled(v, "enabled_in_hand", false)
			EntitySetComponentsWithTagEnabled(v, "enabled_in_inventory", false)
			if (not EntityHasTag(EntityGetParent(v), "wand")) then
				EntitySetComponentsWithTagEnabled(v, "enabled_in_world", true)
			end
			EntitySetComponentsWithTagEnabled(v, "item_unidentified", false)
		end
	end

	AppendEnchantmentString(entity_id);

	return new_enchantment_table
end

function AssignEnchantments(entity_id, enchantments_to_add)
	local enchantment_table = {}
	local new_enchantment_table = {}
	for k, v in pairs(enchantments_to_add) do
		local count = v[2] or 1

		local enchantment = (type(v[1]) == "string") and GetEnchantmentWithId(v[1]) or v[1]

		local enchantment_id = enchantment.id

		if (enchantment == nil) then
			return;
		end

		local enchantment_map = GetEnchantmentMap(entity_id)

		--print("Enchantment Option - "..enchantment.name.." "..tostring(count))

		if (enchantment_map[enchantment_id] ~= nil) then
			if (enchantment_map[enchantment_id][1] > count) then
				count = 0
			elseif (enchantment_map[enchantment_id][1] == count) then
				count = 1
			else
				count = count - enchantment_map[enchantment_id][1]
			end
		end

		--GamePrint("Card has "..tostring(enchantment_map[enchantment_id] ~= nil and enchantment_map[enchantment_id][1] or 0).." stacks of "..GameTextGetTranslatedOrNot(enchantment.name)..", adding "..tostring(count).." stacks.")
		--print("Card has "..tostring(enchantment_map[enchantment_id] ~= nil and enchantment_map[enchantment_id][1] or 0).." stacks of "..GameTextGetTranslatedOrNot(enchantment.name)..", adding "..tostring(count).." stacks.")

		local existing_enchantments = EntityGetVariable(entity_id, "enchantments", "string") or ""

		for id in string.gmatch(existing_enchantments, '([^,]+)') do
			local old_enchantment = GetEnchantmentWithId(id)
			table.insert(enchantment_table, old_enchantment)
		end

		for i = 1, count do
			local x, y = EntityGetTransform(entity_id);

			local banned_components = {
				SpriteComponent = true,
				InheritTransformComponent = true,
				ItemComponent = true,
				HitboxComponent = true,
				SimplePhysicsComponent = true,
				VelocityComponent = true,
				ItemActionComponent = true,
				SpriteOffsetAnimatorComponent = true,
			}

			local old_component_map = {}
			local old_components = EntityGetAllComponents(entity_id)
			for k, v in pairs(old_components) do
				old_component_map[v] = true
			end

			for k, v in ipairs(enchantment.card_extra_entities) do
				EntityLoadToEntity(v, entity_id);
			end

			local new_components = EntityGetAllComponents(entity_id)

			for k, v in pairs(new_components) do
				if (old_component_map[v] == nil) then
					if (banned_components[ComponentGetTypeName(v)]) then
						EntityRemoveComponent(entity_id, v)
					end
				end
			end

			local inherit_transform_components = EntityGetComponentIncludingDisabled(entity_id, "InheritTransformComponent")
			if (inherit_transform_components ~= nil) then
				for k, v in ipairs(inherit_transform_components) do
					EntityRemoveComponent(entity_id, v)
				end
			end

			EntityLoadToEntity("mods/evaisa.enchantments/files/entities/enchantment_table/inherit_transform.xml", entity_id)

			local existing_enchantments = EntityGetVariable(entity_id, "enchantments", "string") or ""
			local new_enchantments = existing_enchantments .. enchantment.id .. ","

			EntitySetVariable(entity_id, "enchantments", "string", new_enchantments);

			table.insert(enchantment_table, enchantment);
			table.insert(new_enchantment_table, enchantment);
		end
	end

	local card_entities = EntityGetAllDecendants(entity_id)
	table.insert(card_entities, entity_id)

	for k, v in pairs(card_entities) do
		if (EntityGetIsAlive(v)) then
			EntitySetComponentsWithTagEnabled(v, "enabled_in_hand", false)
			EntitySetComponentsWithTagEnabled(v, "enabled_in_inventory", false)
			if (not EntityHasTag(EntityGetParent(v), "wand")) then
				EntitySetComponentsWithTagEnabled(v, "enabled_in_world", true)
			end
			EntitySetComponentsWithTagEnabled(v, "item_unidentified", false)
		end
	end

	AppendEnchantmentString(entity_id);
	return new_enchantment_table
end
