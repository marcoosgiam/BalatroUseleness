local meta_utils = {}
function meta_utils:create_custom_meta()
    local custom_meta = {}
    local logic = {
        __readonly = {},
    }
    local meta = {
        __index = function (t,k)
            return rawget(t,k)
        end,
        __newindex = function (t,k,v)
            if logic.__readonly[k] == nil then
            rawset(t,k,v)
            else
                print("Can't set:",k," on t:",t," because ",k," is a read only value")
            end
        end,
    }
    function custom_meta:add_read_only(index, value)
        table.insert(logic.__readonly, index)
        custom_meta[index] = value
    end
    function custom_meta:create()
        local new_meta = table.clone(custom_meta)
        setmetatable(new_meta, meta)
        return new_meta
    end
    return custom_meta
end
_G.metatablesUtils = meta_utils