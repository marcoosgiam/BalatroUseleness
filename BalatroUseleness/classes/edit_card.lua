local function create_placeholder(align,colour,extra)
    align=align or "tm"
    colour=colour or G.C.CLEAR
    extra = extra or {}
    return {n=G.UIT.C,config={align="tm",colour=colour,button=extra.button,ref_table=extra.ref_table,emboss=extra.emboss},nodes={},}
end 
local function create_row_placeholder()
      return {n=G.UIT.R,config={align=nil,colour=G.C.MULT,},nodes={},}
end
local function create_pages_button()
      local this_placeholder = create_row_placeholder()
      this_placeholder.nodes[1] = {
        n=G.UIT.T,config={colour=HEX("e07afd"),outline_colour=G.C.BLACK,text="Pages:1/1",button="edit_card_button_pages",scale=1,}
      }
      return this_placeholder
end
local this_variables = {
  pages = {},
  current_page = 0,
  created_pages = {},
}
function SMODS.BalatroUtilities:apply_card_edit(card_edit)
    local at = card_edit.at
    local target = card_edit.target
    local edit = card_edit.edit
    local edit_target = at[target]
    local function get_edit(current, current_target)
        local this_current = {}
        for i,v in pairs(current) do
            this_current[i] = v
        end
        print("this current:",this_current)
        if this_current.bl_utils_keep then
            print("yesss has!!!")
        end
        for i,v in pairs(current_target) do
            if type(v) == "table" and this_current[i] ~= nil and this_current.bl_utils_keep then
                print("trying to get:",i)
                this_current[i]=get_edit(this_current[i], v)
            end
            if type(v) ~= "table" and this_current[i] == nil then
                this_current[i] = v
            end
        end
        local keys_to_delete = {
           ["bl_utils_keep"] = true,
        }
        for i,v in pairs(keys_to_delete) do
            this_current[i] = nil
        end
        return this_current
    end
    local function apply_edit(current, current_target)
       print("edit target:",current_target)
       local this_edit = get_edit(current,current_target)
       print("edit result:",this_edit)
       for i,v in pairs(this_edit) do
           current_target[i] = v
       end
    end
    apply_edit(edit, edit_target)
    print('applied card edit to:',edit_target)
end
local cards_edit_ref = {}
local current_edit_ref = nil
local current_card_being_edited = nil


local function create_variable_input(ref, i, ref_table,extra)
   local variable_input = nil
   extra=extra or {}
   extra.ignore = extra.ignore or {}
   local w = extra.w or 1.5
   local h = extra.h or 1
   if type(ref[i]) == "string" and extra.ignore[i] ~= true or type(ref[i]) == "number" and extra.ignore[i] ~= true then
      local this_prompt_text = i..":"
      print("prompt_text:",this_prompt_text)
      print("ref value:",i)
      variable_input = create_text_input({
        colour = G.C.CHIPS,
        hooked_colour = G.C.BLACK,
        w = 1.5,
        h = 1,
        prompt_text = this_prompt_text,
        ref_table = ref_table,
        ref_value = i,
        extended_corpus = true,
        max_length = 100,
      })
   end
   if type(ref[i]) == "table" and extra.ignore[i] ~= true then
      local placeholder = create_placeholder(nil, G.C.CHIPS, {button="bl_utils_change_edit_page",ref_table={ref=ref_table,key=i,current_state=ref}})
      placeholder.nodes[1] = {n=G.UIT.T,config={colour=G.C.MULT,outline_colour=G.C.BLACK,text="Edit:"..i,scale=0.5,}}
      variable_input = placeholder
   end
   return variable_input
end

local function create_ref_from_table(tabl)
  local ref = {}
  local allowed_indexes = {
    ["config"] = true,
    ["extra"] = true,
  }
  for i,v in pairs(tabl) do
    if type(v) == "number" or type(v) == "string" then
    print("type:",i," is number or string")
    ref[i] = v
    elseif type(v) ~= "boolean" and allowed_indexes[i] == true then
       print("type:",i," is not number or string")
       ref[i] = v
    end
  end
  return ref
end

