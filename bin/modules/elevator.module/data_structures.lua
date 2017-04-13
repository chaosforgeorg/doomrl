--A linked list is pointless in Lua.  There are better structs.

--A queue.  Copied from online somewhere, can be fairly useful.
core.declare("Queue", {})

function Queue.new ()
  return {first = 0, last = -1}
end

function Queue.pushleft (queue, value)
  local first = queue.first - 1
  queue.first = first
  queue[first] = value
end
function Queue.pushright (queue, value)
  local last = queue.last + 1
  queue.last = last
  queue[last] = value
end

function Queue.popleft (queue)
  local first = queue.first
  if first > queue.last then error("queue is empty") end
  local value = queue[first]
  queue[first] = nil        -- to allow garbage collection
  queue.first = first + 1
  return value
end
function Queue.popright (queue)
  local last = queue.last
  if queue.first > last then error("queue is empty") end
  local value = queue[last]
  queue[last] = nil
  queue.last = last - 1
  return value
end

function Queue.size (queue)
  return last - first + 1
end


--[[ Accd to Sorear this is a recursive slowdown queue, or a butchered lua equivalent.
     I think it's the best way to handle our event queue as I need to insert things
     in the middle of it and multiple events will need to be triggered on ticks.
     I want inserts to be constant; no O(n) searching.  I want multiple entries per
     index.  And I want to pop things off one at a time from the left which is why I've
     gone ahead and made this instead of directly relying on Lua's hash tables.

     In practical terms the only change is the 'insert' function and the requirement
     that all 'value' attributes are tables which store the actual value(s).

     I may add a retrieve or delete if there's a need for it.
--]]
core.declare("RSQ", {})

function RSQ.new ()
  return {first = 0, last = -1}
end
function RSQ.pushleft (queue, value)
  local first = queue.first - 1
  queue.first = first
  queue[first] = { value }
end
function RSQ.pushright (queue, value)
  local last = queue.last + 1
  queue.last = last
  queue[last] = { value }
end

--should these actually return nil if the queue is empty?  We are inserting at random points, a legit nil isn't unusual
function RSQ.popleft (queue)
  local first = queue.first
  if first > queue.last then error("queue is empty") end
  local value = queue[first]
  queue[first] = nil
  queue.first = first + 1
  return value
end
function RSQ.popright (queue)
  local last = queue.last
  if queue.first > last then error("queue is empty") end
  local value = queue[last]
  queue[last] = nil
  queue.last = last - 1
  return value
end

function RSQ.insert (queue, value, index)

  index = index or 0 --default value, inserts into beginning
  local adj_index = index + queue.first

  --if index is empty:
  if (queue[adj_index] == nil) then

    queue[adj_index] = { value }

    if (queue.last < adj_index) then
      queue.last = adj_index
    elseif (queue.first > adj_index) then
      queue.first = adj_index
    end

  else --otherwise
    table.insert(queue[adj_index], value)
  end
end

function RSQ.size (queue)
  return queue.last - queue.first + 1
end
