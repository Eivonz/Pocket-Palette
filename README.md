# Pocket Palette
Addon for Return of Reckoning

This is a small addon that allows players to browse all dyes in the game and preview them on their character.

## Requirements:
```
LibSlash
```

## Installation:
```
1. Unpack the downloaded archive
2. Copy the "Pocket Palette" directory into \Warhammer Online - Age of Reckoning\Interface\AddOns
3. Enable "Pocket Palette" ingame in the "User Settings -> Interface-> Mods/Add-Ons" section. Optionally reload UI (/rel)
```
## Usage:
The Pocket Palette window is shown using the slash command /PP

```
Butons:
    Refresh: Reloads some specific data, fx. number of dye counts. Mainly left for debugging purpose.
    Paperdoll: Shows the character window.
    Show/Hide: Minimizes part of the PP window, for easier viewing of the ingame character model. Intended for lower resolutions.

Dye Picker:
    Selected/active dye is shown in the top.
    Name filter: Enter any partial dye name to apply this filter to the dye list. Remove input to clear filter.
    Ordering: Rearrange the dye list fx. "Count" shows the dyes in possion in a descending order.
    Click on dye in the list to set it as selected/active

Item Slots:
Mouse click to set the selected/active dye for a specific item slot.
Left click sets the primary dye color.
Right click sets the secondary dye color.
Clicking twice with the same dye color clears the dye.
```
    Setting dye colors in the "All" item slot, has a lower priority than dye colors in an actual item slot and will be overruled by this.


## Feedback:
Any feedback, bugs and issues are more than welcome, and can be supplied in this thread.

### v1.1
```
- Added the option to persist a dye preview. This is enabled by checking the "Persitent settings" checkbox.
  Persistent dye preview are active per character, and means a specific dye selection should be visible on the character model even after closing PP, loading into the game or reloading the UI etc.
- Added tooltip info when hovering over an item slot, to indicate if an item can't be dyed.
- Refresh button removed.
- Reduced addon's memory footprint.
```

### v1.0
```
- Browse all dyes, with filter and ordering options
- Show number of actual dyes in possession from inventory and bank
- Preview dyes on character model
```

