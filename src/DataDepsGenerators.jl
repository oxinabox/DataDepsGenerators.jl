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
    shortname::Opt{String}
    fullname::Opt{String}
    website::Opt{String}
    description::Opt{String}
    author::Opt{String}
    maintainer::Opt{String}
    license::Opt{String}
    publishedDate::Opt{String}
    createDate::Opt{String}
    modifiedDate::Opt{String}
    paperCite::Opt{String}
    datasetCite::Opt{String}
    dataurls::Opt{Vector}
    datachecksums::Any
end

function find_metadata(repo, dataname, shortname)

    mainpage, url = mainpage_url(repo, dataname)
    fullname = data_fullname(repo, mainpage)
    if shortname == nothing
        shortname = reduce((s,r)->replace(s, r, ""), fullname, ['\\', '/', ':', '*', '?', '<', '>', '|'])
    end

    Metadata(
        fullname,
        shortname,
        website(repo, url, mainpage),
        description(repo, mainpage),
        author(repo, mainpage),
        maintainer(repo, mainpage),
        license(repo, mainpage),
        publishedDate(repo, mainpage),
        createDate(repo, mainpage),
        modifiedDate(repo, mainpage),
        paperCite(repo, mainpage),
        datasetCite(repo, mainpage),
        get_urls(repo, mainpage),
        get_checksums(repo, mainpage)
    )
end

website(::DataRepo, url, mainpage) = url
description(::DataRepo, mainpage) = missing
author(::DataRepo, mainpage) = missing
maintainer(::DataRepo, mainpage) = missing
license(::DataRepo, mainpage) = missing
publishedDate(::DataRepo, mainpage) = missing
createDate(::DataRepo, mainpage) = missing
modifiedDate(::DataRepo, mainpage) = missing
paperCite(::DataRepo, mainpage) = missing
datasetCite(::DataRepo, mainpage) = missing
get_checksums(::DataRepo, mainpage) = missing
get_urls(::DataRepo, mainpage) = missing

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
    netString =  """
    register(DataDep(
        \"$(meta.shortname)\",
        \"\"\""""
    netString = format_meta(meta.website, netString, "Website")
    netString = format_meta(format_authors(meta.author), netString, "Author", true)
    netString = format_meta(meta.maintainer, netString, "Maintainer", true)
    netString = format_meta(meta.license, netString, "License", true)
    netString = format_meta(meta.publishedDate, netString, "Date of Publication", true)
    netString = format_meta(meta.createDate, netString, "Date of Creation", true)
    netString = format_meta(meta.modifiedDate, netString, "Date of Modification", true)
    netString = format_meta(meta.description, netString, missing,  true)
    netString = format_meta(meta.paperCite, netString, "Please cite this paper", true)
    netString = format_meta(meta.datasetCite, netString, "Please cite this dataset", true)
    netString = strip(netString * "\n\"\"\",")
    netString = format_meta(meta.dataurls, netString)
    netString = netString * ","
    netString = format_meta(format_checksums(meta.datachecksums), netString)
    netString = strip(netString * "\n))")

    netString
end

function format_meta(data::Any, netString, label=missing, indentbool=false)
    if ismissing(data)
        return netString
    else
        new_data = (indentbool? indent(string(data)) : string(data))
        if ismissing(label)
            return netString * "\n" * new_data
        else
            return netString * "\n" * label * ": " * new_data
        end
    end
end

function generate(repo::DataRepo,
                  dataname,
                  shortname = nothing
    )

    meta = find_metadata(repo, dataname, shortname)

    message(meta)
end

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

format_checksums(::Void) = missing

format_checksums(::Missing) = missing

function format_authors(authors::Vector)
    if length(authors) == 1
        authors[1]
    elseif length(authors) == 2
        authors[1] * ", " * authors[2]
    elseif length(authors) >2
        authors[1] * " et al."
    else
        warn("Not able to retrieve any authors")
        missing
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
