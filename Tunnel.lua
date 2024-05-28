_CMR = {
    Delays = {},
    Identifier = getResourceName(getThisResource()),
    Resource = getResourceRootElement()
}

_CMR.AddEvent = function(event, func)
    addEvent(event, true)
    addEventHandler(event, _CMR.Resource, func)
end

_CMR.GenerateID = function()
    local IDGenerator = {
        max = 1,
        ids = {}
    }

    IDGenerator.gen = function()
        if #IDGenerator.ids > 0 then
            table.remove(IDGenerator.ids)
        end

        local r = IDGenerator.max
        IDGenerator.max = IDGenerator.max+1
        return r
    end

    IDGenerator.free = function(id)
        table.insert(IDGenerator.ids, id)
    end

    return setmetatable({}, { __index = IDGenerator })
end

_CMR.BindInterface = function(name, interface)
    _CMR.AddEvent(name..":".._CMR.Identifier..":_cmr_tunnel", function(fname, args, rid, playerSource)
        local f = interface[fname]
        local rets = {}

        if type(f) == "function" then
            rets = {f(unpack(args, 1, table.maxn(args)))}
        end

        if rid >= 0 then
            if triggerClientEvent then
                triggerClientEvent(playerSource, name..":".._CMR.Identifier..":b_cmr_tunnel", _CMR.Resource, rid, rets)
            else
                triggerServerEvent(name..":".._CMR.Identifier..":b_cmr_tunnel", _CMR.Resource, rid, rets)
            end
        end
    end)
end


_CMR.TunnelResolve = function(TableValue, key)
    local MTable = getmetatable(TableValue)
    local Tname = MTable.Name
    local Tid = MTable.IDG
    local Tcallback = MTable.Callbacks
    local Fname = key

    local fcall = function(callback, ...)
        local Args = {...}
        rID = Tid:gen()
        Tcallback[tostring(rID)] = function(...)
            callback(...)
        end

        if triggerClientEvent then
            player = Args[1]
            Args = {unpack(Args, 2, table.maxn(Args))}
            triggerClientEvent(player, Tname..":".._CMR.Identifier..":_cmr_tunnel", _CMR.Resource, Fname, Args, rID)
        else
            triggerServerEvent(Tname..":".._CMR.Identifier..":_cmr_tunnel", _CMR.Resource, Fname, Args, rID, localPlayer)
        end
    end

    TableValue[Fname] = fcall
    return fcall
end

function _CMR.GetInterface(name)
    local Callbacks = {}
    local IDG = _CMR.GenerateID()

    local r = setmetatable({}, {
        __index = _CMR.TunnelResolve,
        Name = name,
        IDG = IDG,
        Callbacks = Callbacks
    })

    _CMR.AddEvent(name..":".._CMR.Identifier..":b_cmr_tunnel", function(rID, args)
        local callback = Callbacks[tostring(rID)]

        if callback then
            IDG:free(rID)
            Callbacks[tostring(rID)] = nil
            callback(unpack(args, 1, table.maxn(args)))
        end
    end)

    return r
end

