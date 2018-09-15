module DataDepsGenerators
using Gumbo, Cascadia, AbstractTrees
using JSON
using HTTP
using Dates

using InteractiveUtils: subtypes

export generate, citation_text, remove_cite_version
export UCI, GitHub, DataDryad, DataOneV1, DataOneV2, CKAN, DataCite, Figshare, JSONLD_Web, JSONLD_DOI




abstract type DataRepo end

struct GeneratorError{T<:DataRepo} <: Exception
    repo::T
    message::String
end

GeneratorError(repo)=GeneratorError(repo, "")

Base.showerror(io::IO, e::GeneratorError) = print(io, e.repo, " generator was not suitable. $(e.message)")



include("utils.jl")

include("metadata.jl")
include("generate.jl")
include("format_codeblock.jl")

include("misc_extractors.jl")



include("APIs/UCI.jl")
include("APIs/GitHub.jl")
include("APIs/DataDryad.jl")
include("APIs/DataOneV1.jl")
include("APIs/DataOneV2/DataOneV2.jl")
include("APIs/CKAN.jl")
include("APIs/DataCite.jl")
include("APIs/Figshare.jl")
include("APIs/JSONLD/JSONLD.jl")

end # module
