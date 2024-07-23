----------------------------------------------------------------------------------------
--
--                               For handling Events
--          (Structure taken but modified from BG3SE - Norbyte - Events.lua)
--
----------------------------------------------------------------------------------------



----------------------------------------------
-- This class is now replaced by Ext.ModEvents
----------------------------------------------
-- Keeping it in case we may use something of it later or move it



-- Event = {}
-- Event.__index = Event

-- -- Lifetime Management
-- -------------------------------

-- -- TODO: Also count content string length of nested tables
-- -- Calculates payload size by characters
-- ---@param payload   string  - The payload to evaluate
-- local function calculatePayloadSize(payload)
--     local size = 0
--     if type(payload) == "table" then
--         for k, v in pairs(payload) do
--             size = size + string.len(tostring(k)) + string.len(tostring(v))
--         end
--     elseif type(payload) == "string" then
--         size = size + string.len(payload)
--     end
--     return size
-- end


-- -- Counts subscribers to a channel
-- ---@param channel   string  - The Channel to check
-- local function countSubscribers(channel)
--     local count = 0
--     for _, sub in ipairs(EVENTSUBSCRIBER) do
--         -- if sub.Channel == channel then
--             count = count + 1
--         -- end
--     end
--     return count
-- end


-- -- Calculates the wait time depending on payload size and subscriber count
-- ---@param event Event   - The event to calculate the wait time for
-- local function calculateWaitTime(event)
--     local subscriberCount = countSubscribers(event.Channel)
--     local payloadSize = calculatePayloadSize(event.Payload)

--     -- Adjust wait time in ms based on payload size and subscriber count (1000 = 1sec)
--     local waitTime = payloadSize * 2 + subscriberCount * 5

--    -- _P("[BG3SX][Event.lua] Calculated waitTime for ", Ext.Json.Stringify(event.Channel), " Event to be: ", waitTime)
--    -- _P("[BG3SX][Event.lua] subscriberCount = ", subscriberCount, " *5ms")
--    -- _P("[BG3SX][Event.lua] payloadSize = ", payloadSize, " *2ms")

--     return waitTime
-- end


-- -- CONSTRUCTOR
-- --------------------------------------------------------------

-- -- A new Event
-- ---@param Channel   string  - The event name - like "MyEvent"
-- ---@param Payload   string  - The payload, stringified with Ext.Json.Stringify(payload)
-- function Event:new(Channel, Payload)
--     local instance = setmetatable({
--         Channel = Channel,
--         Payload = Payload or {},
--     }, Event)

--     -- Notify all global subscriptions
--     instance:Throw(instance)

-- 	-- Calculate wait time based on payload size and subscriber count, then destroy the instance
-- 	local waitTime = calculateWaitTime(instance)
--     Ext.Timer.WaitFor(waitTime, function() 
--         instance:Destroy()
--     end)

--     return instance
-- end


-- -- Subscribing
-- --------------------------------------------------------------

-- -- Creates a subscriber for all events
-- ---@param handler   function    - Use function(e) like in the example or "How to Use" section at the very bottom of this script
-- ---@param priority  integer     - Optional: Manually set the priority of this subscriber to be contacted before others by thrown events
-- ---@example
-- -- Event:Subscribe(function(e) if e.Channel == "MyEvent" then ... etc. to do something on specific ones
-- -- Priotrity setting: At the "end)" of the function insert your second parameters as followed: end, priority)
-- function Event:Subscribe(handler, priority)
--     local index = #EVENTSUBSCRIBER + 1

--     local sub = {
--         -- Path = debug.getinfo(2,"S"), -- Would get us the subscriber instances path as an additional output if debug.getinfo would work
--         Handler = handler,
--         Index = index,
--         Priority = priority or 100,  -- Default priority if not provided
--     }

--     table.insert(EVENTSUBSCRIBER, sub)
--     table.sort(EVENTSUBSCRIBER, function(a, b) return a.Priority > b.Priority end)
--     return index
-- end


-- -- Unsubscribing
-- --------------------------------------------------------------

-- -- Unsubscribes a specific subscriber from all events
-- ---@param handlerIndex  integer - The current subscriber index within the list of EVENTSUBSCRIBER
-- ---@example
-- -- local mySubscriber = Event:Subscribe(function(e) ... etc.
-- -- Event:Unsubscribe(mysubscriber)
-- -- Or within the subscriber itself instead use Event:Unsubscribe(self)
-- function Event:Unsubscribe(handlerIndex)
--     for i, sub in ipairs(EVENTSUBSCRIBER) do
--         if sub.Index == handlerIndex then
--             table.remove(EVENTSUBSCRIBER, i)
--             return
--         end
--     end
-- end


-- -- Throwing
-- --------------------------------------------------------------

-- -- Throws an event for all subscribers
-- ---@param event Event   - The event to throw
-- function Event:Throw(event)
--     -- Iterate over all subscribers
--     for _, sub in pairs(EVENTSUBSCRIBER) do
--         local handler = sub.Handler
--         --_P("EVENT THROWN")
--         -- Call the handler with the event
--         local ok, result = xpcall(handler, debug.traceback, event)
--        -- _P("EVENT OK")
--         if not ok then
--             Ext.Utils.PrintError("[BG3SX][Event.lua] Error while dispatching event " .. event.Channel .. ": ", result)
--         end
--     end
-- end


-- -- Destroy Event
-- --------------------------------------------------------------

-- -- Destroys an event by setting its metatable to nil
-- function Event:Destroy()
-- 	setmetatable(self, nil)
-- end


-- ----------------------------------------------------------------------------------------
-- --
-- --                               	How to use
-- --          
-- ----------------------------------------------------------------------------------------

-- -- Example Payload and Event creation
-- ---------------------------------------------
-- -- local myTable = {entry1 = "entry1", entry2 = "entry2"}
-- -- Event:new("MyEvent", myTable)
-- -- Event:new("MyOtherEvent", myTable.entry1)
-- -- A new events first parameter is the channel it contacts subscribers over, the second parameter is the payload being send with it

-- -- Regular Use
-- ---------------------------------------------
-- -- Event:Subscribe(function(e)
-- --     if e.Channel == "MyEvent" then
-- --         _P("MyEvent received with PayLoad: ")
-- --         dump(e.payload)                          -- Dumps myTable with 2 entries
-- --     end
-- --     if e.Channel == "MyOtherEvent" then
-- --         _P("MyOtherEvent recieved")
-- --     end
-- -- end)


-- -- With priority
-- ---------------------------------------------
-- -- Event:Subscribe(function(e)
-- --     if e.Channel == "MyThirdEvent" then
-- --         _P("MyEvent received with PayLoad: ")
-- --         dump(e.payload)                          -- Since the myTable is myTable.entry1 it dumps entry1 instead
-- --     end
-- -- end, 3192) -- The priority integer
-- --
-- -- Adding a priority integer makes it so the subscriber instance will get contacted earlier over other subscribers of other scripts/mods
-- -- You can create multiple Event:Subscribe instances with different priorities
-- -- Higher number wins


-- -- COPY PASTE TEMPLATE
-- ---------------------------------------------
-- -- Event:Subscribe(function(e)
-- --     if e.Channel == "?" then

-- --     end
-- -- end)