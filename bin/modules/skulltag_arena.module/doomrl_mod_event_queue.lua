--[[ How to use the queue:
     Call "EventQueue.AddEvent" with the following arguments:
     * A pointer to the function to call
     * A 'delay' value indicating how many ticks you want to pass before your function is run
     * The arguments you want to pass to the function, in a table

     Putting the arguments in tables helps group things.  Previously I had event handlers that would
     set defaults.  In the end though making the user specify a function instead of choosing a pre-defined
     one is more flexible.

     The queue was originally made to circumvent a bug or two in OnAction and OnDie.
--]]


--This is the exposed interface
core.declare("EventQueue", {})
EventQueue.RunTick = nil
EventQueue.AddEvent = nil

--hidden stuff
local event_queue = RSQ.new ()


--The interface, implemented
EventQueue.RunTick = function()

  if(RSQ.size(event_queue) == 0) then return end --easy out


  local entries = RSQ.popleft (event_queue)
  if(entries == nil) then return end

  --entries should always be array-style indexed
  for index, value in ipairs(entries) do

    --Call 'event', pass 'args'.
    value.event(unpack(value.args))
  end
end
EventQueue.AddEvent = function(arg_event, arg_delay, arg_parameters)
  local entry = { event = arg_event, args = arg_parameters }
  RSQ.insert(event_queue, entry, arg_delay)
end
