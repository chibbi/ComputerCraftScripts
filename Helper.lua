function GetItem(desiredItemID) 
    for i = 1, 16, 1 do
        local data = turtle.getItemDetail(i)
        if(data ~= nil) then
            if(data.name == desiredItemID) then
                return i
            end
        end
    end
end