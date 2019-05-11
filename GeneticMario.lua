FILE_NAME = "SMB1-1.state"  --archivo de juego guardado iniciando el nivel

local command = {
	"nothing",
	"P1 A",
	"P1 B",
	"P1 Right",
	"P1 Left",
	"P1 Down",
}


local genes = {
	{command[1]},
	{command[3]},
	{command[2]},
	{command[2],command[3]},
	{command[6]},
	{command[6],command[3]},
	{command[4]},
	{command[4],command[3]},
	{command[4],command[2]},
	{command[4],command[2],command[3]},
	{command[6],command[4]},
	{command[6],command[4],command[3]},
	{command[6],command[4],command[2]},
	{command[6],command[4],command[2],command[3]},
	{command[5]},
	{command[5],command[3]},
	{command[5],command[2]},
	{command[5],command[2],command[3]},
	{command[5],command[6]},
	{command[5],command[6],command[3]},
	{command[5],command[6],command[2]},
	{command[5],command[6],command[2],command[3]}
}


function initializationRandom(p,size)
	local chromossomes = {}
	local lgenes = genes
	for i = 1, p, 1
	do
		local chromossome = {}
		for j = 1,size,1
		do
			local gene = math.random(1,22)
			chromossome[j] = lgenes[gene]
		end
		chromossomes[i] = chromossome
	end
	return chromossomes
end

function initializationGuided(p,size)
	local chromossomes = {}
	local positionss = {}
	local lgenes = genes
	for i = 1, p, 1
	do
		local chromossome = {}
		local positions = {}
		for j = 1,size,1
		do
			local gene = math.random(1,22)
			chromossome[j] = lgenes[gene]
			local pos = {}
			pos["x"] = -1
			pos["y"] = -1
			positions[j] = pos
		end
		positionss[i] = positions
		chromossomes[i] = chromossome
	end
	return chromossomes,positionss
end

--[[ r = initializationRandom(3,5)
for k=1, #r,1 do
	print(k)
	local v = r[k]
	for l = 1,5,1
	do
		local v2 = v[l]
		print(v2)
	end
end ]]


function fitness(mario)
	return mario["d"] + 8*mario["t"] + 1024*mario["s"]
end

function tournament(population,k)
	local winner = {}
	local bestFitness = -1
	for i  = 1,k,1 do
		local ind = math.random(1,#population)
		local fitness = fitness(population[ind])
		if fitness > bestFitness then
			winner = population[ind]
			bestFitness = fitness
		end
	end

	return winner
end

function elite_mario(mario_population)
	local best = {}
	local bestFitness = -1
	for i  = 1,#mario_population,1 do
		local mario = mario_population[i]
		if mario["fit"] > bestFitness then
			best = mario_population[i]
			bestFitness = mario["fit"]
		end
	end

	return best
end

function crossover_random(chromossome1, chromossome2) --crossover of a pair of chromossomes and return the results childs
	local index = math.random(1, #chromossome1)
	local child1 = {}
	local child2 = {}
	for i = 1, index, 1 do
		local gene = chromossome1[i]
		local child_gene = {}
		for j = 1, #gene, 1 do
			child_gene[j] = gene[j]
		end
		child1[i] = child_gene

		gene = chromossome2[i]
		child_gene = {}
		for j = 1, #gene, 1 do
			child_gene[j] = gene[j]
		end

		child2[i] = child_gene
	end
	for i = index+1, #chromossome1, 1 do
		local gene = chromossome2[i]
		local child_gene = {}
		for j = 1, #gene, 1 do
			child_gene[j] = gene[j]
		end
		child1[i] = child_gene

		gene = chromossome1[i]
		child_gene = {}
		for j = 1, #gene, 1 do
			child_gene[j] = gene[j]
		end

		child2[i] = child_gene
	end
	return child1, child2
end

function euclidian(x1,y1,x2,y2)
	return math.sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2))
end

