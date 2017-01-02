# Wavetable

A very basic wavetable generation module.

```lua
local wt = require "wavetable"
wt = wt.init()

for k,v in pair(wt.gen_sin()) do
  print(k, v)
end
```
