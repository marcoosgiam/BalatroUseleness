local SourcedFunction = Object:extend()

local functions_source = {}
local functions_variable = {}
local functions_upvalues = {}

function SourcedFunction:get_base_source()
    local variables = ""
    local base_source = ""
    for i,v in ipairs(self.variables) do
        if i == #self.variables then
            variables=variables..v
        else
            variables=variables..v..","
        end 
    end
    for i,v in ipairs(self.upvalues) do
        base_source=base_source.."\n"
        base_source=base_source.."local "..v.name.."=nil"
    end
    base_source=base_source.."\n"
    base_source = base_source.."return function("..variables..")\n"
    base_source=base_source..self.source_code.." end"
    return base_source
end

function SourcedFunction:init(SourceFunction)
    self.source_code = SourceFunction.source_code
    self.variables = SourceFunction.variables
    self.upvalues = SourceFunction.upvalues or {}
    local variables = ""
    for i,v in ipairs(SourceFunction.variables) do
        if i == #SourceFunction.variables then
            variables=variables..v
        else
            variables=variables..v..","
        end 
    end
    --[[local base_source = "return function("..variables..")"
    for i,v in pairs(SourceFunction.upvalues) do
        base_source=base_source.."\n"
        base_source=base_source.."local "..i
    end
    --self.source_function = "return function("..variables..")"..self.source_code.." end"
    self.source_function = base_source..self.source_code.." end"]]
    self.source_function = self:get_base_source()
    getmetatable(self).__call = function(...)
       --print("Sourced Function called!")
       local variables = {...}
       --print(#variables)
       --print(self.source_function)
       local func_to_execute = loadstring(self.source_function)()
       func_to_execute(unpack(variables))
    end
end

function SourcedFunction:get()
if self.source_function ~= nil then
--print("source function:",self.source_function)
--print("source code:",self:get_base_source())
--print("source variables:",self.variables)
--print("source upvalues:",self.upvalues)
local last_source_code = self.source_code
local last_variables = self.variables
local last_upvalues = self.upvalues
print("source:",self:get_base_source())
print("original loadstring:",_G.o_loadstring)
local f = _G.o_loadstring(self:get_base_source())
f=f()
if #last_upvalues >0 then
for i,v in ipairs(last_upvalues) do
    --print("setting upvalue:",v.name," ",v.val)
    debug.setupvalue(f,i,v.val)
end
end
--print("result:",f)
functions_source[f] = last_source_code
functions_variable[f] = last_variables
functions_upvalues[f] = last_upvalues
return f
end
end

function SourcedFunction:get_func_source(f)
    if functions_source[f] ~= nil then
        return functions_source[f]
    end
    return nil
end

function SourcedFunction:get_func_variables(f)
    if functions_variable[f] ~= nil then
        return functions_variable[f]
    end
    return nil
end

function SourcedFunction:get_func_upvalues(f)
    if functions_upvalues[f] ~= nil then
        return functions_upvalues[f]
    end
    return nil
end

function SourcedFunction:remove_func_source(f)
if functions_source[f] ~= nil then
functions_source[f] = nil
return true
end
return false
end

function SourcedFunction:remove_func_upvalues(f)
if functions_upvalues[f] ~= nil then
    functions_upvalues[f] = nil
end
return true
end

function SourcedFunction:change_variables(new_variables)
self.variables = new_variables
local variables = ""
for i,v in ipairs(self.variables) do
    if i == #self.variables then
        variables=variables..v
    else
        variables=variables..v..","
    end 
end
--self.source_function = "return function("..variables..")"..self.source_code.." end"
self.source_function = self:get_base_source()
end

function SourcedFunction:add_source(f, code, variables, upvalues)
--[[SourcedFunction{
    source_code=code,
    variables=variables,
}]]
functions_source[f] = code
--print("setting source:",code,"\n", "variables:",variables)
functions_variable[f] = variables or {}
functions_upvalues = upvalues or {}
end





SMODS.SourcedFunction = SourcedFunction