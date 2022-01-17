mutable struct ODESource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int
    time::Float64
    dt::Float64
    gain::Float64
    problem::OrdinaryDiffEq.ODEProblem
    integrator::OrdinaryDiffEq.ODEIntegrator
end


function ODESource(eltype, system::Function, samplerate::Number, timescale::Number, start_point::Array, pars::Array)
    nchannels = length(start_point)
    time = 0.0
    gain = 0.1
    tspan = (0.0, 100.0)
    problem = ODEProblem(system,start_point,tspan,pars)
    dt = timescale/samplerate
    integrator = init(problem,Tsit5())
    ODESource{eltype}(Float64(samplerate), nchannels, time, dt, gain,problem,integrator)
end

Base.eltype(::ODESource{T}) where T = T
nchannels(source::ODESource) = source.nchannels
samplerate(source::ODESource) = source.samplerate

function unsafe_read!(source::ODESource, buf::Array, frameoffset, framecount)
    tend = source.time+(framecount-1)*source.dt
    seq = TimeChoiceIterator(source.integrator,source.time:source.dt:tend)
    buf[frameoffset+1:frameoffset+framecount,:] = reduce(vcat,[source.gain*u[:]' for (u,t) in seq])
    source.time += framecount*source.dt
    framecount
end