function crossover_guided(mario1,mario2,threshold)
	local chromossome1 = mario1["c"]
	local chromossome2 = mario2["c"]
	local pos1 = mario1["pos"]
	local pos2 = mario2["pos"]

	local smallest = 1000000000
	local n = -1
	for i = 1, #pos1,1 do
		local pos1_values = pos1[i]
		local pos2_values = pos2[i]
		local x1 = pos1_values["x"]
		local y1 = pos1_values["y"]
		local x2 = pos2_values["x"]
		local y2 = pos2_values["y"]
		if x1 == -1 or x2 == -1 then
			break
		end
		local delta = euclidian(x1, y1, x2, y2)
		if delta < smallest and delta < threshold  then
			print("GOTTEM")
			smallest = delta
			n = i
		end
	end

	local child1 = {}
	local child2 = {}
	for i = 1, n, 1 do
		child1[i] = chromossome1[i]
		child2[i] = chromossome2[i]
	end

	for i = n+1, #chromossome1, 1 do

		child1[i] = chromossome2[i]

		child2[i] = chromossome1[i]
	end

	return child1,child2
end


function mutation_random(chromossome, mutation_rate)
	local qnt_mutation = mutation_rate*#chromossome
	math.floor(qnt_mutation)
	for i = 1, qnt_mutation, 1 do
		local ind = math.random(1, #chromossome)
		local gene = math.random(1, 22)
		chromossome[ind] = genes[gene]
	end
end

function mutation_guided(mario,w_0,W)
	if current_mario["W"] % W == 0 then
		print("THE PURGE")
	end
	local window = 0
	if mario["fit"] > mario["l_fit"] then
		mario["w"] = w_0
		window = w_0
	elseif current_mario["W"] % W == 0 and mario["l_fit"] <= mario["fit_w"] then
		if 2*mario["w"] <= mario["death"] then
			mario["w"] = 2*mario["w"]
			window = 2*mario["w"]
		end
	else
		window = mario["w"]
	end

	local chromossome = mario["c"]
	for i=mario["death"]-window,mario["death"],1 do
		local gene = math.random(1,22)
		chromossome[i] = genes[gene]
	end

	mario["w"] = window

end

function evolvePopulation(mario_population,k,crossover_rate,mutation_rate)
	local new_population = {}
	local i = 1
	while (i <= #mario_population) do
		if math.random() < crossover_rate and i+2 <= #mario_population then
			local winner1 = tournament(mario_population,k)
			local winner2 = tournament(mario_population,k)

			local child1 = {}
			local child2 = {}
			child1["c"],child2["c"] = crossover_random(winner1["c"],winner2["c"])

			child1["c"] = mutation_random(child1["c"],mutation_rate)
			child2["c"] = mutation_random(child2["c"],mutation_rate)

			new_population[#new_population+1] = child1
			new_population[#new_population+1] = child2
			i = i + 2
		else
			print("X-MEN TIME")
			local winner = tournament(mario_population,k)
			local winner_copy = {}

			--Hard-copying chromossome
			local c_winner = winner["c"]
			local c_winner_copy = {}
			for j = 1, #c_winner,1 do
				local gene = c_winner[j]
				local gene_copy = {}
				for k = 1, #gene,1 do
					gene_copy[k] = gene[k]
				end
				c_winner_copy[j] = gene_copy
			end

			winner_copy["c"] = c_winner_copy

			mutation_random(winner_copy,mutation_rate)

			new_population[#new_population+1] = winner_copy
			i= i + 1
		end
	end

	return new_population
end

function copy_mario(mario)
	local copy = {}

	copy["w"] = mario["w"]
	copy["W"] = mario["W"]
	copy["fit"] = mario["fit"]
	copy["fit_w"] = mario["fit_w"]
	copy["l_fit"] = mario["l_fit"]
	copy["death"] = mario["death"]

	--Hard-copying chromossome
	local c_mario = mario["c"]
	local c_copy = {}
	for j = 1, #c_mario,1 do
		local gene = c_mario[j]
		local gene_copy = {}
		for k = 1, #gene,1 do
			gene_copy[k] = gene[k]
		end
		c_copy[j] = gene_copy
	end

	copy["c"] = c_copy

	return copy
end

function evolvePopulationGuided(mario_population,k,crossover_rate,w_0,W,threshold)
	local best = elite_mario(mario_population)
	local new_population = {}
	new_population[1] = best -- Elitism

	local i = 1
	while (i <= #mario_population-1) do
		if math.random() < crossover_rate and i+2 <= #mario_population then
			print("SEX TIME")
			local winner1 = tournament(mario_population,k)
			local winner2 = tournament(mario_population,k)

			local child1 = {}
			local child2 = {}
			child1["fit"] = 0
			child1["l_fit"] = 0
			child1["fit_w"] = 0
			child1["w"] = w_0
			child1["W"] = 0

			child2["fit"] = 0
			child2["l_fit"] = 0
			child2["fit_w"] = 0
			child2["w"] = w_0
			child2["W"] = 0

			local positions1 ={}
			local positions2 = {}
			for j = 1,#winner1["pos"],1
			do
				local pos1 = {}
				pos1["x"] = -1
				pos1["y"] = -1
				positions1[j] = pos1
				local pos2 = {}
				pos2["x"] = -1
				pos2["y"] = -1
				positions2[j] = pos2
			end

			child1["pos"] = positions1
			child2["pos"] = positions2

			child1["c"],child2["c"] = crossover_guided(winner1,winner2,threshold)

			new_population[#new_population+1] = child1
			new_population[#new_population+1] = child2
			i = i + 2
		else
			print("X-MEN TIME")
			local winner = tournament(mario_population,k)
			local winner_copy = copy_mario(winner)

			mutation_guided(winner_copy,w_0,W)

			-- Restart values
			local positions = {}
			for j = 1,#winner["pos"],1
			do
				local pos = {}
				pos["x"] = -1
				pos["y"] = -1
				positions[j] = pos
			end
			winner_copy["pos"] = positions

			new_population[#new_population+1] = winner_copy
			i= i + 1
		end
	end

	return new_population
end

function read_time()
	c = memory.readbyte(0x7F8)
	d = memory.readbyte(0x7F9)
	u = memory.readbyte(0x7FA)
	return c*100+d*10+u
end

function save_state(mario,generation,is_best)
	-- Opens a file in append mode
	if is_best == true then
		file = io.open("best_mario_".. bests .. ".txt", "w+")
	else
		file = io.open("mario_" .. generation .. ".txt","w+")
	end

	-- sets the default output file as test.lua
	io.output(file)

	-- appends a word test to the last line of the file
	io.write(mario)
end

--------------------------------------------------------- MAIN ROUTINE ------------------------------------------
local answer = "1"

if answer == "0" then
	g = 5 --granularity
	P = 20 --Population size
	C = 0.005 -- Crossover rate
	M = 0.05 -- Mutation Rate
	T_s = 3 -- tournament size

	-- Generate initial population of marios
	console.writeline("Generating random chromossomes")
	chromossomes_population = initializationRandom(P,10000/g)
	mario_population = {}
	for i = 1,P,1
	do
		mario = {}
		mario["c"] = chromossomes_population[i] -- mario's chromossome
		mario_population[i] = mario
	end

	json = require "json"
	bests = 1
	console.writeline("Ready. Playing with first generation")
	generation = 0
	best_mario = {}
	best_fitness = -1
	best_changed = false
	while true do
		generation = generation + 1
		for i=1, #mario_population,1 do	-- for each mario
			current_mario = mario_population[i]
			current_chromossome = current_mario["c"]
			completed = 1
			endgame = false
			savestate.load(FILE_NAME); -- load first level

			for j=1,#current_chromossome,1 -- play the game
			do
				controller = {}
				current_gene = current_chromossome[j]
				for k=1,#current_gene,1
				do
					controller[current_gene[k]] = true
				end
				for k = 1,g,1 do
					joypad.set(controller)
					emu.frameadvance()
					if memory.readbyte(0x000E) == 0x06 then -- mario died
						completed = 0
						time_left = read_time()
						print(j)
						endgame = true
						break
					end
					if memory.readbyte(0x001D) == 0x03 then -- mario completed the game / sliding the pole
						print("AEEEE PORRA")
						endgame = true
						break
					end
				end

				if endgame == true then
					break
				end

			end

			if completed == 1 then
				print("AEEEE PORRA CONFIRMED")
			end

			current_mario["d"] = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --mario X position in level
			current_mario["t"] = time_left
			current_mario["s"] = completed
			current_mario["gen"] = generation
			fit = fitness(current_mario)
			current_mario["fit"] = fit
			print("Mario ".. i .. " from generation " .. generation .. ".\n Distance = " .. current_mario["d"] .. "\n Time left = " .. current_mario["t"] .. "\n Fitness = " .. fit)
			if fit > best_fitness then
				best_fitness = fit
				best_mario = current_mario
				best_changed = true
			end
			save_state(json.encode(current_mario),i,false)
		end

		if best_changed == true then
			best = bests+1
			save_state(json.encode(best_mario),generation,true)
			best_changed = false
		end

		console.writeline("Best fitness yet = " .. best_fitness)
		console.writeline("Evolving generation" .. "(" .. generation + 1 .. ")")

		math.randomseed(os.time())
		mario_population = evolvePopulation(mario_population,T_s,C,M)

	end
else
	g = 5 --granularity
	P = 10 --Population size
	C = 0.2 -- Crossover rate
	w_0 = 2
	W = 2
	threshold = 5
	T_s = 3 -- tournament size

	-- Generate initial population of marios
	console.writeline("Generating random chromossomes")
	chromossomes_population, positions_populations = initializationGuided(P,10000/g)
	mario_population = {}
	for i = 1,P,1
	do
		mario = {}
		mario["c"] = chromossomes_population[i] -- mario's chromossome
		mario["pos"] = positions_populations[i]
		mario["fit"] = 0
		mario["l_fit"] = 0
		mario["fit_w"] = 0
		mario["w"] = w_0
		mario["W"] = 0
		mario_population[i] = mario
	end

	json = require "json"
	bests = 1
	console.writeline("Ready. Playing with first generation")
	generation = 0
	best_mario = {}
	best_fitness = -1
	best_changed = false
	while true do
		generation = generation + 1
		for i=1, #mario_population,1 do	-- for each mario
			current_mario = mario_population[i]
			current_mario["l_fit"] = current_mario["fit"]
			current_mario["W"] = current_mario["W"]+1
			current_chromossome = current_mario["c"]
			current_positions = current_mario["pos"]
			completed = 1
			endgame = false
			savestate.load(FILE_NAME); -- load first level

			for j=1,#current_chromossome,1 -- play the game
			do
				controller = {}
				current_gene = current_chromossome[j]

				for k=1,#current_gene,1
				do
					local button = current_gene[k]
					controller[button] = true
				end

				for k = 1,g,1 do
					joypad.set(controller)
					emu.frameadvance()
					pos = {}
					pos["x"] = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)
					pos["y"] = memory.readbyte(0x03B8) + 16
					current_positions[j] = pos
					if memory.readbyte(0x000E) == 0x06 then -- mario died
						completed = 0
						time_left = read_time()
						current_mario["death"] = j
						endgame = true
						break
					end
					if memory.readbyte(0x001D) == 0x03 then -- mario completed the game / sliding the pole
						print("AEEEE PORRA")
						endgame = true
						break
					end
				end

				if endgame == true then
					break
				end
			end

			current_mario["d"] = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --mario X position in level
			current_mario["t"] = time_left
			current_mario["s"] = completed
			current_mario["gen"] = generation

			fit = fitness(current_mario)
			current_mario["fit"] = fit

			if current_mario["W"] % W == 0 then
				current_mario["fit_w"] = current_mario["fit"]
			end

			print("Mario ".. i .. " from generation " .. generation .. ".\n Distance = " .. current_mario["d"] .. "\n Time left = " .. current_mario["t"] .. "\n Fitness = " .. fit)

			if fit > best_fitness then
				best_fitness = fit
				best_mario = current_mario
				best_changed = true
			end
			save_state(json.encode(current_mario),i,false)
		end

		if best_changed == true then
			best = bests+1
			save_state(json.encode(best_mario),generation,true)
			best_changed = false
		end

		console.writeline("Best fitness yet = " .. best_fitness)
		console.writeline("Evolving generation" .. "(" .. generation + 1 .. ")")

		math.randomseed(os.time())
		mario_population = evolvePopulationGuided(mario_population,T_s,C,w_0,W,threshold)
	end
end
