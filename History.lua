FILE_NAME = "SMB1-1.state"
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

function readAll(file)
	local f = io.open(file, "rb")
	if f == nil then
		return -1
	end
    local content = f:read("*all")
    f:close()
    return content
end

i = 1
json = require "json"

while true do
	local content = readAll("best_mario_".. i .. ".json")
	if content == -1 then
		print("FIM.")
		break
	end
	print("Running best mario ".. i)
	local mario = json.decode(content)
	current_chromossome = mario.c
	endgame = false
	p = 0
	savestate.load(FILE_NAME); 
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

		for k = 1,mario.g,1 do -- Play the commands
			joypad.set(controller)
			emu.frameadvance()

			-- Needs to check for completion each frame
			if memory.readbyte(0x000E) == 0x06 then -- mario died
				completed = 0	
				endgame = true
				break
			end
	
			if memory.readbyte(0x001D) == 0x03 then --mario won
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

	i = i+1

end