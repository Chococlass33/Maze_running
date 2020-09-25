-- Inspired by Shaun LeBron's Pacman Maze Generator, Tetris Algorithm https://github.com/shaunlebron/pacman-mazegen
-- Create a grid, attempt to fill grid with tetris shapes defined in shapes



local mazefunction = {};

--Default Shapes to use if none are specified
--Shapes are a list of tables, each representing a shape. 
--Each shape is an X by Y rectangualar table representation, where a member is True where the piece is taking space, and False where it isn't taking space.
local localshapes = {	
	{{true,true,true},
	{false,true,false}},--tshape

	{{true,true,true},
	{false,false,true}},--lshape

	{{true,true},
	{false,true}},--smaller l piece
};

local translationx = {1,0,-1,0}
local translationy = {0,1,0,-1}

--Takes an array and return a new deep copy of the original
function mazefunction:deepCopy(original)
	local copy = {} 
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = mazefunction:deepCopy(v);
		end
		copy[k] = v;
	end
	return copy;
end

--Takes an array, returns a copy with a reflection vertically
function mazefunction:mirror(list)
	local newarray = table.create((#list * 2-1));
	for i = 1, #list do
		newarray[#list + i - 1] = list[i];
		newarray[#list - i + 1] = list[i];
	end
	return newarray;
end

--Takes a wall maze array, fills empty gaps in the inner side with random surrounding piece
function mazefunction:fillgaps(list)
	local newarray = mazefunction:deepCopy(list);
	for i = 2, #newarray - 1 do
		for j = 2, #newarray[i]-1 do
			if list[i][j][2] == 0 then
				local lowestsizepiecevalue = newarray[i+1][j][3];
				local lowestsizepieceindex = 1;
				for k = 2, 4 do
					if newarray[i+translationx[k]][j+translationy[k]][3] < lowestsizepiecevalue then
						lowestsizepiecevalue = newarray[i+translationx[k]][j+translationy[k]][3];
						lowestsizepieceindex = k;
					end
				end
				local piecenumber = newarray[i+translationx[lowestsizepieceindex]][j+translationy[lowestsizepieceindex]][2]
				local shapesize = newarray[i+translationx[lowestsizepieceindex]][j+translationy[lowestsizepieceindex]][3]
				newarray[i][j][1] = true;
				newarray[i][j][2] = piecenumber;
				newarray[i][j][3] = shapesize;
			end
		end
	end
	return newarray;
end

function mazefunction:getshapesize(shape)
	local size = 0;
	for i = 1, #shape do
		for j = 1, #shape[i] do
			if shape[i][j] then
				size = size + 1;
			end
		end
	end
	return size;
end

--Takes an table representing a wall maze, prints the piece values
function mazefunction:printmaze(list)
	for i = #list, 1, -1 do
		local text = "";
		for j = 1, #list[i] do
			text = text .. string.format("%03i", list[i][j][2])..",";
		end
		print(text);
	end
end

--Takes an array, recursively prints all the values inside, opening arrays inside
function mazefunction:printNestedList(list,TabLevel)

	if TabLevel == nil then
		TabLevel = 0
	end
	
	for Key,Value in pairs(list) do
		if typeof(Value) == "table" then
			print(string.rep("	",TabLevel)..Key.." : {");
			mazefunction:printNestedList(Value,TabLevel+1);
			print(string.rep("	",TabLevel).."}");
		else
			print(string.rep("	",TabLevel)..Key,Value);
		end
	end
	
end

--Takes an array, flips it 90 degrees to the right
function mazefunction:transposeright(array)
	
	local xlength = #array;
	local ylength = (#array[1]);

	local newtable = table.create(ylength);
	for i = 1, ylength do
		newtable[i] = table.create(xlength);
		for j = 1, xlength do
			newtable[i][xlength-j+1] = array[j][i];
		end
	end
	return newtable;
end

--Takes an array, flips the array upside down
function mazefunction:fliptable(array)
	local size = #array;
	local newtable = table.create(size);
	for i = 1, size do
		newtable[size - i + 1] = array[i];
	end
	return newtable;
end

--Takes a list of shapes, returns a dictionary, with a shape as a key and a list of 8 transforms as the value
local shapepermutator = function(shapes)
	if shapes == nil then
		shapes = localshapes;
	end
	local permutation = {};
	for i = 1, #shapes do
		local templist = table.create(8);
		templist[1] = mazefunction:deepCopy(shapes[i]);
		templist[2] = mazefunction:transposeright(templist[1]);
		templist[3] = mazefunction:transposeright(templist[2]);
		templist[4] = mazefunction:transposeright(templist[3]);
		templist[5] = mazefunction:fliptable(templist[1]);
		templist[6] = mazefunction:transposeright(templist[5]);
		templist[7] = mazefunction:transposeright(templist[6]);
		templist[8] = mazefunction:transposeright(templist[7]);
		permutation[shapes[i]] = templist;
	end
	return permutation;
end

--Takes a table representing the wall maze, a shape representing a piece, a location to drop the piece in, and the piece number to add.
--Attempts to drop the piece in the location given.
--Returns the table with the dropped piece, or nil if the drop is invalid.
function mazefunction:tabledrop(array,shape,location, number)

	local sizex = #shape;
	local sizey = #shape[1];
	local shapesize = mazefunction:getshapesize(shape);
	
	local depth = #array;
	local length = #array[1];

	local continue = true;
	local collided = false;
	local returntable = nil;
	-- Keep trying to drop until you reach a border
	while continue do
		local tablecopy = mazefunction:deepCopy(array);
		for i = 0, sizex -1 do
			for j = 0, sizey - 1 do
				if(depth-i <= 0) or (location + j > length) or (location + j <= 0)then
					continue = false;
					break;
					-- print('fail due to out of bounds')
					-- print(depth)
					-- print(depth-i)
					-- print(length)
					-- print(location + j)
				elseif (array[depth - i][location + j][1] == true) and (shape[i+1][j+1] == true) then
					collided = true;
					break;
					-- print('fail due to collision')
				elseif (shape[i+1][j+1] == true) then
					tablecopy[depth - i][location + j][1] = true;
					tablecopy[depth - i][location + j][2] = number;
					tablecopy[depth - i][location + j][3] = shapesize;
					-- print("success");
				end
			end
		end

		--If the drop is successful, save the table, and redo one level down. If collided, just redo one level down.
		if continue then
			if not collided then
				returntable = tablecopy;
			else 
				collided = false;
			end
			depth = depth - 1;
			-- print("continuing")
		end
	end
	return returntable;
end

function mazefunction:bruteheuristic(array,shape,deepesthole,deepestdepth, number, shapepermutation)
	local currenttable = nil;
	local besttablescore = 0;
	local currentshape = shapepermutation[shape];
	for i = 1, #currentshape do
		for j = 0, #currentshape[i][1]-1 do
			local temptable = mazefunction:tabledrop(array,currentshape[i],deepesthole-j,number);
			if temptable ~= nil then
				-- print("Calculating Heuristic Score")
				local score = mazefunction:heuristicsaux(temptable, deepesthole,deepestdepth);
				-- print(score)
				if score > besttablescore then
					currenttable = temptable;
					besttablescore = score;
				end
			end
		end
	end
		
	-- print('best score')
	-- print(besttablescore)
	return currenttable;
end


function mazefunction:heuristicsaux(array,deepesthole,deepestdepth)
	local score = 0;
	local multiplier = #array;
	if array[deepestdepth][deepesthole][2] == 0 then
		return -1
	end
	for i = 1, #array do
		for j = 1, #array[1] do
			if array[i][j][1] == true then
				score = score + multiplier;
			end
		end
		multiplier = multiplier - 1;
	end
	return score;
end


function mazefunction:getdeepest(array, deepest, ignorelength)
	if ignorelength == nil then
		ignorelength = 0;
	end
	local sizex = #array;
	local sizey = #array[1];
	for i = deepest, (sizex) do
		for j = ignorelength + 1, sizey do
			if (array[i][j][1] == false) then
				-- -- Depreciated No Roof Logic, just try to fill it anyways
				-- local noroof = true;
				-- for k = i, sizex do
				-- 	if(array[k][j][1] == true) then
				-- 		noroof = false;
				-- 		break;
				-- 	end
				-- end
				-- if(noroof) then
				local deepestholex = i;
				local deepestholey = j;
				if deepestholey > ignorelength then
					return deepestholex, deepestholey, true;
				end
				-- end
			end
		end
	end
	return -1, -1, false;
end

function mazefunction:generate(sizex,sizey, shapes)
	if shapes == nil then
		shapes = localshapes;
	end

	local shapepermutation = shapepermutator(shapes)

	local array = table.create(sizex);

	--Generate
	for i = 1, sizex do
		array[i] = table.create(sizey);
		for j = 1, sizey do
			array[i][j] = {false, 0,0}; --  is-full, value of the piece filling here, size of the piece filling here
		end
	end

	local stillworking = true;
	local piecevalue = 1;
	local deepest = 1;
	local ignorelength = nil;

	while(stillworking) do
		wait();
		local deepestholex = 1;
		local deepestholey = 1;
		deepestholex, deepestholey = mazefunction:getdeepest(array,deepest,ignorelength);
		-- print("Deep hole at")
		-- print(deepestholex)
		-- print(deepestholey)
		
		local tempshapes = shapes;
		local x = #tempshapes;
		for i = 1, x do
			local randint = math.random(#tempshapes)
			local randompiece = tempshapes[randint]
			local temptable = mazefunction:bruteheuristic(array,randompiece,deepestholey,deepestholex,piecevalue,shapepermutation);
			if temptable ~= nil then
				array = temptable;
				piecevalue = piecevalue + 1;
				deepest = deepestholex;
				break;
			elseif i == x then
				if deepestholey  > 0 then
					ignorelength = deepestholey;
				else
					deepest = deepest + 1;
					ignorelength = nil;
				end

				if deepest > sizex then
					stillworking = false;
				end
			else
				table.remove(tempshapes,randint);
			end
		end
	end
	return array;
end





function mazefunction:generatefloor(wallarray)
	local floorarrayx = #wallarray + 2;
	local floorarrayy = #wallarray[1] + 2;
	local array = table.create(floorarrayx);
	for i = 1, floorarrayx do
		array[i] = table.create(floorarrayy);

		
	end
end

return mazefunction;