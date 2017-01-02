--[[--
  Main scope for all of the wavetable generation code

  @Parameter: number
    The sample rate for the wavetable, defaults to 44100
  @Parameter: number
    The size of the wave table, defaults to 1024
--]]--
local wavetable = {}

function wavetable.init(init_sr, init_ts)
  local sample_rate = init_sr or 44100
  local table_size  = init_ts or 1024
  local f_freq      = 1 / (table_size / sample_rate)  -- fundamental frequency
  local two_pi      = math.pi * 2

  --[[--
    @Return: number
      The sample rate set
  --]]--
  local function get_sample_rate()
    return sample_rate
  end

  --[[--
    @Param: number
      The new sample rate
  --]]--
  local function set_sample_rate(sr)
    sample_rate = sr
  end

  --[[--
    @Return: number
      The number of samples in the wavetable
  ]]
  local function get_table_size()
    return table_size
  end

  --[[--
    @Parameter: number
      The new number of samples in the wavetable
  --]]--
  local function set_table_size(ts)
    table_size = ts
  end

  --[[--
    @Parameter: number
      The sample rate
    @Parameter: number
      The table size
    @Return: number
      The fundamental frequency
  --]]--
  local function gen_f_freq(sr, ts)
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
  local function gen_table_size(sr, f)
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
  local function gen_phase_inc(sr, f)
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
  local function gen_saw_inc(sr, f)
    return (2 * f) / sr
  end

  --[[--
    @Parameter: number
      The frequency of the waveform to generate, defaults to the local f_freq
    @Return: table
      Table of all the values in the waveform
  --]]--
  local function gen_sin(f)
    local ts = table_size
    if f then
      ts = gen_table_size(sample_rate, f)
    end

    local freq = f or f_freq
    local phase_inc = gen_phase_inc(sample_rate, freq)
    local phase = 0
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
  local function gen_sqr(f, dc)
    local ts = table_size
    if f then
      ts = gen_table_size(sample_rate, f)
    end

    local freq = f or f_freq
    local duty = dc or 50
    local mid_point = two_pi * (duty / 100)
    local phase_inc = gen_phase_inc(sample_rate, freq)
    local phase = 0
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
  local function gen_saw(f)
    local ts = table_size
    if f then
      ts = gen_table_size(sample_rate, f)
    end

    local freq = f or f_freq
    local saw_inc = gen_saw_inc(sample_rate, freq)
    local saw_val = -1
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
  local function gen_tri(f)
    local ts = table_size
    if f then
      ts = gen_table_size(sample_rate, f)
    end

    local freq = f or f_freq
    local wave_table = {}
    local phase_inc = gen_phase_inc(sample_rate, freq)
    local phase = 0
    local two_div_pi = 2 / math.pi

    for i = 1, ts do
      local tri_val = phase * two_div_pi

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

  return {
    -- Mutators
    get_table_size  = get_table_size,
    get_sample_rate = get_sample_rate,
    set_table_size  = set_table_size,
    set_sample_rate = set_sample_rate,

    -- Utilities, pure functions
    gen_f_freq     = gen_f_freq,
    gen_table_size = gen_table_size,
    gen_phase_inc  = gen_phase_inc,
    gen_saw_inc    = gen_saw_inc,

    -- Generators
    gen_sin = gen_sin,
    gen_sqr = gen_sqr,
    gen_saw = gen_saw,
    gen_tri = gen_tri
  }
end

return wavetable
