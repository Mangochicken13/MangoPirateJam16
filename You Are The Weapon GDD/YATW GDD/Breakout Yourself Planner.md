---

kanban-plugin: board

---

## Ideas

- [ ] Proper physics bouncing, including spin


## Planned



## Todo

- [ ] Score Mechanic
	- Add points for: 
		- [ ] breaking a brick
		- [ ] activating a trigger
		- [ ] completing a win condition
		- [ ] completing the level
		- [ ] time bonus
	- [ ] Multiply level score by a combo value based on speed
	- [ ] Store high score between plays


## In progress

- [ ] ### Breakable Walls/Blocks
	- [ ] Break into non-colliding chunks
	- [x] Trigger breaking when health is depleted ✅ 2025-01-29
	- [ ] Visually indicate health by cracks


## Urgent

- [ ] Create Main Menu
	- [ ] Make buttons functional
	- [ ] (Optional) Make it look good
- [ ] Create Main manager script
	- Handle starting the game
		- [ ] Position the ball correctly
		- [ ] Lerp Engine.time_scale to 1 over a few seconds to launch
	- [ ] Manage level transitions (manual positioning for now)
	- [ ] Manage scoring


## Complete

- [x] ### Make Camera not awful while bouncing ✅ 2025-01-28
	- [x] Research using lerps and easing ✅ 2025-01-20
	- [x] Research using camera boundaries ✅ 2025-01-28
- [x] ### Make test blocks automatically set mesh side albedo ✅ 2025-01-20


## Unplanned

- [ ] ### Add Trail to Ball movement path
	- [ ] Make it fade out before reaching the camera




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false,true,true]}
```
%%