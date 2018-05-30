

println("="^70)
file = download("https://datadryad.org/bitstream/handle/10255/dryad.173075/Fuzzy%20coded%20trait%20data.xlsx?sequence=1")
@show stat(file)
println("="^70)
file = download("https://datadryad.org/bitstream/handle/10255/dryad.173251/raw_data.zip?sequence=1")
@show stat(file)
println("="^70)
