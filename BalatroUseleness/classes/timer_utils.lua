SMODS.BalatroUtilities.timer_utils = {}
local function get_timers(card)
return card.ability.extra.bl_util_card_timers
end
function SMODS.BalatroUtilities.timer_utils:set_active(card, timer_pos)
local timers = get_timers(card)
timers[timer_pos].active = true
end
function SMODS.BalatroUtilities.timer_utils:deactivate(card, timer_pos)
local timers = get_timers(card)
timers[timer_pos].active = false
end
function SMODS.BalatroUtilities.timer_utils:is_active(card,timer_pos)
local timers = get_timers(card)
if timers[timer_pos].active ~= false then return true end
return false
end
function SMODS.BalatroUtilities.timer_utils:copy_timer(card,timer_pos)
local timers = get_timers(card)
return copy_table(timers[timer_pos])
end
function SMODS.BalatroUtilities.timer_utils:set_timer_current(card,timer_pos,value)
value = value or 0
local timers = get_timers(card)
timers[timer_pos].current = value
end
function SMODS.BalatroUtilities.timer_utils:change_id(card,timer_pos,new_id)
local timers = get_timers(card)
timers[timer_pos].id = new_id
end
function SMODS.BalatroUtilities.timer_utils:set_reset_on(card,timer_pos,value)
local timers = get_timers(card)
timers[timer_pos].reset_on = value
end