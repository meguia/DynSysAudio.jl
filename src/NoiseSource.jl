mutable struct NoiseSource{T} <: SampleSource
    samplerate::Float64
    nchannels::Int64
    std::Float64

    function NoiseSource(eltype, samplerate::Number, nchannels::Int, std::Number=1)
        new{eltype}(samplerate, nchannels, std)
    end
    function NoiseSource(eltype, samplerate::Unitful.Frequency, nchannels::Int, std::Number=1)
        samplerate = ustrip(uconvert(u"Hz", samplerate))
        NoiseSource(eltype, samplerate, nchannels, std)
    end
end

Base.eltype(::NoiseSource{T}) where T = T
nchannels(source::NoiseSource) = source.nchannels
samplerate(source::NoiseSource) = source.samplerate

function unsafe_read!(source::NoiseSource, buf::Array, frameoffset, framecount)
    buf[1+frameoffset:framecount+frameoffset, 1:source.nchannels] = source.std .* randn(framecount, source.nchannels)
    framecount
end