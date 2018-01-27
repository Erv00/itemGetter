local c = require("component")
local conn = c.tunnel
local e = require("event")
local database = {}
local slotIndex = 1
local chestIndex = 1

function send(...)
    local arg = {...}
    print("Sent! proto: "..arg[1])
    conn.send(table.unpack(arg))
end
function waitResponse()
    local id,_,_,_,_,proto,code = e.pullMultiple("modem_message","interrupted")
    if id == "interrupted" then
        os.exit()
    end
    return code
end

function createEntry(name,chest,slot,amm)
    local tmp = name.."+"..chest.."+"..slot.."+"..amm
    return tmp
end

function unpackEntry(entry)
    local arr = {}
    for v in string.gmatch(entry,'%w+') do
        arr[#arr+1] = v
    end
    return arr[1],arr[2],arr[3],arr[4]
end

while true do
    print("Welcome!")
    print("1 - Stash Item(s)")
    local ch = io.read()
    if ch=="1" then
        ::again::
        print("How many different itemstacks will you stash?(max 27)")
        local num = tonumber(io.read())
        if num > 27 then
            print("I said max 27")
            goto again
        end
        print("Define itemstacks IN ORDER!")
        for i=1,num do
            local id,name,amm = ""
            --id
            io.write("ID:")
            id = tonumber(io.read())
            --name
            ::getName::
            io.write("Name:(alpha-numerical characters and spaces only)")
            name = io.read()
            --check name for illegals
            if string.find(name,'[^%w%s]') then
                print("I said alpha-numerical characters and spaces only")
                goto getName
            end
            --get ammount
            io.write("Ammount:")
            amm = tonumber(io.read())

            print()
            --add to table
            if not database[id] then
                database[id] = createEntry(name,chestIndex,slotIndex,amm)
                slotIndex = slotIndex + 1
                if slotIndex > 27 then
                    slotIndex = 1
                    chestIndex = chestIndex + 1
                end
            else
                data = database[id];
                name,chest,slot,have = unpackEntry(data)
                database[id] = createEntry(name,chest,slot,have+amm)
            end
        end
        print("Dumping database")
        for k,v in pairs(database) do
            print(v)
        end
        print("Put items in the chest, then press a key")
        e.pull("key_down")
        send("collect")
        if waitResponse() == 200 then
            send("stash",2)
            if waitResponse() == 200 then
                print("Done")
            else
                print("Not good")
            end
        else
            print("Could not collect")
        end
    end
end