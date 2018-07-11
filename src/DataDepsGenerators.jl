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
    publishedDate::Union{DateTime, Opt{String}}
    createDate::Union{DateTime, Opt{String}}
    modifiedDate::Union{DateTime, Opt{String}}
    paperCite::Opt{String}
    datasetCite::Opt{String}
    dataurls::Opt{Vector}
    datachecksums::Any
end

function find_metadata(repo, dataname, shortname)

    mainpage, url = mainpage_url(repo, dataname)
    fullname = data_fullname(repo, mainpage)
    shortname = data_shortname(repo, shortname, fullname)

    Metadata(
        fullname,
        shortname,
        website(repo, url, mainpage),
        description(repo, mainpage),
        format_authors(author(repo, mainpage)),
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

function data_shortname(repo, shortname::Void, fullname)
    # Remove any characters not allowed in a file path
    reduce((s,r)->replace(s, r, ""), fullname, ['\\', '/', ':', '*', '?', '<', '>', '|'])
end

data_shortname(repo, shortname, fullname) = shortname

format_dates(rawdate) = rawdate #Catches the missing and the string
format_dates(rawdate::Dates.Date) = Dates.format(rawdate, "U d, yyyy")

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
    netString *= format_meta(meta.website, "Website")
    netString *= format_meta(meta.author, "Author")
    netString *= format_meta(meta.maintainer, "Maintainer")
    netString *= format_meta(format_dates(meta.publishedDate), "Date of Publication")
    netString *= format_meta(format_dates(meta.createDate), "Date of Creation")
    netString *= format_meta(format_dates(meta.modifiedDate), "Date of Last Modification")
    netString *= format_meta(meta.license, "License")
    netString *= "\n"
    netString *= format_meta(meta.description)
    netString *= format_meta(meta.paperCite, "\nPlease cite this paper")
    netString *= format_meta(meta.datasetCite, "\nPlease cite this dataset")
    netString *= "\n\"\"\","
    netString = netString |> strip
    netString *= format_meta(meta.dataurls, indent_field=false)
    netString *= ","
    netString *= format_meta(format_checksums(meta.datachecksums), indent_field=false)
    netString *= "\n))"

    netString
end

format_meta(::Missing, args...; kwargs...) = ""

function format_meta(data::Any, label=""; indent_field=true)
    if label != ""
        label*=":"
    end
    field = (indent_field ? indent(string(data)) : string(data))
    return "\n" * label * field
end

format_authors(authors::Missing) = "Authors not specified"

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

format_checksums(::Missing) = missing

format_authors(authors::AbstractString) = authors

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

function handle_null(attr::Any)
    attr != nothing? attr : missing
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
