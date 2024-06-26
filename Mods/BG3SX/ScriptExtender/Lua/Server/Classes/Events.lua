----------------------------------------------------------------------------------------
--
--                               For handling Events
--          (Structure taken but modified from BG3SE - Norbyte - Events.lua)
--
----------------------------------------------------------------------------------------

Event = {}
Event.__index = Event
local globalSubscribers = {}

-- Destroy Management
-------------------------------

local function calculatePayloadSize(payload)
    -- Example function to calculate payload size
    local size = 0
    for k, v in pairs(payload) do
        size = size + string.len(tostring(k)) + string.len(tostring(v))
    end
    return size
end

local function calculateWaitTime(payload, subscriberCount)
    -- Example logic, adjust as per your specific needs
    local payloadSize = calculatePayloadSize(payload)
    local baseWaitTime = 1000  -- Default wait time in milliseconds

    -- Adjust wait time based on payload size and subscriber count
    local waitTime = baseWaitTime + payloadSize * 10 + subscriberCount * 100

    return waitTime
end

local function countSubscribers(channel)
    -- Example function to count subscribers for a channel
    local count = 0
    for _, sub in ipairs(globalSubscribers) do
        if sub.Channel == channel then
            count = count + 1
        end
    end
    return count
end

-- CONSTRUCTOR
--------------------------------------------------------------

function Event:new(Channel, Payload)
    local instance = setmetatable({
        Channel = Channel,
        Payload = Payload or {},
    }, Event)

    -- Notify all global subscriptions
    self:Throw(instance)

	-- Calculate wait time based on payload size and subscriber count
	local waitTime = calculateWaitTime(Payload, countSubscribers(Channel))

    -- Automatically destroy the event after 1 second
    Ext.Timer.WaitFor(waitTime, function() 
        instance:Destroy()
    end)

    return instance
end


-- Subscribing
--------------------------------------------------------------

function Event:Subscribe(handler, priority)
    local index = #globalSubscribers + 1

    local sub = {
        Handler = handler,
        Index = index,
        Priority = priority or 100,  -- Default priority if not provided
        Channel = nil  -- Channel can be set dynamically in handlers based on event
    }

    table.insert(globalSubscribers, sub)
    table.sort(globalSubscribers, function(a, b) return a.Priority > b.Priority end)
    return index
end


-- Unsubscribing
--------------------------------------------------------------

function Event:Unsubscribe(handlerIndex)
    for i, sub in ipairs(globalSubscribers) do
        if sub.Index == handlerIndex then
            table.remove(globalSubscribers, i)
            return
        end
    end
end


-- Throwing
--------------------------------------------------------------

function Event:Throw(event)
    for _, sub in ipairs(globalSubscribers) do
        -- Iterate over all subscribers
        local handler = sub.Handler
        
        -- Check if the handler is interested in this event's channel
        if sub.Channel == event.Channel then
            -- Call the handler with the event
            local ok, result = xpcall(handler, debug.traceback, event)
            if not ok then
                Ext.Utils.PrintError("[BG3SX][Events.lua] Error while dispatching event " .. event.Channel .. ": ", result)
            end
        end
    end
end


-- Destroy Event
--------------------------------------------------------------

function Event:Destroy()
		setmetatable(self, nil)
end


----------------------------------------------------------------------------------------
--
--                               	How to use
--          
----------------------------------------------------------------------------------------

-- local payload = {entry1 = "entry1", entry2 = "entry2"}
-- Event:new("MyEvent", Ext.Json.Stringify(payload))
-- Event:new("MyOtherEvent", Ext.Json.Stringify(payload.entry1))


-- Event:Subscribe(function(e)
--     if e.Channel == "MyEvent" then
--         local payload = Ext.Json.Parse(e.PayLoad)
--         print("MyEvent received with PayLoad: ")
--         dump(payload)
--     end
-- 	if e.Channel == "MyOtherEvent" then
-- 		print("MyOtherEvent recieved")
-- 	end
-- end)