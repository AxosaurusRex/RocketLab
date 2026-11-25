# What can be measured

All scenarios are offline Free Play only, launched without Easy Anti-Cheat.
Nothing here has been tested in game yet.

- **Measured** - success follows directly from game state (touch, goal, ground, time).
- **Estimated** - inferred by rules; can be wrong. The UI will label it "estimated".
- **Practice only** - the scenario is set up and time and reps are counted; you mark success yourself.

| Category | Mechanic | Tracking | Based on |
|---|---|---|---|
| Aerial | Basic aerial control | Measured | reach targets while airborne, time |
| Aerial | Aerial touches | Measured | ball touch while airborne |
| Aerial | Air dribbles | Estimated | consecutive airborne touches |
| Aerial | Wall-to-air transitions | Estimated | wall contact, then airborne touch |
| Aerial | Aerial recoveries | Measured | time until wheels are down |
| Aerial | Ceiling shots | Estimated | ceiling contact, flip, touch, goal |
| Aerial | Double touches | Estimated | two airborne touches with backboard bounce between |
| Aerial | Air roll control | Measured | orientation held to a target |
| Aerial | Aerial redirects | Measured | touch on a moving ball, then goal |
| Ground | Dribbling | Estimated | ball stays above and near the car |
| Ground | Flicks | Estimated | dribble, dodge, ball speed gain |
| Ground | 45-degree flicks | Practice only | flick style is hard to classify |
| Ground | Speed flips | Estimated | time to target and speed; technique not judged |
| Ground | Powerslide cuts | Measured | handbrake input and checkpoint time |
| Ground | Ball control | Estimated | time ball stays in range |
| Ground | Ground-to-air | Estimated | ground touch, then airborne touch |
| Ground | Recoveries | Measured | time until controlled on wheels |
| Wall | Wall reads | Measured | touch before the ball lands |
| Wall | Wall hits | Measured | touch while on or near wall, goal |
| Wall | Wall-to-air dribbles | Estimated | consecutive touches after leaving wall |
| Wall | Backboard reads | Measured | touch after backboard bounce |
| Wall | Ceiling setups | Estimated | ceiling contact with ball in range |
| Wall | Wall recoveries | Measured | time until wheels are down |
| Shooting | Ground shots | Measured | goal or miss |
| Shooting | Aerial shots | Measured | airborne touch, goal |
| Shooting | Power shots | Measured | ball speed at goal |
| Shooting | Redirects | Measured | touch on a moving ball, goal |
| Shooting | Near-post / far-post | Measured | where the ball crosses the goal |
| Shooting | Difficult angles | Measured | goal or miss |
| Defense | Shadow defense | Practice only | needs an opponent; not in basic Free Play |
| Defense | Backboard defense | Measured | goal prevented |
| Defense | Saves / aerial saves | Measured | touch and ball no longer goal-bound |
| Defense | Recovery positioning | Estimated | time to reach a target zone |
| Defense | Clearances | Measured | ball leaves the defensive zone |
| Advanced | Flip resets | Estimated | flip regained in the air after wheel contact with ball |
| Advanced | Musty flicks | Practice only | |
| Advanced | Double taps | Estimated | as double touches, plus goal |
| Advanced | Breezi flicks | Practice only | |
| Advanced | Stalls | Practice only | |
| Advanced | Advanced air dribbles | Estimated | touch count and height |

Ceiling shots appear twice in the brief (Aerial and Advanced); they will be one drill with both tags.

## Match data (EAC on)

| Source | Available | Limits |
|---|---|---|
| Stats API | goals, shots, assists, saves, touches, demos, ball hits, goal speed, events | must be enabled in an ini file before launch; boost and car speed are sent only while spectating; whether it sends anything in Free Play is untested |
| Replay header | goals, per-player score/goals/assists/saves/shots, teams, map, date, length | only replays that were saved |
| Replay network data | car and ball positions and motion, boost and other actor updates | needs processing; format changes with game updates |
| Possession | not recorded | could only be estimated from last touch; will be labelled |

Replay fields will be confirmed against your own replay files in Phase 6.
