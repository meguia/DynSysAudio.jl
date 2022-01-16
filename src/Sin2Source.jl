mutable struct Sin2Source{T} <: SampleSource
    samplerate::Float64
    freqs::Vector{Float64} # in radians/sample
    phases::Vector{Float64}
end

function Sin2Source(eltype, samplerate, freqs::Array)
    # convert frequencies from cycles/sec to rad/sample
    radfreqs = map(f->2pi*f/samplerate, freqs)
    Sin2Source{eltype}(Float64(samplerate), radfreqs, zeros(length(freqs)))
end

# also allow a single frequency
Sin2Source(eltype, samplerate, freq::Real) = Sin2Source(eltype, samplerate, [freq])

Base.eltype(::Sin2Source{T}) where T = T
nchannels(source::Sin2Source) = length(source.freqs)
samplerate(source::Sin2Source) = source.samplerate

function unsafe_read!(source::Sin2Source, buf::Array, frameoffset, framecount)
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