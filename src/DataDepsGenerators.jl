module DataDepsGenerators
using Gumbo, Cascadia, AbstractTrees

export generate, UCI


abstract type DataRepo end

struct Metadata
    fullname::String
    website::String
    description::String
    dataurls::Vector{String}
end


function message(meta)
    escape_multiline_string("""
    Dataset: $(meta.fullname)
    Website: $(meta.website)
    $(meta.description)


    """, "\$")
end



include("utils.jl")
include("generic_extractors.jl")
include("UCI.jl")

function data_shortnamename(repo::DataRepo, dataname)
    string(typeof(repo).name.name) * " " * dataname
end

function generate(repo::DataRepo, dataname)
    shortname = data_shortnamename(repo, dataname)
    meta = find_metadata(repo, dataname)
    """
    RegisterDataDep(
        \"$shortname\",
        \"\"\"
    $(indent(message(meta)))\"\"\",
        $(meta.dataurls)
    )
    """
end


end # module
