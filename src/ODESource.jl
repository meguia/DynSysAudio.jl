import SampledSignals: nchannels, samplerate, unsafe_read!

mutable struct ODESource{T} <: SampleSource
    samplerate::Float64
    timescale::Float64
    nchannels::Int
    time::Float64
    dt::Float64
    uini::Array
    pars::Array
    gain::Float64
    problem::OrdinaryDiffEq.ODEProblem
end


function ODESource(eltype, system::Function, samplerate::Number, timescale::Number, start_point::Array, pars::Array)
    nchannels = length(start_point)
    time = 0.0
    gain = 0.1
    tspan = (0.0, 100.0)
    dt = timescale/samplerate
    uini = start_point
    problem = ODEProblem(system,start_point,tspan,pars)
    ODESource{eltype}(Float64(samplerate), Float64(timescale),nchannels, time, dt, uini, pars, gain,problem)
end

Base.eltype(::ODESource{T}) where T = T
nchannels(source::ODESource) = source.nchannels
samplerate(source::ODESource) = source.samplerate


function unsafe_read!(source::ODESource, buf::Array, frameoffset, framecount)
    tend = source.time+(framecount-1)*source.dt
    seq = hcat(solve(remake(source.problem;u0=source.uini,tspan=(source.time,tend),p=source.pars),Tsit5(),saveat=source.dt).u...)'
    buf[frameoffset+1:frameoffset+framecount,:] = source.gain*seq[1:framecount,:]
    source.time += framecount*source.dt
    source.uini = seq[end,:]
    framecount
end
