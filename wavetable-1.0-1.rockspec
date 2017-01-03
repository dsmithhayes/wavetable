package = "wavetable"
version = "1.0-1"

source = {
  url = "https://github.com/dsmithhayes/wavetable"
}

description = {
  summary = "Wavetable generator.",
  detailed = [[
    A wavetable generator with support for four primitive waveforms. These
    include sine, triangle, saw, and square.
  ]],
  homepage = "https://github.com/dsmithhayes/wavetable",
  license = "BSD 3.0"
}

dependencies = {
  "lua >= 5.1, < 5.4"
}

build = {
  type = "builtin",
  modules = {
    wavetable = "src/wavetable.lua"
  }
}
