"""
A Julia package for making sound from dynamical systems
"""
module DynSysAudio

    using SampledSignals
    using DifferentialEquations
    using Unitful

    import SampledSignals: nchannels, samplerate, unsafe_read!

    export  ODESource,
            FilterDyn,
            modify,
            samplerate

    include("ODESource.jl")
    include("FilterDyn.jl")

end # module