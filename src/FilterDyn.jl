using DSP: Butterworth, digitalfilter, DF2TFilter, Bandpass, Lowpass, Highpass, filt

mutable struct FilterDyn{T}
    filter::Array{DF2TFilter, 1}  # Filter object
    enable::Bool
    num_filters::Int
end

function FilterDyn(samplerate::Number,nchannels::Int64;order=4,lcut=nothing,hcut=nothing)
    if hcut!==nothing && lcut!==nothing
        responsetype = Bandpass(lcut, hcut; fs=samplerate)
    elseif lcut!==nothing
        responsetype = Highpass(lcut; fs=samplerate)
    elseif hcut!==nothing
        responsetype = Lowhpass(hcut; fs=samplerate)
    else    
        error("lcut and/or hcut must be defined")
    end    
    designmethod = Butterworth(order)
    zpg = digitalfilter(responsetype, designmethod)
    ff = fill(DF2TFilter(zpg),nchannels)
    FilterDyn{eltype}(ff, true, length(ff))
end

Base.eltype(::FilterDyn{T}) where T = T

function modify(sink::FilterDyn, buf)
    if sink.enable
        for idx in 1:sink.num_filters
            buf.data[:, idx] = filt(sink.filter[idx], buf.data[:, idx])
        end
    end
    return buf
end