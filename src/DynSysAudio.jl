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
            ODESource,
            FilterDyn,
            modify,
            samplerate

    include("NoiseSource.jl")
    include("SinusoidSource.jl")
    include("ODESource.jl")
    include("FilterDyn.jl")


end # module