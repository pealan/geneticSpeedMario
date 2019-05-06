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

--[[ Fisher-Yates shuffle]]
local function shuffle(t)
    local rand = math.random 
    assert(t, "table.shuffle() expected a table, got nil")
    local iterations = #t
    local j
    
    for i = iterations, 2, -1 do
        j = rand(i)
        t[i], t[j] = t[j], t[i]
    end
end

function fitness(mario)
	return mario["d"] + 8*mario["t"] + 1024*mario["s"]
end

function tournament(population,k)
	local winners = {}
	shuffle(population)
	local i = 1
	for i = 1,#population,k
	do
		local best_fitness = -1
		local winner = population[j]
		for j = 0,k-1,1
		do
			local mario = population[j+i]
			if mario == nil then
				break
			end
			local f = fitness(mario)
			if f > best_fitness then
				best_fitness = f
				winner = mario
			end
		end
		winners[#winners+1] = winner
	end

	return winners
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
	qnt_mutation = (mutation_rate*length)/100
	math.floor(qnt_mutation)
	for i = 1, qnt_mutation, 1 do
		ind = math.random(1, length)
		gene = math.random(1, 22)
		chromossome[ind] = genes[gene]
	end
	return chromossome
end

--[[ chromossomes = initializationRandom(2, 4)
child1, child2 = crossover_random(chromossomes[1], chromossomes[2])
print("FILHO1")
for k, v in ipairs(child1) do
	print(k, v)
end
print("FILHO 2")
for k, v in ipairs(child2) do
	print(k, v)
end
new_chromossome = mutation_random(chromossomes[1], 25.0)
print("mutacao")
for k, v in ipairs(new_chromossome) do
	print(k, v)
end ]]

--[[ function generateIndividualDNA() --generar DNA de un invividuo random
	local individual = {}
	individual.bytes = {}
	bytes = "_"
	for count=0, FRAME_COUNT do
		if math.random() < JUMP_WEIGHT then
			individual.bytes[#individual.bytes+1] = 1 -- probabilidad JUMP_WEIGHT (93%) de saltar
		else
			individual.bytes[#individual.bytes+1] = 0 -- probabilidad 1 - JUMP_WEIGHT (7%) de no saltar
		end
		bytes = bytes .. individual.bytes[#individual.bytes] --concatenar string con nuevo movimiento
	end
	return individual --regresar el DNA del individuo
end

function generateRandomPopulation() --generar primera poblacion random
	for count=0,POPULATION_SIZE do
		population[count] = generateIndividualDNA()
	end
end

function tournamentSelection() --tomar individuos de la poblacion al azar y regresar los mejores

	highestIndex = 0
	highestFit = 0
	highestSpeed = 3500

	for i=0, TOURNAMENT_SIZE do
		index = math.random(#population)
		-- elegir el mejor o si hay un empate elegir el mas rapido
		if population[index].fitness > highestFit or (population[index].fitness == highestFit and population[index].frameNumber < highestSpeed) then
			highestIndex = index
			highestSpeed = population[index].frameNumber
			highestFit = population[index].fitness
		end
	end

	return population[highestIndex]

end

function crossover(indiv1, indiv2) --tomar dos individuos y combinarlos (reproducirlos)

	newIndiv = {}
	newIndiv.bytes = {}
	index = math.random(#indiv1.bytes) --random numero de bytes que el primer padre


	for i=1, index do --copiar elementos del primer padre
		newIndiv.bytes[#newIndiv.bytes+1] = indiv1.bytes[i]
	end

	for i=index, #indiv1. bytes do --copiar elementos del segundo padre
		newIndiv.bytes[#newIndiv.bytes+1] = indiv2.bytes[i]
	end

	return newIndiv --regresar el hijo

end

function mutate(indiv) --cambiar un poco el DNA d un individuo

	newIndiv = {}
	newIndiv.bytes = {}

	for i=1, #indiv.bytes do
		if indiv.bytes[i] == 1 and math.random() < MUTATION_RATE_1 then
			newIndiv.bytes[#newIndiv.bytes+1] = 0   --convertir 1 en 0
		else if indiv.bytes[i] == 0 and math.random() < MUTATION_RATE_0 then
				newIndiv.bytes[#newIndiv.bytes+1] = 1 --convertir 1 en 0
			else --caso inutil
				newIndiv.bytes[#newIndiv.bytes+1] = indiv.bytes[i]
			end
		end
	end

	return newIndiv

end

highestFit = 0 --iniciar la mejor finess a 0
highestSpeed = 3500 --iniciar la mejor velocidad (menor es mejor)

function evolvePopulation()

	local newPopulation = {}

	--keeping the highest fitness
	highestIndex = 0
	highestFit = 0
	highestSpeed = 3500
	for i=1, #population do
		if population[i].fitness > highestFit or (population[i].fitness == highestFit and population[i].frameNumber < highestSpeed) then
			highestIndex = i
			highestSpeed = population[i].frameNumber
			highestFit = population[i].fitness
		end
	end

	newPopulation[#newPopulation+1] = population[highestIndex]

	for i=2, POPULATION_SIZE do
		indiv1 = tournamentSelection() --elegir individuo 1 en base a torneo
		indiv2 = tournamentSelection() --elegir individuo 2 en base a torneo
		newPopulation[#newPopulation+1] = crossover(indiv1, indiv2) --hijo entren in1 y in2
	end

	for i=2, POPULATION_SIZE do
		newPopulation[i] = mutate(newPopulation[i])
	end

	population = newPopulation --remplazando nueva poblacion con una nueva

end

console.writeline("Generando poblacion random.")
generateRandomPopulation()
console.writeline("Listo. Jugando con primera generacion.")
generation = 0
while true do 	--Hacer para siempre
	generation = generation + 1
	for index=1, #population do		--por cada individuo en la poblacion

		local moveIndex = 0
		savestate.load(FILE_NAME); --cargar el inicio del nivel

		population[index].frameNumber = 0
		while true do	--play with the individual

			population[index].fitness = memory.readbyte(0x6D) * 0x100 + memory.readbyte(0x86)	--mario X position in level
			population[index].fitness = population[index].fitness / 20 --normalizando dividiendo por 50
			population[index].fitness = math.floor(population[index].fitness) --redondeando a un int
			population[index].frameNumber = population[index].frameNumber + 1 --sumando ++1 al frame

			--dibujar GUI Heads Up display
			gui.drawBox(0, 0, 300, 35, backgroundColor, backgroundColor)
			gui.drawText(0, 0, "Generacion No." .. generation .. "- Individuo No." .. index, 0xFFFFFFFF, 8)
			gui.drawText(0, 10, "Fitness = " .. population[index].fitness .. " en " .. population[index].frameNumber .. " frames", 0xFFFFFFFF, 8)
			gui.drawText(0, 20, "Top Fitness = " .. highestFit .. " en " .. highestSpeed .. " frames", 0xFFFFFFFF, 8)

			controller = {}
			if population[index].bytes[moveIndex] == 0 then
				controller["P1 B"] = true --true si el DNA dice 0
			else
				controller["P1 A"] = true -- population[index].bytes[moveIndex] == 1 --true si el DNA dice 1
			end

			moveIndex = moveIndex + 1 		--moveindex++
			controller["P1 Right"] = true --presionar A para saltar en P1
			joypad.set(controller) 				--api para presionar usar el control

			emu.frameadvance(); --Api avanzar frame en el juego

			if memory.readbyte(0x000E) == 0x06 then --si mario muere reiniciar juego con siguiente individuo
				break
			end
		end

		console.writeline("Fitness reached: " .. index .. "> " .. population[index].fitness) --log finess alcanzado
	end

	console.writeline("")
	console.writeline("Evolucionando nueva generation." .. "(" .. generation + 1 .. ")")
	evolvePopulation()

end ]]
