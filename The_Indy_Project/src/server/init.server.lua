print("Hello world, from server!") 

local serverstorage = game:GetService("ServerStorage")
local my_functions = require(serverstorage.mazefunction)

local test1 = {{1,2},{3,4},{5,6}}
local test2 = my_functions:transposeright(test1);
local test3 = my_functions:transposeright(test2);
local test4 = my_functions:transposeright(test3);
local test5 = my_functions:fliptable(test1);

-- my_functions:printNestedList(test1,0)
-- my_functions:printNestedList(test2,0)
-- my_functions:printNestedList(test3,0)
-- my_functions:printNestedList(test4,0)
-- my_functions:printNestedList(test5,0)

local newThread = coroutine.create(function()
    local test6 = (my_functions:generate(5,10))
    -- my_functions:printNestedList(test6,0)
    print("print1")
    my_functions:printmaze(test6)
    local test7 = (my_functions:mirror(test6))
    print("print2")
    my_functions:printmaze(test7)
    local test8 = my_functions:transposeright(test7);
    print("print3")
    my_functions:printmaze(test8)
end)

coroutine.resume(newThread)