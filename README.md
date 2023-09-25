# zig-text-adventure
A text adventure written in Zig for obvious reasons

### This is a work in progress.

## Build
Dependencies:
- [Zig](https://ziglang.org/download/)

1. Clone this repo
2. `cd` into it
3. run `zig build run`
4. That's it :)

### To Do
- [x] Add some basic commands that print to the screen
- [x] Refactor code to use `StringHashMap` for commands
- [x] Basic movement commands
- [x] Door instances will "lock" when you say "lock door"
    - While this is reflected in the code, there isn't any logic yet, e.g. for preventing the player
    from walking through a locked door anyway.
- [ ] Locked doors prevent you from walking through them.
- [ ] Using a key item/object to unlock a door works
- [ ] Player inventory 
    - [ ] Can hold items
    - [ ] Items can stack
    - [ ] Can consume certain items
        - [ ] Cooldown timer upon consuming 
