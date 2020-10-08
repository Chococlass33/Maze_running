local sensor = {};
sensor.__index = sensor;

function sensor:generate(north, east, south, west)
    local newsensor = {};
    setmetatable(newsensor,sensor);
    newsensor.obstacles = {north,east,south,west}; 
    return newsensor;
end

