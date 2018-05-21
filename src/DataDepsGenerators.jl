module DataDepsGenerators
using Gumbo, Cascadia, AbstractTrees
using Suppressor

export generate, UCI, GitHub, DataDryad

abstract type DataRepo end

struct Metadata
    fullname::String
    website::String
    description::String
    dataurls::Vector
    datachecksums::Any
end

function find_metadata(repo, dataname)
    if startswith(dataname, "http")
        mainpage_url = dataname
        #TODO: This isn't going to take https/http differences.
        dataname = first(split(replace(mainpage_url, base_url(repo), ""), "/"))
    else # not a URL
        mainpage_url = joinpath(base_url(repo), dataname)
    end

    mainpage = getpage(mainpage_url)

    Metadata(
        data_fullname(repo, mainpage),
        mainpage_url,
        description(repo, mainpage),
        get_urls(repo, mainpage),
        get_checksums(repo, mainpage)
    )
end



include("utils.jl")
include("generic_extractors.jl")
include("UCI.jl")
include("GitHub.jl")
include("DataDryad.jl")



function message(meta)
    escape_multiline_string("""
    Dataset: $(meta.fullname)
    Website: $(meta.website)
    $(meta.description)
    """, "\$")
end


function data_shortnamename(repo::DataRepo, meta)
    short_name = meta.fullname
    reduce((s,r)->replace(s, r, ""), short_name, ['\\', '/', ':', '*', '?', '<', '>', '|'])
end

function generate(repo::DataRepo,
                  dataname,
                  shortname = nothing
    )

    meta = find_metadata(repo, dataname)
    if shortname == nothing
        shortname = data_shortnamename(repo, meta)
    end
    """
    RegisterDataDep(
        \"$shortname\",
        \"\"\"
    $(indent(message(meta)))\"\"\",
        $(meta.dataurls),
        $(meta.datachecksums)
    )
    """
end

function get_checksums(repo::DataRepo, page)
    checksums = nothing
    checksums
end

end # module
