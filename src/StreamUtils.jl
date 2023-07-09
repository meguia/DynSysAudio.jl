using PortAudio: PortAudioStream, devices

function soundcard_init(device_name::String,fs::Int64)
    sdev = devices()
    device_index = findfirst(x->occursin(device_name,x.name),sdev)
    if isnothing(device_index)
        error("Device not found")
    end
    soundcard = PortAudioStream(sdev[device_index],0,2; samplerate=fs)
    return soundcard
end    