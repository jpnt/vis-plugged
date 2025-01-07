# vis-plugged

## Simple plugin manager for vis made to be as small as possible

### To install this plugin, clone the repo to "plugins" directory and then require it:

```lua
plugged = require("plugins/vis-plugged")
```

Then use it like so:

```lua
plugged.add_plugin("https://github.com/lutobler/vis-commentary")
plugged.add_plugin("https://git.sr.ht/~mcepl/vis-fzf-open")
plugged.add_plugin("https://github.com/jpnt/vis-shout")
plugged.add_plugin("https://github.com/kupospelov/vis-ctags")
plugged.require_all_plugins()
```

TODO: async