local function create_edit_prompts(target,contents,extra,createds, insert_pos)
    createds=createds or 0
    insert_pos=insert_pos or 1
    extra = extra or {}
    extra.ignore = extra.ignore or {}
    extra.ignore["pos"] = true
    local this_target = target
    print("current ref:",current_edit_ref)
    local function find_target(t)
       if t == target then this_target=t return end
       for i,v in pairs(t) do
          if v == target then this_target=v break end
          if type(v) == "table" then find_target(v) end
       end
    end
    find_target(current_edit_ref)
    --[[if current_edit_ref ~= nil then
       this_target=current_edit_ref
    else
        this_target=target
    end]]
    --[[if current_edit_ref ~= nil then
       for i,v in pairs(current_edit_ref) do
           this_target[i] = current_edit_ref[i]
       end
    end]]
    --local this_ref=create_ref_from_table(this_target)
    local this_ref=this_target
    --[[if current_edit_ref == nil then
       current_edit_ref=this_ref
    end]]
    --[[if current_edit_ref == nil then
       current_edit_ref=create_ref_from_table(target)
    else
       current_edit_ref=table.clone(current_edit_ref)
    end]]
    for i,v in pairs(target) do
       if createds >=3 then
        insert_pos=insert_pos+1
       end
       if contents[insert_pos] == nil then
          contents[insert_pos] = create_placeholder()
       end
       local variable_input = create_variable_input(target, i, this_ref,extra)
       if variable_input ~= nil then
          table.insert(contents[insert_pos].nodes, variable_input)
       end
    end
    return this_ref
end


local function create_edit_card_button(card)
    local edit = nil
    edit = {n=G.UIT.C, config={align = "cr"}, nodes={
      {n=G.UIT.C, config={ref_table = card, align = "cr",maxw = 1.25, padding = 0.1, r=0.2, minw = 1.25, minh = (card.area and card.area.config.type == 'joker') and 0 or 1, hover = true, shadow = true, colour = HEX("a785ff"), one_press = false, button = 'edit'}, nodes={
        {n=G.UIT.B, config = {w=0.05,h=0.3}},
        {n=G.UIT.T, config={text = localize("k_edit"),colour = HEX("ff858d"), scale = 0.55, shadow = true}}
      }}
    }}
    return edit
end
G.FUNCS.edit = function (e)
  local card = e.config.ref_table
  current_card_being_edited = card
  if cards_edit_ref[card] ~= nil then
      current_edit_ref=cards_edit_ref[card]
      print("set current edit ref?")
  else
      current_edit_ref=nil
  end
  local this_menu = create_edit_menu(card)
  G.FUNCS.overlay_menu({
    definition=this_menu
  })
  table.insert(this_variables.pages, {ref=card})
  this_variables.current_page=this_variables.current_page+1
end
local last = G.UIDEF.use_and_sell_buttons
G.UIDEF.use_and_sell_buttons = function (card)
    local result = last(card)
    print("node:",result.nodes[1])
    table.insert(result.nodes[1].nodes, create_edit_card_button(card))
    return result
end
local function get_unique_ref_id(card)
  local card_unique_identifier = "cards_edit".."<"..card.config.center.key..">"
  local ids = {}
  local card_unique_ref_id = ""
  for i,v in ipairs(SMODS.temp_variables[card_unique_identifier]) do
      if v.ref == card then return false,v end
      local this_id = v.id
      ids[this_id] = true
  end
  local unique_id = 0
  while true do
     if ids[unique_id] == true then
     unique_id=unique_id+1
     else
      break
     end
  end
  card_unique_ref_id = "<"..unique_id..">"
  return card_unique_ref_id
end
local function create_card_ref(card)
   local card_ref = {
     
   }
   for i,v in pairs(card) do
     card_ref[i] = v
   end
   print("card:",card)
   local card_unique_identifier = "cards_edit".."<"..card.config.center.key..">"
   if SMODS.temp_variables[card_unique_identifier] == nil then
      SMODS.temp_variables[card_unique_identifier] = {}
   end
   local unique_card_id,unique_card_ref = get_unique_ref_id(card)
   if unique_card_ref ~= nil then return unique_card_ref end
   local pos = #SMODS.temp_variables[card_unique_identifier]+1
   table.insert(SMODS.temp_variables[card_unique_identifier], {
     id = unique_card_id,

   })
   SMODS.temp_variables[card_unique_identifier][pos].ref = card_ref
   return SMODS.temp_variables[card_unique_identifier][pos]
end

function create_edit_page(ref,target,last_menu)
   --[[if this_variables.created_pages[this_variables.current_page] ~= nil then
      print("found reference!")
      local this_ref = {create_placeholder()}
      this_ref=create_UIBox_generic_options({
        contents=this_ref,
        back_func="bl_utils_back_to_last_edit_page",
      })
      create_edit_prompts(this_variables.created_pages[this_variables.current_page].ref,this_ref)
      return this_ref
   end]]
   local contents={
     create_placeholder()
   }
   local edit_page=create_UIBox_generic_options({
     contents=contents,
     back_func="bl_utils_back_to_last_edit_page",
   })
   for i,v in pairs(target) do
      print("key:",i)
   end
   print("ref:",target)
   local this_ref = create_edit_prompts(target, contents)
   --table.insert(this_variables.created_pages, {uidef=table.clone(contents),ref=this_ref,})
   return edit_page,this_ref
