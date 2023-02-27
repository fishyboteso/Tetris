# Tetris for ESO
  
**Play Tetris while you are playing a fishing-minigame while you are playing Elderscrolls Online**  
  
It can integrate state machines from [fishyboteso/FishyQR](https://github.com/fishyboteso/FishyQR) or [fishyboteso/Chalutier](https://github.com/fishyboteso/Chalutier) for brilliant extra features.
  
## Installation:
### With Minion:
- Download [Tetris for Fishing](https://www.esoui.com/downloads/info3314-TetrisforFishing.html)
- Depends on [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
- Optionally depends on [Chalutier](https://www.esoui.com/downloads/info2934-Chalutier.html)
- Set up **keybindings** for Tetris in the game

### By Hand:
- Download the latest release of [Tetris.zip](https://github.com/fishyboteso/Tetris/releases)
- Download [LibAddonMenu-2](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
- Optionally download [Chalutier](https://www.esoui.com/downloads/info2934-Chalutier.html) for brilliant extra features
- Unpack the ZIP to ESOs AddOns folder: "C:\Users< username >\Documents\Elder Scrolls Online\live\AddOns"
- Set up **keybindings** for Tetris in the game
  
## Tetris UI
![Tetris UI](https://user-images.githubusercontent.com/1882648/155900436-f03e868b-24eb-4d86-a2ee-7af97fbc06fb.png)  
  
## Tetris Menu
![Tetris menu](https://user-images.githubusercontent.com/1882648/155891942-7ce959ea-8ca9-4ea4-8cf2-8ada38f67e91.png)  
  
## Tetris Keybindings
![Tetris Controls](https://user-images.githubusercontent.com/1882648/155709898-33faba93-ea3c-45ff-8464-74055959a0cb.png)  

## Showcase on Youtube
[![Play Tetris while fishing in Elderscrolls Online](https://img.youtube.com/vi/Qh1E58Fy0AQ/0.jpg)]( https://www.youtube.com/watch?v=Qh1E58Fy0AQ)

### TODO:
- Add a preview of the next block
  - add Menu to enable/disable Preview
  - remove next block on "game over", generate new one on next game
  - edge cases (first start, reloadUI)
  - SavedVar
  - share common constants with tetris.lua
  - show/hide respects loot scene condition
- Pause Message when no keybindings are set
- Add Votans Fisherman as engine
- Improve simple engine to include blink and pause  
- Optional increasing speed
  
### DONE:
- Better UI (animation for deleting lines and game over, fade out when hiding, blink when fish is hooked, show "game over" and "pause" label)
- Menu options to (1) blink when hooked, (2) to pause on Chalutier.looking
- auto detect FishyCha / Chalutier / No engine integration
- Ingame menu for pixelsize
- Ingame menu button to temporarily show Tetris in order to relocate it
- SavedVars for position and recovery of last game
- Better show/hide options for when inactive (don't show in inventory and such)
- Allow right/left-manipulation once after slamming
- Spawning a new block is possible, even when a tower is in the way -> should be game over instead
- Tetris continues playing when pressing slam, when it should be stopped
- Improve randomness of block generation
- Chalutier states seem to break tetris' running state, especially fighting seems fishy  
