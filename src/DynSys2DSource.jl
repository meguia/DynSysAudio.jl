mutable struct SinusoidSource{T} <: SampleSource
    samplerate::Float64
    freqs::Vector{Float64} # in radians/sample
    phases::Vector{Float64}
end

function SinusoidSource(eltype, samplerate, freqs::Array)
    # convert frequencies from cycles/sec to rad/sample
    radfreqs = map(f->2pi*f/samplerate, freqs)
    SinusoidSource{eltype}(Float64(samplerate), radfreqs, zeros(length(freqs)))
end

# also allow a single frequency
SinusoidSource(eltype, samplerate, freq::Real) = SinusoidSource(eltype, samplerate, [freq])

Base.eltype(::SinusoidSource{T}) where T = T
nchannels(source::SinusoidSource) = length(source.freqs)
samplerate(source::SinusoidSource) = source.samplerate

function unsafe_read!(source::SinusoidSource, buf::Array, frameoffset, framecount)
    inc = 2pi / samplerate(source)
    for ch in 1:nchannels(buf)
        f = source.freqs[ch]
        ph = source.phases[ch]
        for i in 1:framecount
            buf[i+frameoffset, ch] = sin.(ph)
            ph += f
        end
        source.phases[ch] = ph
    end

    framecount
end