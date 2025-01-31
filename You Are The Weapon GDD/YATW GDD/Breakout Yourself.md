# Breakout Yourself

Format referenced from the example Game Design Document, for [Mass Flux](https://docs.google.com/document/d/1Vl7BMvzUOhbunJrI_X1gUc6x-LAp3aaBiPwHUf27B70). Future documents will likely use a simpler format, but having a guide was very useful for referencing the formatting for me.

### Game Summary Pitch
Breakout Yourself is a platformer? game about breaking blocks quickly in a 3D level

### Inspiration
[Breakout](https://en.wikipedia.org/wiki/Breakout_(video_game)) is naturally the main inspiration, the original concept for this game was "Breakout but you are the ball". 
The intended lore for the original game appears to be that the player, a prison inmate, was knocking a ball and chain into the prison walls in order to escape. 
This was a great launching point to transition to a Roguelike/Roguelite game, providing a reason as to why you have to start again when trying to escape: being caught by the prison guard/security.

The movement was most closely inspired by the visuals of [Children of the Sun](https://store.steampowered.com/app/1309950/Children_of_the_Sun/), adapted to feature continuous control, due to being directly in control of the projectile

### Player Experience
Current plan is for 3 levels to be played in sequence, showcasing the completed mechanics (base movement + bouncing, bouncier bricks/walls, and win conditions)
There will ideally be an options menu to decrease the game speed to enable easier play, as the game will likely be quite difficult

### Platform
The game would ideally be fully released on Windows/Mac/Linux as a downloadable executable through either Itch or Steam, but the demo is being done as a web game for playing on Itch due to both Jam requirements and ease of access

### Development Software
- Godot 4.3 for programming
- Aseprite 1.x dev (compiled) for 2D Sprites
- Medibang Paint Pro for the unused crack texture

### Genre
- Rougelike/Rougelite
- Singleplayer

### Target Audience
The difficult controls and fast paced gameplay likely do not lend well to a good experience for casual players, so the target audience would likely lean more towards fans of movement-based or fast-paced roguelike games


## Concept
### Gameplay
The player controls the ball in a [Breakout](https://en.wikipedia.org/wiki/Breakout_(video_game)) style game, translated into a rougelike format and 3 Dimensional environment. 
The ball moves forward on its own, with the player having control over the direction it turns (relatively being left-right, and up-down; similarly to how a plane would control), as well as how it spins, which will ideally affect how bounces work (spin controls and mechanic not implemented)

### Theme Interpretation
"You are the Weapon" to me implies that the character is the thing physically attacking/destroying things, so, the sword in a game where the player is a knight, or in this case, the ball from breakout, where the player was originally the paddle

### Primary Mechanics
- Walls
	- The player will bounce off of walls the come into contact with, and;
	- Inflict damage on breakable walls (bricks), which will break (disappear) when their health reaches 0, and change color over a gradient to indicated their remaining health if they survive
- Triggers
	- The player will activate a trigger by passing through it, at which point it will turn from orange to green
	- Triggers can only be activated once
- Objectives
	- Each individual level will contain an objective, whether its just to reach the end, break and amount of bricks, or interact with an amount of triggers
	- Additionally there is can be a timer on this objective, providing bonus score if you complete the objective within it
- Scoring
	- Each primary mechanic will have an effect on the score you get:
		- Breaking bricks
		- Activating triggers
		- Completing objectives
		- Finishing with spare time
		- Over-completing objectives if there was a time limit

## Game Experience
### UI
The ui for the game was pretty hastily cobbled together unfortunately, with a lot of functionality going unimplemented (a settings menu, and changing the color of the ball)

During gameplay, two scores, one for the current level and one for the total score are shown at the top left of the screen. 
The center of the screen has the current objective, completion amount of that objective, and the timer if the current level is timed

### Controls
the only controls are WASD/Arrow keys for turning, although the game uses plane controls, so w/up is to turn down, and s/down is to turn up
The left joystick on a controller also works for the turning controls


The best development timeline i have is better viewed on the github repository


# Credits
@tr1bute on the Pirate Software discord (who has since left for a reason unknown to me) for pointing me towards the Phantom Camera plugin to handle my game camera, and being a rubber duck for me while i was learning how to use it,
And subsequently, the Phantom Camera Team for making such a cool plugin https://github.com/ramokz/phantom-camera/tree/main

@brighhton on discord (Not in the Pirate Software discord for encouraging me and being cool)

https://godotshaders.com/shader/the-simplest-outline-shader-via-material/ for the basis of my brick outline shader,
And https://godotshaders.com/shader/camera-distance-uv-scaling/ for the logic behind hiding that shader with proximity

The regulars in the Pirate Software discord \#godot channel for being so nice and encouraging, and creating an environment that I felt safe to ask questions in

​And finally, the Godot team, for making the engine that made all of this possible [https://godotengine.org/](https://godotengine.org/)​