function unpack(t,i)
    i=i or 1
    if t[i] ~= nil then
        return t[i], unpack(t, i + 1)
    end
end
function f(...)
    arg = {...}
    a,b,c = unpack(arg)
    print(c..a..b)
end


f("1","2","3")