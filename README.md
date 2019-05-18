# geneticSpeedMario

Simple genetic algorithm developed for the 2nd project in Artificial Intelligence (MC096) administred in 2019.

## How to run (Windows)
1. Clone the repository: `git clone https://github.com/pealan/geneticSpeedMario.git`
2. Download Bizhawk: `http://tasvideos.org/BizHawk.html`
3. Edit parameters.json to your needs (with caution, please). Mode 1 uses g, P,C and M (1st cofiguration). Mode 2 (2nd configuration) uses g, P, C, w_0, W, threshold and ini_random (if 1 initialization will be random).
4. Open Bizhawk
5. Go to File->Open ROM and open Super Mario Bros. (World).nes
6. Go to Tools->Lua Console and wait for the terminal to open.
7. On Lua Console go to Open Script and choose GeneticMario.lua 
8. Click on Toggle Script

### PROTIPs
1. The big number that first appears on the console is your seed for this run. You can hardcode it on the script in order to achieve the same results again, assuming that you are running with the same configuration.
2. When the emulator is on focus, press "+" on the keyboard to increase the speed.

## Analyzing results
Currently, all marios from the current generation are saved in json files after they are tested. When a new best mario is noticed, it is saved on `best_mario_i.json`. Please clean your marios on the directory before running the main script again or suffer the consequences of maybe being confused. In order to see the evolution of your best marios, go through the same process as stated before but run `History.lua` this time and watch the evolution. This script will search for json in the format `best_mario_i.json` for `i` going from 1 to `n >=1` in increasing order.
