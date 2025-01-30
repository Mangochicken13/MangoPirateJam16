## Theme: You Are The Weapon


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

### Genre
- Rougelike/Rougelite
- Singleplayer

### Target Audience
The difficult controls and fast paced gameplay likely do not lend well to a good experience for casual players, so the target audience would likely lean more towards fans of movement-based or fast-paced roguelike games

### Gameplay
The player controls the ball in a [Breakout](https://en.wikipedia.org/wiki/Breakout_(video_game)) style game, translated into a rougelike format and 3 Dimensional environment. 
The ball moves forward on its own, with the player having control over the direction it turns (relatively being left-right, and up-down; similarly to how a plane would control), as well as how it spins, which will ideally affect how bounces work
