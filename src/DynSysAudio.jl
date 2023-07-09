"""
A Julia package for making sound from dynamical systems
"""
module DynSysAudio

    import SampledSignals: nchannels, samplerate, unsafe_read!

    using DSP
    using DifferentialEquations
    using PortAudio
    using SampledSignals
    using Unitful

    export  ODESource,
            FilterDyn,
            StreamUtils,
            modify,
            step!,
            mixer,
            soundcard_init,
            samplerate

    include("ODESource.jl")
    include("FilterDyn.jl")
    include("StreamUtils.jl")

end # module