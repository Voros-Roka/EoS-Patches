# Roka-Patch
Nuzlocke patch for Explorers of Sky.

Still in early development ... so expect bugs, crashes, instability and other random things ...

Replaces the in-dungeon tip system with code to enable enforced nuzlocke rules. Config and other data for the nuzlocke rules are saved inside the normal save-game so are persistent.

When the patch is applied inside Skytemple it will ask for:

- pokemon id to store the portrait for the config system.
	- For most things the default id of 599 should be fine. In the case that the spot is already in use by a custom pokemon it is possible to use another id.
- Display type for the belly meter
	- Simple just shows the current belly
	- Full show "belly/max"
	- The hp-bar max size is smaller to not collide with the belly display

## Compatibility
Currently only works with the NA version of EoS.

This patch works with newly started games or old save-games. The patch will try it's best to convert data from an existing save-game for use with the nuzlocke rules. The only thing that might be missing is information about the player already recruited team-members in case the player dismissed a pokemon from the team.

The save-games created with a patched rom are somewhat backwards compatible with a non patched version. The only thing that will happen is that random hints might be show in-dungeon.

Not compatible with the 'DisableTips' patch included in SkyTemple. Compatibility with other SkyTemple patches is currently unknown.


## What works
* The status if it is possible to recruit a new team member inside a dungeon (Right bottom corner, Green 1 means possible, white 0 means impossible)
* Forced recruit of new team-members inside dungeons
* Forced naming of new team-members inside dungeons
* Preventing the use of revive seeds inside dungeons (experimental)
* Check of duplicated pokemon inside dungeons
	* Check against the evolution lines of pokemon
	* Check against the hero
	* Check against the partner
	* Check against the gender of pokemon (somewhat experimental)
	* Check against the list of all recruited pokemon (somewhat experimental, at the moment always performs a gender dependent check)
* Log entry when the patch prevents recruitment
* Log entry ehwn the patch prevents revive
* Display of belly (Top right corner, either current belly or belly/max)

## What does not work
* Mark team member as dead
	* The team member is marked internally as dead but it is currently not used
	* It is no where shown that a team member is marked as dead ...
* Dupe check against dead team members
	* Works as long as team members are not dismissed inside the assembly. The marks are not transferred with the rest of the data to the new spot in the member list, meaning that suddenly another team member might be marked as dead and the moved team member lost his death mark ...
* Duplication rules are not applied to after-dungeon/mission/cafe recruits
* Dead members can still be used inside dungeons

## What is planned/missing
* More log entries when a rule prevents something and why
* Add option to mark a whole dungeon group instead of only a single dungeon for the dungeon already recruit member check
* Config to prevent to be kicked out when partner or hero dies
* Replacing the hero and/or partner in case they they die
* Config menu to change the rules inside and outside of dungeons
* Dead member handling
	* Assembly modification to show which members are dead
	* Prevent that dead members are usable inside dungeons
	* Config option to automatically dismiss/remove dead members
* Show if it possible to recruit members inside the dungeon list when the player wants to depart
* Application of duplication rules outside of dungeons (mission/cafe/?story?)
* Option to restore original save-game state for a non patched rom
* In-dungeon UI tweaks
	* Health of team members?
	* Better visualization of applied nuzlocke rules
* And many more other ideas ...

## Config
When first entering any dungeon the player will be asked questions what nuzlocke rules the game should enforce. Currently it is not possible to change the config after that point.

## Technical stuff
The config gets stored inside the save-game in place of the config for the in-dungeon tip system flags that tell the game which tips it already displayed. The code to store the tip flags was rewritten and expanded to make this possible.

Dungeons that are no longer allowed to recruit in are recorded in the first 32 bytes inside the 'global_progress' struct.
Dead team members are marked directly after that with one bit for one team member according to there position inside the internal list of team members.
The first 148 byte of the 'global_progress' struct are seemingly not used in the game so the functions to access them were entirely rewritten to make changes possible

The code for the rules itself replace the functions that display the in-dungeon tips and the list of text-ids that get used by them.

# Links
Zorua portraits are from the [PMD Sprite Repository](https://sprites.pmdcollab.org/)


