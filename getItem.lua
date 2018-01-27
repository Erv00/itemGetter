local currentPos = 0
local tileID = -1
local e = require("event")
local c = require("component")
local robot = c.robot
local s = require("sides")
local inv = c.inventory_controller
local conn = c.tunnel

function forward()
    robot.move(s.forward);
    tileID = tileID + 2
end
function back()
    robot.move(s.back)
    tileID = tileID - 2
end
function turnLeft()
    robot.turn(false)
end
function turnRight()
    robot.turn(true)
end

function gotoChest(id)
    if id == currentPos then
        return
    elseif (tileID+1==id) or (tileID==id) then
        turnLeft()
        turnLeft()
        currentPos = id
        return
    elseif id > currentPos then
        if currentPos~=0 then
            if currentPos%2==0 then
                turnRight()
            else
                turnLeft()
            end
        end
        while(id~=tileID or id~=tileID+1) do
            if(id==tileID or id==tileID+1)then
                break
            end
            forward()
        end
        if id%2==0 then
            turnLeft()
        else
            turnRight()
        end
        currentPos = id
        return
    else
        if currentPos~=0 then
            if currentPos%2==0 then
                turnRight()
            else
                turnLeft()
            end
        end
        while(id~=tileID or id~=tileID+1) do
            if(id==tileID or id==tileID+1)then
                break
            end
            back()
        end
        if id%2==0 then
            turnLeft()
        else
            turnRight()
        end
        currentPos = id
        return
    end
end

function respond(...)
    arg = {...}
    print(table.unpack(arg))
    conn.send(table.unpack(arg))
end

function getFrom(chest,slot,amm)
    gotoChest(chest)
    if not inv.suckFromSlot(s.forward,slot,amm) then
        respond("error","getting")
        return false
    end
    return true
end
function stash(chest,slot,amm,from)
    gotoChest(chest)
    robot.select(from)
    if not inv.dropIntoSlot(s.forward,slot,amm) then
        respond("error","dropping")
        robot.select(1)
        return false
    end
    robot.select(1)
    return true
end
function stash(chest)
    gotoChest(chest)
    for i=1,27 do
        robot.select(i)
        inv.dropIntoSlot(s.forward,i)
    end
    robot.select(1)
    return true
end
function collect()
    if currentPos == 0 then
        turnLeft()
        turnLeft()
        for i=1,27 do
            inv.suckFromSlot(s.forward,i,64)
        end
        turnLeft()
        turnLeft()
    end
    respond("response",200)
end

while true do
    id,_,_,_,_,proto,chest,slot,amm,from = e.pullMultiple("modem_message","interrupted")
    if id == "interrupted" then
        os.exit()
    end
    print("Received: "..proto)
    if proto == "get" then
        getFrom(chest,slot,amm)
    elseif proto == "stash" then
        if slot then
            stash(chest,slot,amm,from)
        else
            stash(chest)
        end
        respond("response",200)
    elseif proto == "dump" then
        error("Not implemented")
    elseif proto == "collect" then
        collect()
    end
end