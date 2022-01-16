mutable struct ODESource{T} <: SampleSource
    samplerate::Float64
    timescale::Float64
    time::Float64
    dt::Float64
    pars::Vector{Float64} 
    problem::OrdinaryDiffEq.ODEProblem
    integrator::OrdinaryDiffEq.ODEIntegrator
end

# ODE EXAMPLE
function vdp!(du,u,p,t)
    du[1] = u[2]
    du[2] = p[1]*(1.0-u[1]*u[1])*u[2]-u[1]
end	

function ODESource(eltype, samplerate::Number, timescale::Number, pars::Array)
    u0 = [0.1, 0.1]
    tspan = (0.0, 100.0)
    problem = ODEProblem(vdp!,u0,tspan,pars)
    dt = timescale/samplerate
    integrator = init(problem,Tsit5())
    ODESource{eltype}(Float64(samplerate), timescale, time=0.0, dt, pars, problem,integrator)
end

Base.eltype(::ODESource{T}) where T = T
nchannels(source::ODESource) = 1
samplerate(source::ODESource) = source.samplerate

function unsafe_read!(source::ODESource, buf::Array, frameoffset, framecount)
    tend = source.time+(framecount-1)*source.dt
    seq = TimeChoiceIterator(source.integrator,time:source.dt:tend)
    buf[frameoffset+1:frameoffset+framecount,1] = [u[1] for (u,t) in seq]
    source.time += framecount*source.dt
    framecount
end