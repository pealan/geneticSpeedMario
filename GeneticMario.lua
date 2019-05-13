FILE_NAME = "SMB1-1.state"  --archivo de juego guardado iniciando el nivel
seed = os.time()
math.randomseed(seed)
print(seed)
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
	{command[2]},
	{command[2],command[3]},
	{command[6]},
	{command[6],command[3]},
	{command[4]},
	{command[4],command[3]},
	{command[4],command[2]},
	{command[4],command[2],command[3]},
	{command[6],command[4],command[3]},
	{command[6],command[4],command[2]},
	{command[6],command[4],command[2],command[3]},
	{command[5]},
	{command[5],command[3]},
	{command[5],command[2]},
	{command[5],command[2],command[3]},
	{command[5],command[6],command[3]},
	{command[5],command[6],command[2]},
	{command[5],command[6],command[2],command[3]}
}


function initializationRandom(p,size)
	local chromossomes = {}
	for i = 1, p, 1
	do
		local chromossome = {}
		for j = 1,size,1
		do
			local gene = math.random(1,#genes)
			chromossome[j] = gene
		end
		chromossomes[i] = chromossome
	end
	return chromossomes
end

function get_weighted_random()

end

function initializationGuided(p,size)
	local chromossomes = {}
	local positionss = {}
	for i = 1, p, 1
	do
		local chromossome = {}
		local positions = {}
		for j = 1,size,1
		do
			local gene = math.random(1,#genes)
			chromossome[j] = gene
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

function fitness(mario)
	return mario["d"] + 8*mario["t"]*mario["s"] + 1024*mario["s"]
end

function tournament(population,k)
	local winner = {}
	local best_ind = -1
	local bestFitness = -1
	for i  = 1,k,1 do
		local ind = math.random(1,#population)
		local fitness = fitness(population[ind])
		if fitness > bestFitness then
			winner = population[ind]
			bestFitness = fitness
			best_ind = ind
		end
	end

	return winner,ind
end

function elite_mario(mario_population)
	local best = {}
	local bestFitness = -1
	for i  = 1,#mario_population,1 do
		local mario = mario_population[i]
		local fit_list = mario["fit_list"]
		if fit_list[#fit_list] > bestFitness then
			best = mario_population[i]
			bestFitness = fit_list[#fit_list]
		end
	end

	return best
end

function crossover_random(chromossome1, chromossome2) --crossover of a pair of chromossomes and return the results childs
	local index = math.random(1, #chromossome1)
	local child1 = {}
	local child2 = {}
	for i = 1, index, 1 do
		child1[i] = chromossome1[i]

		child2[i] = chromossome2[i]
	end
	for i = index+1, #chromossome1, 1 do
		child1[i] = chromossome2[i]

		child2[i] = chromossome1[i]
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

	if n == -1 then
		n = math.random(1,#chromossome1)
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
		local gene = math.random(1, #genes)
		chromossome[ind] = gene
	end
end

function mutation_guided(mario,w_0,W)
	local fit_list = mario["fit_list"]
	local window = 0
	if fit_list[#fit_list] > fit_list[math.max(#fit_list-1,1)] then
		print(" GOT BETTER")
		mario["w"] = w_0
	elseif fit_list[#fit_list] <= fit_list[math.max(#fit_list-W,1)] then
		if 2*mario["w"] <= mario["death"] then
			print(" GOT WORSE. EXPAND")
			mario["w"] = 2*mario["w"]
		end
	end
	window = mario["w"]
	print(" " .. window)

	local chromossome = mario["c"]
	for i=math.max(1,mario["death"]-window),mario["death"],1 do
		local gene = math.random(1,#genes)
		chromossome[i] = gene
	end

	mario["w"] = window

end

function evolvePopulation(mario_population,k,crossover_rate,mutation_rate)
	local new_population = {}
	local i = 1
	while (i <= #mario_population) do
		if math.random() < crossover_rate and i+2 <= #mario_population then
			print("SEX_TIME")
			local winner1 = tournament(mario_population,k)
			local winner2 = tournament(mario_population,k)

			local child1 = {}
			local child2 = {}
			child1["c"],child2["c"] = crossover_random(winner1["c"],winner2["c"])

			mutation_random(child1["c"],mutation_rate)
			mutation_random(child2["c"],mutation_rate)

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
				c_winner_copy[j] = c_winner[j]
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
	copy["death"] = mario["death"]

	--Hard-copying chromossome
	local c_mario = mario["c"]
	local c_copy = {}
	for j = 1, #c_mario,1 do
		c_copy[j] = c_mario[j]
	end

	copy["c"] = c_copy

	--Hard-copying fit list
	local f_mario = mario["fit_list"]
	local f_copy = {}
	for j = 1, #f_mario,1 do
		f_copy[j] = f_mario[j]
	end

	copy["fit_list"] = f_copy

	return copy
end

function evolvePopulationGuided(mario_population,k,crossover_rate,w_0,W,threshold)
	local best,best_ind = elite_mario(mario_population)
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
			child1["fit_list"] = {}
			child1["w"] = w_0

			child2["fit_list"] = {}
			child2["w"] = w_0

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
	C = 0.2 -- Crossover rate
	M = 0.1 -- Mutation Rate
	T_s = math.max(3,math.floor(0.15*P))-- tournament size -- tournament size

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
	bests = 0
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
			final_d = 0
			endgame = false
			p = 0
			savestate.load(FILE_NAME); -- load first level

			for j=1,#current_chromossome,1 -- play the game
			do
				controller = {}
				current_gene = current_chromossome[j]
				combo = genes[current_gene]

				for k=1,#combo,1 -- load the actual commands on the controller
				do
					button = combo[k]
					controller[button] = true
				end

				for k = 1,g,1 do -- Play the commands
					joypad.set(controller)
					emu.frameadvance()

					-- Needs to check for completion each frame
					if memory.readbyte(0x000E) == 0x06 then -- mario died
						completed = 0	
						endgame = true
						break
					end
	
					if memory.readbyte(0x001D) == 0x03 then --mario won
						print("AE PORRA")
						endgame = true
						break
					end
				end

				if p == 0 then 
					final_d = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --mario X position in level
				else -- mario is inside pipe world now, x is measured differently
					final_d = math.min((c + (memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) - 14)*9 + 1),2561)
				end

				if endgame == true then
					break
				end

				--gui.text(1,100,final_d) -- print x position on screen
				--gui.text(1,200,memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)) -- print x position on screen

				if memory.readbyte(0x000E) == 0x03 then -- going down pipe
					c = 916 -- first possible entry point
					p = 1
					while memory.readbyte(0x000E) ~= 0x08 do -- everything back to normal
						emu.frameadvance()
					end
				end

				if memory.readbyte(0x000E) == 0x02 then -- going side pipe
					p  = 0
					while memory.readbyte(0x000E) ~= 0x08 do -- everything back to normal
						emu.frameadvance()
					end
				end
			end

			if completed == 1 then
				print("AEEEE PORRA CONFIRMED")
			end

			current_mario["d"] = final_d
			current_mario["t"] = read_time()
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
			bests = bests+1
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
	P = 20 --Population size
	C = 0.2 -- Crossover rate
	w_0 = 2
	W = 2
	threshold = 5
	T_s = math.max(3,math.floor(0.15*P))-- tournament size

	-- Generate initial population of marios
	console.writeline("Generating random chromossomes")
	chromossomes_population, positions_populations = initializationGuided(P,10000/g)
	mario_population = {}
	for i = 1,P,1
	do
		mario = {}
		mario["c"] = chromossomes_population[i] -- mario's chromossome
		mario["pos"] = positions_populations[i]
		mario["fit_list"] = {}
		mario["w"] = w_0
		mario_population[i] = mario
	end

	json = require "json"
	bests = 0
	console.writeline("Ready. Playing with first generation")
	generation = 0
	best_mario = {}
	best_fitness = -1
	best_changed = false
	while true do
		generation = generation + 1
		for i=1, #mario_population,1 do	-- for each mario
			current_mario = mario_population[i]
			current_fit_list = current_mario["fit_list"]
			current_chromossome = current_mario["c"]
			current_positions = current_mario["pos"]
			completed = 1
			p = 0
			endgame = false
			savestate.load(FILE_NAME); -- load first level

			for j=1,#current_chromossome,1 -- play the game
			do
				controller = {}
				current_gene = current_chromossome[j]
				combo = genes[current_gene]

				for k=1,#combo,1 -- load the actual commands on the controller
				do
					button = combo[k]
					controller[button] = true
				end

				for k = 1,g,1 do -- Play the commands
					joypad.set(controller)
					emu.frameadvance()

					-- Needs to check for completion each frame
					if memory.readbyte(0x000E) == 0x06 then -- mario died
						completed = 0
						current_mario["death"] = j
						endgame = true
						break
					end
	
					if memory.readbyte(0x001D) == 0x03 then --mario won
						print("AE PORRA")
						endgame = true
						break
					end
				end

				if p == 0 then 
					final_d = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) --mario X position in level
				else -- mario is inside pipe world now, x is measured differently
					final_d = math.min((c + (memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86) - 14)*9 + 1),2561)
				end

				pos = {}
				pos["x"] = final_d
				pos["y"] = memory.readbyte(0x03B8) + 16
				current_positions[j] = pos

				--gui.text(1,100,final_d) -- print x position on screen
				--gui.text(1,200,memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)) -- print x position on screen

				if endgame == true then
					break
				end

				if memory.readbyte(0x000E) == 0x03 then -- going down pipe
					c = 916 -- first possible entry point
					p = 1
					while memory.readbyte(0x000E) ~= 0x08 do -- everything back to normal
						emu.frameadvance()
					end
				end

				if memory.readbyte(0x000E) == 0x02 then -- going side pipe
					p  = 0
					while memory.readbyte(0x000E) ~= 0x08 do -- everything back to normal
						emu.frameadvance()
					end
				end
			end

			current_mario["d"] = final_d
			current_mario["t"] = read_time()
			current_mario["s"] = completed
			current_mario["gen"] = generation

			fit = fitness(current_mario)
			current_fit_list[#current_fit_list+1] = fit

			print("Mario ".. i .. " from generation " .. generation .. ".\n Distance = " .. current_mario["d"] .. "\n Time left = " .. current_mario["t"] .. "\n Fitness = " .. fit)

			if fit > best_fitness then
				best_fitness = fit
				best_mario = current_mario
				best_changed = true
			end
			save_state(json.encode(current_mario),i,false)
		end

		if best_changed == true then
			bests = bests+1
			save_state(json.encode(best_mario),generation,true)
			best_changed = false
		end

		console.writeline("Best fitness yet = " .. best_fitness)
		console.writeline("Evolving generation" .. "(" .. generation + 1 .. ")")

		mario_population = evolvePopulationGuided(mario_population,T_s,C,w_0,W,threshold)
	end
end

print("THIS SHOULD NEVER BE PRINTED")
