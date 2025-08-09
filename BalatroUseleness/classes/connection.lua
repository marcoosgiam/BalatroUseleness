local signal = {}
function signal:new()
    local new_signal = metatablesUtils:create_custom_meta()
    new_signal:add_read_only("connections", {})
    new_signal=new_signal:create()
    local function create_connection(func,once)
        local this_connection = {
            event=func,
            once=once or false,
        }
        function this_connection:disconnect()
            local pos = table.find(new_signal.connections, self)
            table.remove(new_signal.connections, pos)
            new_signal.connections[pos] = nil
            this_connection = nil
            self = nil
        end
        return this_connection
    end
    function new_signal:connect(func)
        local this_connection = create_connection(func)
        table.insert(new_signal.connections, this_connection)
    end
    function new_signal:once(func)
        local this_connection = create_connection(func,true)
        table.insert(new_signal.connections, this_connection)
    end
    function new_signal:DisconnectAll()
        for i,v in pairs(self.connections) do
            v:disconnect()
        end
    end
    function new_signal:fire(...)
        for i,v in pairs(self.connections) do
           local co = coroutine.create(v.event)
           coroutine.resume(co, ...)
           if v.once == true then v:disconnect() end
        end
    end
    return new_signal
end
_G.signal = signal