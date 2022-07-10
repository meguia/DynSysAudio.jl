### A Pluto.jl notebook ###
# v0.19.9

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ f735551e-9eb0-44d1-9b28-2e52437dab3e
using Pkg; Pkg.add("DifferentialEquations");Pkg.add("PortAudio");Pkg.add("SampledSignals");Pkg.add("Unitful");Pkg.add("PlutoUI");Pkg.add("DSP");Pkg.add("Plots");Pkg.add("Pipe");

# ╔═╡ ca79dbd0-e662-11ec-3fd3-952bfc9d3247
using DifferentialEquations, PortAudio,SampledSignals, Unitful, PlutoUI, DSP, Plots

# ╔═╡ 1a5f71e9-0451-4e76-9526-e6f283ea9531
using Pipe: @pipe

# ╔═╡ 243593f5-eaa7-4a47-8470-46abd9b64cf5
include("../DynSysAudio.jl")

# ╔═╡ 6793be34-9055-403f-a16f-90c57201f843
theme(:dark)

# ╔═╡ 02489954-cc81-4e08-bc20-70147414f0bb
sdev = PortAudio.devices()

# ╔═╡ 09eff68c-2541-4dbe-b87b-97a8885f2e16
soundcard = PortAudioStream(sdev[6],0,2) #CHECK YOUR AUDIO OUTPUT

# ╔═╡ 53cdcf81-3a83-42f0-a338-b32094200298
function thomas!(du,u,p,t)
	du[1]=sin(p[1]*u[2])-p[2]*u[1]
	du[2]=sin(p[1]*u[3])-p[2]*u[2]
	du[3]=sin(p[1]*u[1])-p[2]*u[3]
end		

# ╔═╡ abd92eb6-6963-43d8-b277-c6940d56ecde
mapping = [1 0; 0 1; 0 0];

# ╔═╡ b820531d-75a2-4049-ba55-822c3b3d3b9b
@bind ticks Clock(0.1,true)

# ╔═╡ 52f25ad8-540a-4505-9690-877a223d0a41
md"""
azimut $(@bind az Slider(0:5:90,default=60;show_value=true)) 
elevation $(@bind el Slider(0:5:90,default=30;show_value=true)) \
tail $(@bind tail Slider(30:50:500,default=100;show_value=true)) 
"""

# ╔═╡ 98de6555-d4f5-4cd6-9875-b7a17957dc96
md"""
a $(@bind a Slider(0.0:0.01:5.0,default=1.0;show_value=true)) 
b $(@bind b Slider(0.0:0.001:1.0,default=0.2;show_value=true)) \
Δt $(@bind Δt Slider(0.001:0.001:1.0,default=0.11;show_value=true)) 
gain $(@bind g Slider(0:0.001:0.2,default=0.1;show_value=true)) \
reset $(@bind resetic Button("reset!")) 
restart  $(@bind restart Button("restart!"))
"""

# ╔═╡ 17cda66b-c90c-47bd-8883-fc5a4949a0b3
# some values
#a = 1.47 b = 0.195 dt = 0.035
#a = 1.12 b = 0.2 dt = 0.06

# ╔═╡ a81916f4-595f-4175-a5dc-510e38cb5076
ode_source = DynSysAudio.ODESource(Float64, thomas!, 44100, 5.0, [1.0;1.1;-0.01],[0.2,0.2]);

# ╔═╡ 9e6b85e1-345a-4519-b095-45ff33a67a2a
begin
	restart
	ode_source.gain = 0.0
	sleep(1)
	ode_source.gain = 0.1
	ode_stream = Threads.@spawn begin
	    while ode_source.gain>0.0
	        @pipe read(ode_source, 0.05u"s") |> DynSysAudio.mixer(mapping,_) |> write(soundcard, _)
	    end
	end
end;

# ╔═╡ f69b0c75-f868-4d0e-9cde-230ee32dc184
begin
	ode_source.gain=g
	ode_source.pars=[a,b]
	ode_source.dt=Δt
end;

# ╔═╡ 46107d77-d3f6-4432-b269-7bb67eda8e78
begin
	ticks
	sol = solve(ODEProblem(thomas!,ode_source.uini,(ode_source.time,ode_source.time+tail),[a,b]));
end;

# ╔═╡ bac44977-95a5-470d-80a3-1c5e4a24dbe6
plot(sol,vars=(1,2,3),c=:yellow,label="thomas",size=(800,600), camera = (az, el))


# ╔═╡ 9fa17e98-7a05-4473-9d38-f0f5f348da60
begin
	resetic
	ode_source.uini=[1.0;1.1;-0.001]
end;

# ╔═╡ 3f683dd7-0938-454c-a61a-6cde2fb87fce
html"""
<style>
input[type*="range"] {
	width: 30%;
}
</style>
"""

# ╔═╡ Cell order:
# ╟─f735551e-9eb0-44d1-9b28-2e52437dab3e
# ╠═ca79dbd0-e662-11ec-3fd3-952bfc9d3247
# ╠═1a5f71e9-0451-4e76-9526-e6f283ea9531
# ╠═6793be34-9055-403f-a16f-90c57201f843
# ╠═243593f5-eaa7-4a47-8470-46abd9b64cf5
# ╠═02489954-cc81-4e08-bc20-70147414f0bb
# ╠═09eff68c-2541-4dbe-b87b-97a8885f2e16
# ╟─53cdcf81-3a83-42f0-a338-b32094200298
# ╟─abd92eb6-6963-43d8-b277-c6940d56ecde
# ╟─9e6b85e1-345a-4519-b095-45ff33a67a2a
# ╠═b820531d-75a2-4049-ba55-822c3b3d3b9b
# ╟─52f25ad8-540a-4505-9690-877a223d0a41
# ╟─bac44977-95a5-470d-80a3-1c5e4a24dbe6
# ╟─98de6555-d4f5-4cd6-9875-b7a17957dc96
# ╠═17cda66b-c90c-47bd-8883-fc5a4949a0b3
# ╟─a81916f4-595f-4175-a5dc-510e38cb5076
# ╟─f69b0c75-f868-4d0e-9cde-230ee32dc184
# ╟─46107d77-d3f6-4432-b269-7bb67eda8e78
# ╟─9fa17e98-7a05-4473-9d38-f0f5f348da60
# ╟─3f683dd7-0938-454c-a61a-6cde2fb87fce
