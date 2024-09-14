GLOBALDEBUG = true


function SatanPrint(debug, message)

    local modname = "[BG3SX] "

    if debug then
        if message and (type(message) == string) then
            _P(modname .. message)
        else
            _P(modname)
            _P(message)
        end
    end
end



function SatanDump(debug, message)

    if debug then
        _D(message)
    end
end