module DataDepsGenerators
using Gumbo, Cascadia, AbstractTrees
using Suppressor
using JSON
using HTTP
using Missings

export generate, citation_text
export UCI, GitHub, DataDryad, DataOneV1, DataOneV2, CKAN, DataCite, Figshare, JSONLD

abstract type DataRepo end

const Opt{T} = Union{Missing, T}
struct Metadata
    fullname::Opt{String}
    website::Opt{String}
    description::Opt{String}
    dataurls::Opt{Vector}
    datachecksums::Any
end

function find_metadata(repo, dataname)

    mainpage, url = mainpage_url(repo, dataname)

    Metadata(
        data_fullname(repo, mainpage),
        website(repo, url, mainpage),
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
include("DataOneV1.jl")
include("DataOneV2/DataOneV2.jl")
include("CKAN.jl")
include("DataCite.jl")
include("Figshare.jl")
include("JSONLD/JSONLD.jl")

function message(meta)
    escape_multiline_string("""
    Dataset: $(meta.fullname)
    Website: $(meta.website)
    $(meta.description)
    """) |> strip
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
    register(DataDep(
        \"$shortname\",
        \"\"\"
        $(indent(message(meta)))
        \"\"\",
        $(meta.dataurls),
        $(format_checksums(meta.datachecksums))
    ))
    """
end

get_checksums(repo::DataRepo, page) = nothing

function format_checksums(csums::Vector)
    csumvec = join(format_checksums.(csums), ", ")
    "[$csumvec]"
end

function format_checksums(csum::Tuple{T,<:AbstractString}) where T<:Symbol
    func = string(csum[1])
    hashstring = format_checksums(csum[2])
    "($func, $hashstring)"
end

function format_checksums(csum::AbstractString)
    if length(csum)>0 "\"$csum\"" else "" end
end

function format_checksums(::Void)
    ""
end

function format_authors(authors::Vector)
    if length(authors) == 1
        authors[1]
    elseif length(authors) == 2
        authors[1] * ", " * authors[2]
    elseif length(authors) >2
        authors[1] * " et al."
    else
        warn("Not able to retrieve any authors")
        "Unknown Author"
    end
end

function format_papers(authors::Vector, year::String, name::String, link::String)
    #APA format. Other formats can be included here later.
    join(authors, ", ") * " ($year). " * name * " " * link
end

function match_doi(uri::String)
    identifier_match = match(r"\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?![\"&\'<>])\S)+)\b", uri)
    identifier_match === nothing ? nothing : identifier_match.match
end

website(::DataRepo, mainpage_url, mainpage) = mainpage_url

function mainpage_url(repo::DataRepo, dataname)
    if startswith(dataname, "http")
        url = dataname
        #TODO: This isn't going to take https/http differences.
        dataname = first(split(replace(url, base_url(repo), ""), "/"))
    else # not a URL
        url = joinpath(base_url(repo), dataname)
    end
    getpage(url), url
end

end # module
