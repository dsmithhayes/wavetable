--[[--
  The wavetable module is used to generate waveforms within a single buffer.

  @Author:  Dave Smith-Hayes <me@davesmithhayes.com>
--]]--
local wavetable = {}

local sample_rate = 44100
local table_size  = 1024
local f_freq      = 1 / (table_size / sample_rate)
local two_pi      = 2 * math.pi
local two_by_pi   = 2 / math.pi

--[[--
  @Return: number
    The sample rate set
--]]--
function wavetable.get_sample_rate()
  return sample_rate
end

--[[--
  @Param: number
    The new sample rate
--]]--
function wavetable.set_sample_rate(sr)
  f_freq = wavetable.gen_f_freq(sr, table_size)
  sample_rate = sr
end

--[[--
  @Return: number
    The number of samples in the wavetable
]]
function wavetable.get_table_size()
  return table_size
end

--[[--
  @Parameter: number
    The new number of samples in the wavetable
--]]--
function wavetable.set_table_size(ts)
  f_freq = wavetable.gen_f_freq(sample_rate, ts)
  table_size = ts
end

--[[--
  @Parameter: number
    The fundamental frequency to use
--]]--
function wavetable.set_f_freq(f)
  table_size = wavetable.gen_table_size(sample_rate, f)
  f_freq = f
end

--[[--
  @Return: number
    The fundamental frequency
--]]--
function wavetable.get_f_freq()
  return f_freq
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The table size
  @Return: number
    The fundamental frequency
--]]--
function wavetable.gen_f_freq(sr, ts)
  return 1 / (ts / sr)
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The frequency
  @Return: number
    The table size for the frequency and sample rate
--]]--
function wavetable.gen_table_size(sr, f)
  return sr * (1 / f)
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The frequency
  @Return: number
    The phase increment
--]]--
function wavetable.gen_phase_inc(sr, f)
  return (two_pi / sr) * f
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The frequency
  @Return: number
    The saw increment
--]]--
function wavetable.gen_saw_inc(sr, f)
  return (2 * f) / sr
end

--[[--
  @Parameter: number
    The frequency of the waveform to generate, defaults to the local f_freq
  @Return: table
    Table of all the values in the waveform
--]]--
function wavetable.gen_sin(f)
  local ts = table_size
  if f then
    ts = wavetable.gen_table_size(sample_rate, f)
  end

  local freq       = f or f_freq
  local phase_inc  = wavetable.gen_phase_inc(sample_rate, freq)
  local phase      = 0
  local wave_table = {}

  for i = 1, ts do
    wave_table[i] = math.sin(phase)
    phase = phase + phase_inc

    if phase >= two_pi then
      phase = phase - two_pi
    end
  end

  return wave_table
end

--[[--
  @Parameter: number
    The frequency of the wavetable to generate, defaults to the calculated
    fundamental frequency stored locally
  @Parameter: number
    The duty cycle of the waveform
  @Return: table
    The generated wavetable
--]]--
function wavetable.gen_sqr(f, dc)
  local ts = table_size
  if f then
    ts = wavetable.gen_table_size(sample_rate, f)
  end

  local freq       = f or f_freq
  local duty       = dc or 50
  local mid_point  = two_pi * (duty / 100)
  local phase_inc  = wavetable.gen_phase_inc(sample_rate, freq)
  local phase      = 0
  local wave_table = {}

  for i = 1, ts do
    phase = phase + phase_inc

    if phase >= two_pi then
      phase = phase - two_pi
    end

    if phase >= mid_point then
      wave_table[i] = -1
    else
      wave_table[i] = 1
    end
  end

  return wave_table
end

--[[--
  @Parameter: number
    The frequency to generate, defaults to the local f_freq
  @Return: table
    The generated wavetable
--]]--
function wavetable.gen_saw(f)
  local ts = table_size
  if f then
    ts = wavetable.gen_table_size(sample_rate, f)
  end

  local freq       = f or f_freq
  local saw_inc    = wavetable.gen_saw_inc(sample_rate, freq)
  local saw_val    = -1
  local wave_table = {}

  for i = 1, ts do
    wave_table[i] = saw_val
    saw_val = saw_val + saw_inc

    if saw_val >= 1 then
      saw_val = -1
    end
  end

  return wave_table
end

--[[--
  @Parameter: number
    The frequency to generate, defaults to the local f_freq
  @Return: table
    The generated wavetable
--]]--
function wavetable.gen_tri(f)
  local ts = table_size
  if f then
    ts = wavetable.gen_table_size(sample_rate, f)
  end

  local freq       = f or f_freq
  local wave_table = {}
  local phase_inc  = wavetable.gen_phase_inc(sample_rate, freq)
  local phase      = 0

  for i = 1, ts do
    local tri_val = phase * two_by_pi

    if tri_val < 0 then
      tri_val = 1.0 + tri_val
    else
      tri_val = 1.0 - tri_val
    end

    wave_table[i] = tri_val
    phase = phase + phase_inc

    if phase >= math.pi then
      phase = phase - two_pi
    end
  end

  return wave_table
end

return wavetable
