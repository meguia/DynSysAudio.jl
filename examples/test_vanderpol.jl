using PortAudio, DynSysAudio, SampledSignals
using Pipe: @pipe

# ODE EXAMPLE
function vdp!(du,u,p,t)
    du[1] = u[2]
    du[2] = p[1]*(1.0-u[1]*u[1])*u[2]-u[1]
end	

function get_first_soundcard_matching(soundcard::String="Speaker")
    a = PortAudio.devices()
    idx = [occursin(soundcard, d.name) for d in a]
    if sum(idx) > 1
        print("Multiple soundcards with requested name ($soundcard) were found: $a")
    end
    name = a[findfirst(idx)].name
    println("Using device: $name")
    stream = PortAudioStream(name, 0, 2)
end

soundcard = get_first_soundcard_matching()
source = ODESource(Float64, vdp!, 48000, 400, [0.2,0.2], 3.0)

noise_stream = Threads.@spawn begin
    while amplify.current > 0.001
        @pipe read(noise_source, 0.01u"s") |> modify(amplify, _) |> modify(bandpass, _) |> write(soundcard, _)
    end
end