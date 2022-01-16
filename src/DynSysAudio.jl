"""
A Julia package for making sound from dynamical systems
"""
module DynSysAudio

    using SampledSignals
    using DifferentialEquations
    using Unitful

    import SampledSignals: nchannels, samplerate, unsafe_read!

    export  NoiseSource,
            SinusoidSource,
            Sin2Source,
            ODESource,
            samplerate

    include("NoiseSource.jl")
    include("SinusoidSource.jl")

end # module