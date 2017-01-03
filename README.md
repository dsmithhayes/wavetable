# Wavetable

A very basic wavetable generation module.

## Examples

The first example is a basic implementation using the default values for the
sample rate, table size (number of samples), and fundamental frequency. The
default values are as follows:

* `sample_rate`: `44100`
* `table_size`: `1024`
* `f_freq`: `1 / (table_size / sample_rate)`

```lua
local wt = require("wavetable")

for k,v in pairs(wt.gen_sin()) do
  print(k, v)
end
```

We can generate a waveform with a specific frequency. This is useful when you
want say the lowest MIDI note (`A0`, 27.5Hz) to build your waveform with.

```lua
local wt = require("wavetable")

for k,v in pairs(wt.gen_sin(27.5)) do
  print(k, v)
end
```

Alternatively, we can change the local `f_freq`.

```lua
local wt = require("wavetable")

wt.set_f_freq(27.5)

for k,v in pairs(wt.gen_sin()) do
  print(k, v)
end
```

We can also control how many samples will exist in the table.

```lua
local wt = require("wavetable")

wt.set_table_size(2048)

for k,v in pairs(wt.gen_sin()) do
  print(k, v)
end
```

Adjusting the sample rate will only affect the fundamental frequency and leave
whichever value for the table size that was previously set.
