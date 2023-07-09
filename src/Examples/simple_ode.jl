using DifferentialEquations, PortAudio,SampledSignals, Unitful
using Pipe: @pipe
include("../DynSysAudio.jl")

fs = 44100
dt = 0.1
dur = 10.0u"s"

sdev = PortAudio.devices()
device_name = "Scarlett"
println("Initilazing soundcard: $device_name")
device_index = findfirst(x->occursin(device_name,x.name),sdev)
soundcard = PortAudioStream(sdev[device_index],0,2; samplerate=fs)
println("Soundcard initialized")

function takens3!(du,u,p,t)
    du[1]=u[2]
    du[2]=p[1]+p[4]*sin(p[5]*t)+u[1]*(p[2]+p[3]*cos(p[5]*t)-u[2]+u[1]*(1-u[1]-u[2]))
end  

p = [-0.18,0.0,0.12,0.05,0.001]
ode_source = DynSysAudio.ODESource(Float64, takens3!, fs, dt, [0.001,0.0],p);
ode_source.gain = 0.1
println("Odesource defined")

@pipe read(ode_source, dur)  |> write(soundcard, _)


