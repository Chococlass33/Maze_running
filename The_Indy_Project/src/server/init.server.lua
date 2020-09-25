print("Hello world, from server!") 

local serverstorage = game:GetService("ServerStorage")
local my_functions = require(serverstorage.ServerStorage.mazefunction)

local test1 = {{1,2},{3,4},{5,6}}
local test2 = my_functions:transposeright(test1);
local test3 = my_functions:transposeright(test2);
local test4 = my_functions:transposeright(test3);
local test5 = my_functions:fliptable(test1);

my_functions:printNestedList(test1,0)
my_functions:printNestedList(test2,0)
my_functions:printNestedList(test3,0)
my_functions:printNestedList(test4,0)
my_functions:printNestedList(test5,0)

local newThread = coroutine.create(function()
    local test = (my_functions:generate(10,10))
    my_functions:printNestedList(test,0)
    my_functions:printmaze(test)
end)

coroutine.resume(newThread)