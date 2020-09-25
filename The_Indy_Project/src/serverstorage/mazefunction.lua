-- Inspired by Shaun LeBron's Pacman Maze Generator, Tetris Algorithm https://github.com/shaunlebron/pacman-mazegen
-- Create a grid, attempt to fill grid with tetris shapes defined in shapes



local mazefunction = {};
local shapes = {	
	{{true,true,true},{false,true,false}},--tshape
	{{true,true,true},{false,false,true}},--lshape
	{{false,true,true},{true,true,false}},--zpiece
};

function mazefunction:deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = mazefunction:deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

function mazefunction:mirror(list)
	
	
end

function mazefunction:printmaze(list)
	for i = #list, 1, -1 do
		local text = ""
		for j = 1, #list[i] do
			text = text .. string.format("%03i", list[i][j][2])..","
		end
		print(text);
	end
end

function mazefunction:printNestedList(list,TabLevel)
	
	for Key,Value in pairs(list) do
		if typeof(Value) == "table" then
			print(string.rep("	",TabLevel)..Key.." : {")
			mazefunction:printNestedList(Value,TabLevel+1)
			print(string.rep("	",TabLevel).."}")
		else
			print(string.rep("	",TabLevel)..Key,Value)
		end
	end
	
end

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

function mazefunction:fliptable(array)
	local size = #array;
	local newtable = table.create(size);
	for i = 1, size do
		newtable[size - i + 1] = array[i];
	end
	return newtable;
end

local shapepermutation = function()
	local permutation = {};
	for i = 1, #shapes do
		local templist = table.create(8);
		templist[1] = mazefunction:deepCopy(shapes[i])
		templist[2] = mazefunction:transposeright(templist[1])
		templist[3] = mazefunction:transposeright(templist[2])
		templist[4] = mazefunction:transposeright(templist[3])
		templist[5] = mazefunction:fliptable(templist[1])
		templist[6] = mazefunction:transposeright(templist[5])
		templist[7] = mazefunction:transposeright(templist[6])
		templist[8] = mazefunction:transposeright(templist[7])
		permutation[shapes[i]] = templist;
	end
	return permutation;
end

shapepermutation = shapepermutation()


function mazefunction:tabledrop(array,shape,location, number)

	local sizex = #shape;
	local sizey = #shape[1];
	
	local depth = #array;
	local length = #array[1];

	local continue = true;
	local returntable = nil;

	while continue do
		local tablecopy = mazefunction:deepCopy(array);
		for i = 0, sizex -1 do
			for j = 0, sizey - 1 do
				if(depth-i <= 0) or (location + j > length) or (location + j <= 0)then
					continue = false;
					-- print('fail due to out of bounds')
					-- print(depth)
					-- print(depth-i)
					-- print(length)
					-- print(location + j)
				elseif (array[depth - i][location + j][1] == true) and (shape[i+1][j+1] == true) then
					continue = false;
					-- print('fail due to collision')
				elseif (shape[i+1][j+1] == true) then
					tablecopy[depth - i][location + j][1] = true;
					tablecopy[depth - i][location + j][2] = number;
					-- print("success");
				else 
				end
			end
		end
		if continue then
			returntable = tablecopy;
			depth = depth - 1;
			-- print("continuing")
		end
	end
	return returntable;
end

function mazefunction:bruteheuristic(array,shape,deepesthole,number)
	local currenttable = nil;
	local besttablescore = 0;
	local currentshape = shapepermutation[shape];
	for i = 1, #currentshape do
		for j = 0, #currentshape[i][1]-1 do
			local temptable = mazefunction:tabledrop(array,currentshape[i],deepesthole-j,number);
			if temptable ~= nil then
				-- print("Calculating Heuristic Score")
				local score = mazefunction:heuristicsaux(temptable);
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


function mazefunction:heuristicsaux(array)
	local score = 0;
	local multiplier = #array;
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
				local noroof = true
				for k = i, sizex do
					if(array[k][j][1] == true) then
						noroof = false;
						break;
					end
				end
				if(noroof) then
					local deepestholex = i;
					local deepestholey = j;
					if deepestholey > ignorelength then
						return deepestholex, deepestholey, true
					end
				end
			end
		end
	end
	return -1, -1, false
end

function mazefunction:generate(sizex,sizey)
	local array = table.create(sizex);
	local piecesize = #shapes;

	--Generate
	for i = 1, sizex do
		array[i] = table.create(sizey)
		for j = 1, sizey do
			array[i][j] = {false, 0}; --  is-full, value of the piece filling here
		end
	end

	local stillworking = true;
	local piecevalue = 1
	local deepest = 1;
	local ignorelength = nil;

	while(stillworking) do
		wait();
		local deepestholex = 1;
		local deepestholey = 1;
		local founddeepest = false;
		deepestholex, deepestholey, founddeepest = mazefunction:getdeepest(array,deepest,ignorelength);
		-- print("Deep hole at")
		-- print(deepestholex)
		-- print(deepestholey)
		
		local localshapes = shapes;
		local x = #localshapes;
		for i = 1, x do
			local randint = math.random(#localshapes)
			local randompiece = localshapes[randint]
			local temptable = mazefunction:bruteheuristic(array,randompiece,deepestholey,piecevalue);
			if temptable ~= nil then
				array = temptable; 
				piecevalue = piecevalue + 1;
				deepest = deepestholex;
				break;
			elseif i == x then
				if deepestholey  > 0 then
					ignorelength = deepestholey;
				else
					deepest = deepest - 1;
					ignorelength = nil;
				end

				if deepest == 1 then
					stillworking = false;
				end
			else
				table.remove(localshapes,randint)
			end
		end
	end
	return array;
end

return mazefunction	