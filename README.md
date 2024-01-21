# Tetris for ESO
  
**Play Tetris while you are playing a fishing-minigame while you are playing Elderscrolls Online**  
  
## Installation:
### With Minion:
- Download [Tetris for Fishing](https://www.esoui.com/downloads/info3314-TetrisforFishing.html)
- Depends on [LibAddonMenu](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
- Depends on [FishingStateMachine](https://www.esoui.com/downloads/info3693-FishingStateMachine.html)
- Set up **keybindings** for Tetris in the game

### By Hand:
- Download the latest release of [Tetris.zip](https://github.com/fishyboteso/Tetris/releases)
- Download [LibAddonMenu-2](https://www.esoui.com/downloads/info7-LibAddonMenu.html)
- Download [FishingStateMachine](https://www.esoui.com/downloads/info3693-FishingStateMachine.html)
- Unpack the ZIP to ESOs AddOns folder: "C:\Users\\< username >\Documents\Elder Scrolls Online\live\AddOns"
- Set up **keybindings** for Tetris in the game
  
## Tetris UI
![Tetris UI](https://user-images.githubusercontent.com/1882648/227217532-5927eec9-8d98-4516-98d2-479180f3c9ef.png)
  
## Tetris Menu
![Tetris menu](https://user-images.githubusercontent.com/1882648/227217868-4aebe803-a644-48df-aa68-e9ee60811f9f.png)
  
## Tetris Keybindings
![Tetris Controls](https://user-images.githubusercontent.com/1882648/227218054-3f975f30-9839-4519-8698-7d61fd5fbd26.png)


## Showcase on Youtube
[![Play Tetris while fishing in Elderscrolls Online](https://img.youtube.com/vi/Qh1E58Fy0AQ/0.jpg)]( https://www.youtube.com/watch?v=Qh1E58Fy0AQ)

### Open Features:
- Optional increase speed
- Implement Guidelines:
  - rename blocks -> tetrominos/pieces
  - wallkicks
  - ghost piece OR guide lines
  - Delayed Auto Shift
- Improve Score
- Fix random game over bug
  
### Changelog:
**1.7**
- update API version to 101040
- use ZO_tabledeepcopy for deepcopy

**1.6**
- use FishingStateMachine addon

**1.5:**
- fix game over bugs
- lock down time 500 ms
- Start above playfield
- Add TetrisCha engine
- Pause Message when no keybindings are set
- Fix Random (7bag)
- Fix moves (SRS) and start rotation
- Add a preview of the next block
- show stats in menu

**1.4:**
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
