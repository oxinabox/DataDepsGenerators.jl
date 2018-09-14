module DataDepsGenerators
using Gumbo, Cascadia, AbstractTrees
using Suppressor
using JSON
using HTTP
using Dates

using InteractiveUtils: subtypes

export generate, citation_text, remove_cite_version
export UCI, GitHub, DataDryad, DataOneV1, DataOneV2, CKAN, DataCite, Figshare, JSONLD

abstract type DataRepo end

const Opt{T} = Union{Missing, T}
struct Metadata
    shortname::Opt{String}
    fullname::Opt{String}
    website::Opt{String}
    description::Opt{String}
    author::Opt{Vector{String}}
    maintainer::Opt{String}
    license::Opt{String}
    published_date::Opt{Union{Date, DateTime,String}}
    create_date::Opt{Union{Date, DateTime,String}}
    modified_date::Opt{Union{Date, DateTime,String}}
    paper_cite::Opt{String}
    dataset_cite::Opt{String}
    dataurls::Opt{Vector}
    datachecksums::Any
end

function find_metadata(repo, dataname, shortname)
    mainpage, url = mainpage_url(repo, dataname)
    fullname = data_fullname(repo, mainpage)
    shortname = data_shortname(repo, shortname, fullname)

    Metadata(
        shortname,
        fullname,
        website(repo, url, mainpage),
        description(repo, mainpage),
        author(repo, mainpage),
        maintainer(repo, mainpage),
        license(repo, mainpage),
        published_date(repo, mainpage),
        create_date(repo, mainpage),
        modified_date(repo, mainpage),
        paper_cite(repo, mainpage),
        dataset_cite(repo, mainpage),
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
published_date(::DataRepo, mainpage) = missing
create_date(::DataRepo, mainpage) = missing
modified_date(::DataRepo, mainpage) = missing
paper_cite(::DataRepo, mainpage) = missing
dataset_cite(::DataRepo, mainpage) = missing
get_checksums(::DataRepo, mainpage) = missing
get_urls(::DataRepo, mainpage) = missing

include("utils.jl")
include("generic_extractors.jl")
include("APIs/UCI.jl")
include("APIs/GitHub.jl")
include("APIs/DataDryad.jl")
include("APIs/DataOneV1.jl")
include("APIs/DataOneV2/DataOneV2.jl")
include("APIs/CKAN.jl")
include("APIs/DataCite.jl")
include("APIs/Figshare.jl")
include("APIs/JSONLD/JSONLD.jl")

function aggregate(metadatas)

    meta = Metadata(
        combine_all(metadatas, :shortname),
        combine_all(metadatas, :fullname),
        combine_all(metadatas, :website),
        combine_all(metadatas, :description),
        combine_all(metadatas, :author),
        combine_all(metadatas, :maintainer),
        combine_all(metadatas, :license),
        combine_all(metadatas, :published_date),
        combine_all(metadatas, :create_date),
        combine_all(metadatas, :modified_date),
        combine_all(metadatas, :paper_cite),
        combine_all(metadatas, :dataset_cite),
        combine_all(metadatas, :dataurls),
        combine_all(metadatas, :datachecksums),
    )
    body(meta)  
end

function getfieldlist(metadatas::Vector, sym::Symbol)
    return [getfield(i, sym) for i in metadatas]
end

function combine_all(values::Vector, sym::Symbol)
    ret = missing
    for value in getfieldlist(values, sym)
        ret = combine(ret, value, sym)
    end
    ret
end

#Redispatch based on Value
combine(x::String, y::String, s::Symbol) = combine(x,y,Val{s}())

combine(::Missing, ::Missing, ::Any) = missing
combine(::Missing, x, ::Any) = x
combine(x, ::Missing, ::Any) = x
combine(x::Vector, y::Vector, ::Any) = length(x) > length(y) ? x : y
combine(x::String, y::String, ::Val{:license}) = length(x) < length(y) ? x : y
combine(x::String, y::String, ::Any) = length(x) > length(y) ? x : y
combine(x::Union{DateTime, Date}, y::String, ::Any) = x
combine(x::String, y::Union{DateTime, Date}, ::Any) = y

function body(meta)
    netString =  """
    register(DataDep(
        \"$(meta.shortname)\",
        \"\"\""""
    netString *= format_meta(meta.fullname, "Dataset")
    netString *= format_meta(meta.website, "Website")
    ## Start of the message
    netString *= format_meta(format_authors(meta.author), "Author")
    netString *= format_meta(meta.maintainer, "Maintainer")
    netString *= format_meta(format_dates(meta.published_date), "Date of Publication")
    netString *= format_meta(format_dates(meta.create_date), "Date of Creation")
    netString *= format_meta(format_dates(meta.modified_date), "Date of Last Modification")
    netString *= format_meta(meta.license, "License")
    netString *= "\n"
    netString *= format_meta(meta.description)
    netString *= format_meta(meta.paper_cite, "\nPlease cite this paper")
    netString *= format_meta(meta.dataset_cite, "\nPlease cite this dataset")
    netString *= "\n\t\"\"\","
    netString = netString |> strip
    ## End of the message
    netString *= format_meta(ismissing(meta.dataurls) ? "missing" : meta.dataurls)
    netString *= ","
    netString *= format_meta(format_checksums(meta.datachecksums))
    netString *= "\n))"

    netString
end

format_meta(::Missing, args...; kwargs...) = ""

function format_meta(data::Any, label="")
    if label != ""
        label*=": "
    end
    return "\n" * indent(label * string(data))
end

function generate(repo::DataRepo, dataname; kwargs...)
    generate([repo], dataname; kwargs...)
end

function generate(dataname; kwargs...)
    all_repos = [T() for T in leaf_subtypes(DataRepo)]
    generate(all_repos, dataname; kwargs...)
end


function generate(repos::Vector, dataname; shortname = nothing, show_failures=false)
    retrieved_metadatas_ch = Channel{Any}(128)
    failures = Channel{Tuple{DataRepo, Exception}}(128)
    
    # Get all the metadata we can
    for repo in repos
        try
            metadata = find_metadata(repo, dataname, shortname)
            push!(retrieved_metadatas_ch, metadata)
        catch err
            push!(failures, (repo, err))
        end
    end
    close(retrieved_metadatas_ch)
    close(failures)
    
    retrieved_metadatas = collect(retrieved_metadatas_ch)
    # Display errors if required
    if length(retrieved_metadatas) == 0 || show_failures
        for (repo, err) in failures
            println(repo, " failed due to")
            println(err)
            println()
        end
    end
    
    # merge them
    aggregate(retrieved_metadatas)
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

format_checksums(::Missing) = missing

function format_checksums(csum::AbstractString)
    if length(csum)>0 "\"$csum\"" else "" end
end

format_authors(authors::Missing) = "Authors not specified"

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
        format_authors(missing)
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

struct GeneratorError{T<:DataRepo} <: Exception
    repo::T
    message::String
end

GeneratorError(repo)=GeneratorError(repo, "")

Base.showerror(io::IO, e::GeneratorError) = print(io, e.repo, " generator was not suitable. $(e.message)")

end # module
