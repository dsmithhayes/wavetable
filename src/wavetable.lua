--[[--
  The wavetable module is used to generate waveforms within a single buffer.

  @Author:  Dave Smith-Hayes <me@davesmithhayes.com>
--]]--
local wavetable = {}
wavetable.__index = wavetable

--[[--
  Constants
--]]--
local TWO_PI    = 2 * math.pi
local TWO_BY_PI = 2 / math.pi

--[[--
   Call `wavetable` as a constructor.
--]]--
setmetatable(wavetable, {
  __call = function (cls, ...)
    return cls.new(..., ...)
  end
})

--[[--
  The main constructor for the wavetable object.

  @Parameter: number
    The sample rate to set for the wavetable
  @Parameter: number
    The number of samples to set for the wavetable
--]]--
function wavetable:new(init_sr, init_s)
  local self = setmetatable({}, wavetable)
  self.sample_rate = init_sr
  self.samples = init_s
  self.freq = 1 / (self.samples / self.sample_rate)

  return self
end

--[[--
  @Return: number
    The sample rate set
--]]--
function wavetable:get_sample_rate()
  return self.sample_rate
end

--[[--
  @Param: number
    The new sample rate
--]]--
function wavetable:set_sample_rate(sr)
  self.sample_rate = sr
  self.freq = wavetable:gen_freq(self.sample_rate, self.samples)
end

--[[--
  @Return: number
    The number of samples in the wavetable
--]]--
function wavetable:get_samples()
  return self.samples
end

--[[--
  @Parameter: number
    The new number of samples in the wavetable
--]]--
function wavetable:set_samples(s)
  self.samples = s
  self.freq = wavetable:gen_freq(self.sample_rate, self.samples)
end

--[[--
  @Parameter: number
    The fundamental frequency to use
--]]--
function wavetable:set_freq(f)
  self.freq = f
  self.samples = wavetable:gen_samples(self.sample_rate, self.freq)
end

--[[--
  @Return: number
    The fundamental frequency
--]]--
function wavetable:get_freq()
  return self.freq
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The table size
  @Return: number
    The fundamental frequency
--]]--
function wavetable:gen_freq(sr, s)
  return 1 / (s / sr)
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The frequency
  @Return: number
    The table size for the frequency and sample rate
--]]--
function wavetable:gen_samples(sr, f)
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
function wavetable:gen_phase_inc(sr, f)
  return (TWO_PI / sr) * f
end

--[[--
  @Parameter: number
    The sample rate
  @Parameter: number
    The frequency
  @Return: number
    The saw increment
--]]--
function wavetable:gen_saw_inc(sr, f)
  return (2 * f) / sr
end

--[[--
  @Parameter: number
    The frequency of the waveform to generate, defaults to the local f_freq
  @Return: table
    Table of all the values in the waveform
--]]--
function wavetable:gen_sin(f)
  local s = self.samples
  if f then
    s = wavetable:gen_samples(self.sample_rate, f)
  end

  local freq       = f or self.freq
  local phase_inc  = wavetable:gen_phase_inc(self.sample_rate, freq)
  local phase      = 0
  local wave_table = {}

  for i = 1, s do
    wave_table[i] = math.sin(phase)
    phase = phase + phase_inc

    if phase >= TWO_PI then
      phase = phase - TWO_PI
    end
  end

  return wave_table
end

--[[--
  @Parameter: number
    The duty cycle of the waveform as a number between 0 and 1
  @Parameter: number
    The frequency of the wavetable to generate, defaults to the calculated
    fundamental frequency stored locally
  @Return: table
    The generated wavetable
--]]--
function wavetable:gen_pul(duty, f)
  local s = self.samples
  if f then
    s = wavetable:gen_samples(self.sample_rate, f)
  end

  local freq       = f or self.freq
  local mid_point  = TWO_PI * duty
  local phase_inc  = wavetable:gen_phase_inc(self.sample_rate, freq)
  local phase      = 0
  local wave_table = {}

  for i = 1, s do
    phase = phase + phase_inc

    if phase >= TWO_PI then
      phase = phase - TWO_PI
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
  This function is more or less an alias for the pulse generator with a fixed
  50% duty cycle.

  @Parameter: number
    The frequency to generate
  @Return: table
    The generated square wave
--]]--
function wavetable:gen_sqr(f)
  return self:gen_pul(0.5, f)
end

--[[--
  @Parameter: number
    The frequency to generate, defaults to the local f_freq
  @Return: table
    The generated wavetable
--]]--
function wavetable:gen_saw(f)
  local s = self.samples
  if f then
    s = wavetable:gen_table_size(self.sample_rate, f)
  end

  local freq       = f or self.freq
  local saw_inc    = wavetable:gen_saw_inc(self.sample_rate, freq)
  local saw_val    = -1
  local wave_table = {}

  for i = 1, s do
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
function wavetable:gen_tri(f)
  local s = self.samples
  if f then
    s = wavetable:gen_samples(self.sample_rate, f)
  end

  local freq       = f or self.freq
  local wave_table = {}
  local phase_inc  = wavetable:gen_phase_inc(self.sample_rate, freq)
  local phase      = 0

  for i = 1, s do
    local tri_val = phase * TWO_BY_PI

    if tri_val < 0 then
      tri_val = 1.0 + tri_val
    else
      tri_val = 1.0 - tri_val
    end

    wave_table[i] = tri_val
    phase = phase + phase_inc

    if phase >= math.pi then
      phase = phase - TWO_PI
    end
  end

  return wave_table
end

return wavetable
