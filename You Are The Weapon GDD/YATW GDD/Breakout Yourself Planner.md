---

kanban-plugin: board

---

## Ideas

- [ ] Proper physics bouncing, including spin


## Planned



## Todo

- [ ] Score Mechanic
	- Add points for: 
		- [x] breaking a brick ✅ 2025-01-31
		- [x] activating a trigger ✅ 2025-01-31
		- [x] completing a win condition ✅ 2025-01-31
		- [x] completing the level ✅ 2025-01-31
		- [x] time bonus ✅ 2025-01-31
	- [ ] Multiply level score by a combo value based on speed
	- [ ] Store high score between plays


## In progress

- [ ] ### Breakable Walls/Blocks
	- [ ] Break into non-colliding chunks
	- [x] Trigger breaking when health is depleted ✅ 2025-01-29
	- [ ] Visually indicate health by cracks


## Urgent

- [ ] Create Main Menu
	- [x] Make buttons functional ✅ 2025-01-31
	- [ ] (Optional) Make it look good
- [ ] Create Main manager script
	- Handle starting the game
		- [ ] Position the ball correctly
		- [ ] Lerp Engine.time_scale to 1 over a few seconds to launch
	- [ ] Manage level transitions (manual positioning for now)
	- [x] Manage scoring ✅ 2025-01-31


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