# Wavetable

A very basic wavetable generation module.

## Examples

The first example is building a simple `wavetable` object with a sample rate of
44.1kHz, and 1024 samples. Each `gen_` method will return a table of values
between -1 and 1. In the example below, each table created is exactly 1024
samples long.

```lua
wavetable = require("wavetable")

wt = wavetable(44100, 1024)

local sin_wave = wt:gen_sin()
local sqr_wave = wt:gen_sqr()
local tri_wave = wt:gen_tri()
local saw_wave = wt:gen_saw()
```

We can adjust the frequency to create an easy basenote for wavetable based
synthesis as well. The lowest frequency on the MIDI keyboard is 27.5Hz, or the
note `A0`. Let's set that frequency and generate our waveforms. For kicks we
should generate an `A4` at the same time.

```lua
wavetable = require("wavetable")

wt = wavetable(44100, 1024)

wt:set_freq(27.5)   -- changes the `.samples` local variable
local a_zero = wt:gen_sin()
local a_four = wt:gen_sin(440)
```
