local DynamicObj = {};
DynamicObj.__index = DynamicObj;

function DynamicObj.new(object)
    local dynamicobj = {}
    setmetatable(dynamicobj,DynamicObj)
    dynamicobj.object = object
end

