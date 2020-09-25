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
    local i = 1
    local test6 = (my_functions:generate(5,10))
    while true do
        wait();
        test6 = (my_functions:generate(5,10))
        -- my_functions:printNestedList(test6,0)
        print("print "..string.format("%i",i))
        my_functions:printmaze(test6)
            
        local test12 = my_functions:fillgaps(test6)
        print("print7")
        my_functions:printmaze(test12)

        break
        -- local test7 = (my_functions:mirror(test6))
        -- print("print2")
        -- my_functions:printmaze(test7)
        -- local test8 = my_functions:transposeright(test7);
        -- print("print3")
        -- my_functions:printmaze(test8)
        -- local squareshapes = {	
        --     {{true,true,true},{true,true,true},{true,true,true}}, -- 3 size square
        --     {{true,true},{true,true}}, -- 2 size square
        --     {{true}}, -- 1 size square
        -- };
        -- local test9 = my_functions:generate(10,10,squareshapes)
        -- print("print4")
        -- my_functions:printmaze(test9)
        -- local test10 = (my_functions:mirror(test9))
        -- print("print5")
        -- my_functions:printmaze(test10)
        -- local test11 = my_functions:transposeright(test10);
        -- print("print6")
        -- my_functions:printmaze(test11)
    end
end)

coroutine.resume(newThread)