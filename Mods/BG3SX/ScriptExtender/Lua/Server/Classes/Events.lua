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

-- Calculates payload size by characters
---@param payload   string  - The payload to evaluate
local function calculatePayloadSize(payload)
    local size = 0
    for k, v in pairs(payload) do
        size = size + string.len(tostring(k)) + string.len(tostring(v))
    end
    return size
end


-- Counts subscribers to a channel
---@param channel   string  - The Channel to check
local function countSubscribers(channel)
    local count = 0
    for _, sub in ipairs(globalSubscribers) do
        if sub.Channel == channel then
            count = count + 1
        end
    end
    return count
end


-- Calculates the wait time depending on payload size and subscriber count
---@param event Event   - The event to calculate the wait time for
local function calculateWaitTime(event)
    local subscriberCount = countSubscribers(event.Channel)
    local payloadSize = calculatePayloadSize(event.Payload)

    -- Adjust wait time based on payload size and subscriber count
    local waitTime = payloadSize * 10 + subscriberCount * 100

    _P("[BG3SX][Events.lua] Calculated waitTime for ", event.Channel, " to be: ", waitTime)
    _P("[BG3SX][Events.lua] subscriberCount = ", subscriberCount, " *100")
    _P("[BG3SX][Events.lua] payloadSize = ", payloadSize, " *100")

    return waitTime
end


-- CONSTRUCTOR
--------------------------------------------------------------


-- A new Event
---@param Channel   string  - The event name - like "MyEvent"
---@param Payload   string  - The payload, stringified with Ext.Json.Stringify(payload)
function Event:new(Channel, Payload)
    local instance = setmetatable({
        Channel = Channel,
        Payload = Payload or {},
    }, Event)

    -- Notify all global subscriptions
    instance:Throw(instance)

	-- Calculate wait time based on payload size and subscriber count, then destroy the instance
	local waitTime = calculateWaitTime(instance)
    Ext.Timer.WaitFor(waitTime, function() 
        instance:Destroy()
    end)

    return instance
end


-- Subscribing
--------------------------------------------------------------

-- Creates a subscriber for all events
---@param handler   function    - Use function(e) like in the example or "How to Use" section at the very bottom of this script
---@param priority  integer     - Optional: Manually set the priority of this subscriber to be contacted before others by thrown events
---@example
-- Event:Subscribe(function(e) if e.Channel == "MyEvent" then ... etc. to do something on specific ones
-- Priotrity setting: At the "end)" of the function insert your second parameters as followed: end, priority)
function Event:Subscribe(handler, priority)
    local index = #globalSubscribers + 1

    local sub = {
        Handler = handler,
        Index = index,
        Priority = priority or 100,  -- Default priority if not provided
    }

    table.insert(globalSubscribers, sub)
    table.sort(globalSubscribers, function(a, b) return a.Priority > b.Priority end)
    return index
end


-- Unsubscribing
--------------------------------------------------------------

-- Unsubscribes a specific subscriber from all events
---@param handlerIndex  integer - The current subscriber index within the list of globalSubscribers
---@example
-- local mySubscriber = Event:Subscribe(function(e) ... etc.
-- Event:Unsubscribe(mysubscriber)
-- Or within the subscriber itself instead use Event:Unsubscribe(self)
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

-- Throws an event for all subscribers
---@param event Event   - The event to throw
function Event:Throw(event)
    -- Iterate over all subscribers
    for _, sub in ipairs(globalSubscribers) do
        local handler = sub.Handler
        
        -- Call the handler with the event
        local ok, result = xpcall(handler, debug.traceback, event)
        if not ok then
            Ext.Utils.PrintError("[BG3SX][Events.lua] Error while dispatching event " .. event.Channel .. ": ", result)
        end
    end
end


-- Destroy Event
--------------------------------------------------------------

-- Destroys an event by setting its metatable to nil
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
--     if e.Channel == "MyOtherEvent" then
--         print("MyOtherEvent recieved")
--     end
-- end)

-- With priority
-- Event:Subscribe(function(e)
--     if e.Channel == "MyThirdEvent" then
--         local payload = Ext.Json.Parse(e.PayLoad)
--         print("MyEvent received with PayLoad: ")
--         dump(payload)
--     end
-- end, 3192)
-- This will make it so this instance of a subscriber will get contacted earlier over other subscribers of other scripts/mods, higher number wins