end

function enter_edit_page(ref,target)
  local this_edit_page,this_ref = create_edit_page(ref,target)
   G.FUNCS.overlay_menu{
    definition=this_edit_page,
   }
  table.insert(this_variables.pages, {ref=ref,target=target,})
  this_variables.current_page=this_variables.current_page+1
    
end
function create_edit_menu(card)
   
   local contents = {
     create_placeholder(nil,nil,{emboss=2,}),
   }
   local function create_key_textbox()
    local key_textbox = create_text_input({
        colour = G.C.CHIPS,
        hooked_colour = G.C.CHIPS,
        w = 5,
        h= 1,
        prompt_text = "key:",
        ref_table = this_card_ref.ref,
        ref_value = "key",
        extended_corpus = true,
        max_length = 100,
    })
    return key_textbox
   end
   if current_edit_ref == nil then
   current_edit_ref=create_ref_from_table(card.config.center)
   cards_edit_ref[card] = current_edit_ref
   end
   create_edit_prompts(current_edit_ref, contents[1].nodes)
   table.insert(contents[1].nodes, {
     n=G.UIT.C,config={colour=G.C.GREEN,w=0.5,h=0.5,align="cl",},nodes={
       {n=G.UIT.T,config={colour=G.C.CHIPS,minw=1,minh=1,align="cl",text="Apply changes",scale=0.5,button="bl_utils_apply_edit_changes"}}
     },
   })
   --[[for i,v in pairs(card.config.center) do
      local variable_input = create_variable_input(card.config.center, i, create_ref_from_table(card.config.center))
      if variable_input ~= nil then
        table.insert(contents[1].nodes, variable_input)
      end
   end]]
   --table.insert(contents[1].nodes, create_variable_input(card.config.center, "key", this_card_ref.ref))
   local edit_menu =  create_UIBox_generic_options({
    contents=contents,
    back_func="bl_utils_leave_edit_menu",
   })
   return edit_menu
end
G.UIDEF.create_edit_card_button = create_edit_card_button
G.FUNCS.bl_utils_change_edit_page = function(e)
  local config = e.config.ref_table
  local ref = config.ref
  print("config:",config)
  enter_edit_page(ref, config.current_state[config.key])
end
G.FUNCS.bl_utils_leave_edit_menu = function (e)
   print('leaving edit menu!')
   this_variables.current_page = 1
   table.clear(this_variables.pages)
   G.FUNCS.exit_overlay_menu()
end
G.FUNCS.bl_utils_back_to_last_edit_page = function (e)
   print("current page:",this_variables.current_page)
   local last_page = this_variables.pages[this_variables.current_page-1]
   print("last page:",last_page)
   local this_page = nil
   if this_variables.current_page == 2 then
      this_page = create_edit_menu(last_page.ref)
   else
       this_page=create_edit_page(last_page.ref, last_page.target)
   end
   G.FUNCS.overlay_menu({
     definition=this_page,
   })
   print("overlayed")
   for i = this_variables.current_page,#this_variables.pages do
      this_variables.pages[i] = nil
   end
   this_variables.current_page=this_variables.current_page-1
   this_variables.pages[#this_variables.pages] = last_page
end
G.FUNCS.bl_utils_apply_edit_changes = function (e)
    print("applying edit changes!")
    print("edit ref:",current_edit_ref)
    for i,v in pairs(current_edit_ref.config) do
        if i ~= "extra" then
        print("card edited value:",i,":",v)
        print("card being edited:",current_card_being_edited)
        current_card_being_edited.ability[i] = v
        end
    end
    for i,v in pairs(current_edit_ref.config.extra) do
        current_card_being_edited.ability.extra[i] = v
    end
    this_variables.pages = {}
    table.clear(current_edit_ref)
    current_edit_ref=nil
    table.clear(cards_edit_ref[current_card_being_edited])
    cards_edit_ref[current_card_being_edited] = nil
    current_card_being_edited=nil
    G.FUNCS.exit_overlay_menu()
    collectgarbage("collect")
end

local l_highlight = Card.highlight
--[[function Card:highlight(is_highlighted)
    local r = l_highlight(self,is_highlighted)
    if G.OVERLAY_MENU then
    local buttons = G.UIDEF.use_and_sell_buttons(self)
    self.children.use_button = UIBox{
            definition = buttons, 
            config = {align="cr",offset={x=-0.4,y=0,}},
            parent =self
        }
    end
end]]

local l_draw = Card.draw