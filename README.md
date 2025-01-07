# vis-plugged

## Simple async plugin manager for vis made to be as small as possible

### To install this plugin, clone the repo to "plugins" directory and then require it

vis-plug assumes the plugins directory is always: $HOME/.config/vis/plugins. There is no
intent of customizing this location at the moment.

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

This plugin manager makes no effort to support themes. The amount of code necessary
to do such a simple thing is not worth it for me. If you value that feature then I
recommend [vis-plug](https://github.com/erf/vis-plug) instead of vis-plugged.
