# Wavetable

A very basic wavetable generation module.

```lua
local wt = require("wavetable")

for k,v in pairs(wt.gen_sin()) do
  print(k, v)
end
```
