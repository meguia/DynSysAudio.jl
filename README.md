# DynSysAudio
A very basic package for the sonification of Dynamical Systems using [DifferentialEquations.jl](https://github.com/SciML/DifferentialEquations.jl) and [SampledSignals.jl](https://github.com/JuliaAudio/SampledSignals.jl)

The main element is the ODE audio source `ODESource`, inspired in the `SinSource.jl` Sinusoidal Generator of SampledSignals.jl.
This mutable structure is defined as:

`ode_source = ODESource(Float64, f, sr, dt, uini,p);`

where $f$ is the vector field, $sr$ the sampling rate, $dt$ the time step (for time scaling) and $uini$ and $p$ are two arrays corresponding to the initial conditions and the parameters of the dynamical system respectively.

The function `read(ode_source,buffer_size)` returns a buffer of duration `buffer_size` (specified in real units using Unitful), which is a `SampleBuf` data type that can be written directly to the audio output:

`using Pipe:@pipe; @pipe read(ode_source,buffer_size) |> write(soundcard,_)`

where `soundcard` is the Portaudio device.

If the number of variables of the vector field does not match the number of channels, a mapping function can be defined using a mixed matrix. For example, for mapping the two first variables of a 3D flow to the left and right channels of a stereo output the matrix is: `mapping=[1 0; 0 1; 0 0]` and the mixer can be inserted before the audio output: 

`using Pipe:@pipe; @pipe read(ode_source,buffer_size) |> mixer(mapping,_) |> write(soundcard,_)`

Also, a few Pluto notebooks with examples are provided. 



