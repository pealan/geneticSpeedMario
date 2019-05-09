population = {} 							--contenedor de poblacion
backgroundColor = 0x2C3D72000 		-- color rojo
FRAME_COUNT = 3500   					--frames para pasar el juego
POPULATION_SIZE = 10 							--tamaño de individuos en la generacion
TOURNAMENT_SIZE = 3  							--tamaño de individuos en el torneo para reproducirse
JUMP_WEIGHT	= 0.95 	 					-- probabilidad de saltar
RIGHT_WEIGHT = 0.9   					--probabilidad de moverse a la derecha
MUTATION_RATE_0 = 0.05  					--probabilidad de no saltar
MUTATION_RATE_1 = 0.15 						--probabilidad de saltar
FILE_NAME = "SMB1-1.state"  --archivo de juego guardado iniciando el nivel
ROM_NAME = "mario_rom.nes"

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

math.randomseed(os.time())

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

--[[ pop = {}
for i = 1,5,1
do
	m = {}
	d = math.random(1,10)
	m["d"] = d
	t = math.random(1,10)
	m["t"] = t
	s = math.random(1,10)
	m["s"] = s
	pop[#pop+1] = m
end

for k=1, #pop,1 do
	local v = pop[k]
	print(k)
	print(v)
end

w = tournament(pop,2)

print("SHUFFLED")
for k=1, #pop,1 do
	local v = pop[k]
	print(k)
	print(v)
end

for k=1, #w,1 do
	local v = w[k]
	print(k)
	print(v)
end ]]

function crossover_random(chromossome1, chromossome2) --crossover of a pair of chromossomes and return the results childs
	length = table.getn(chromossome1)
	index = math.random(1, length)
	child1 = {}
	child2 = {}
	for i = 1, index, 1 do
		child1[i] = chromossome1[i]
		child2[i] = chromossome2[i]
	end
	for i = index+1, length, 1 do
		child1[i] = chromossome2[i]
		child2[i] = chromossome1[i]
	end
	return child1, child2
end

function mutation_random(chromossome, mutation_rate)
	length = table.getn(chromossome)
	qnt_mutation = mutation_rate*length
	math.floor(qnt_mutation)
	for i = 1, qnt_mutation, 1 do
		ind = math.random(1, length)
		gene = math.random(1, 22)
		chromossome[ind] = genes[gene]
	end
	return chromossome
end

function evolvePopulation(mario_population,k,crossover_rate,mutation_rate)
	new_population = {}
	local i = 1
	while (i <= #mario_population) do
		if math.random() < crossover_rate then
			local winner1 = tournament(mario_population,k)
			local winner2 = tournament(mario_population,k)

			child1 = {}
			child2 = {}
			child1["c"],child2["c"] = crossover_random(winner1["c"],winner2["c"])

			child1["c"] = mutation_random(child1["c"],mutation_rate)
			child2["c"] = mutation_random(child2["c"],mutation_rate)

			new_population[#new_population+1] = child1
			new_population[#new_population+1] = child2
			i = i + 2
		else
			local winner = tournament(mario_population,k)
			clone = {}
			clone["c"] = mutation_random(winner["c"],mutation_rate)
			new_population[#new_population+1] = clone
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
		file = io.open("best_mario.txt", "w+")
	else
		file = io.open("mario_" .. generation .. ".txt","w+")
	end

	-- sets the default output file as test.lua
	io.output(file)

	-- appends a word test to the last line of the file
	io.write(generation)

	local c = mario["c"]
	for i = 1,#c,1 do
		local gene = c[i]
		io.write(",( ")
		for j = 1,#gene,1 do
			io.write(gene[j] .. " ")
		end
		io.write(")")
	end


end


g = 5 --granularity
P = 20 --Population size
C = 0.001 -- Crossover rate
M = 0.05 -- Mutation Rate
T_s = 3 -- tournament size

-- Generate initial population of marios
console.writeline("Generating random chromossomes")
chromossomes_population = initializationRandom(20,10000)
mario_population = {}
for i = 1,P,1
do
	mario = {}
	mario["c"] = chromossomes_population[i] -- mario's chromossome
	mario_population[i] = mario
end

save_state(mario_population[1],0,false)
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
		fit = fitness(current_mario)
		print("Mario ".. i .. " from generation " .. generation .. ".\n Distance = " .. current_mario["d"] .. "\n Time left = " .. current_mario["t"] .. "\n Fitness = " .. fit)
		if fit > best_fitness then
			best_fitness = fit
			best_mario = current_mario
			best_changed = true
		end
		save_state(current_mario,i,false)
	end

	if best_changed == true then
		save_state(best_mario,generation,true)
		best_changed = false
	end

	console.writeline("Best fitness yet = " .. best_fitness)
	console.writeline("Evolving generation" .. "(" .. generation + 1 .. ")")
	mario_population = evolvePopulation(mario_population,T_s,C,M)

end
