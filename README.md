This Addon allows you to play tetris while FishyBot is doing the heavy (fish) lifting for you.

![Tetris example](https://user-images.githubusercontent.com/1882648/155708996-05d39438-55f7-4974-bbe6-7d3c19946b67.png)

### TODO:
- Ingame menu for pixelsize
- SavedVars for position and recovery of last game
- Better show/hide options for when inactive (don't show in inventory and such)
- Better UI (show "game over" label, animation for deleting lines and game over, fade out when hiding)
- Allow right/left-manipulation once after slamming
- Maybe add a preview of the next block

### Know Bugs:
- Spawning a new block is possible, even when a tower is in the way -> should be game over instead
- Chalutier states seem to break tetris' running state, especially fighting seems fishy
- Tetris continues playing when pressing slam, when it should be stopped
- Improve randomness of block generation

![Tetris Controls](https://user-images.githubusercontent.com/1882648/155709898-33faba93-ea3c-45ff-8464-74055959a0cb.png)
