local c = require("component")
local conn = c.tunnel
local e = require("event")

function send(...)
    arg = {...}
    print("Sent! proto: "..arg[1])
    conn.send(table.unpack(arg))
end
function waitResponse()
    id,_,_,_,_,proto,code = e.pullMultiple("modem_message","interrupted")
    if id == "interrupted" then
        os.exit()
    end
    return code
end

--function createEntry(name,chest,slot,amm)
--    tmp = name.."+"..chest.."+"..slot.."+"..amm
--    return tmp
--end

while true do
    print("Welcome!")
    print("1 - Stash Item(s)")
    ch = io.read()
    if ch=="1" then
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