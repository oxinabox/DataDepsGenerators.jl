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
        remove_cite_version(dataset_cite(repo, mainpage)),
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
include("UCI.jl")
include("GitHub.jl")
include("DataDryad.jl")
include("DataOneV1.jl")
include("DataOneV2/DataOneV2.jl")
include("CKAN.jl")
include("DataCite.jl")
include("Figshare.jl")
include("JSONLD/JSONLD.jl")

function aggregate(generator_meta)

    meta = Metadata(
        reduct(generator_meta, :shortname),
        reduct(generator_meta, :fullname),
        reduct(generator_meta, :website),
        reduct(generator_meta, :description),
        reduct(generator_meta, :author),
        reduct(generator_meta, :maintainer),
        reduct(generator_meta, :license),
        reduct(generator_meta, :published_date),
        reduct(generator_meta, :create_date),
        reduct(generator_meta, :modified_date),
        reduct(generator_meta, :paper_cite),
        reduct(generator_meta, :dataset_cite),
        reduct(generator_meta, :dataurls),
        reduct(generator_meta, :datachecksums),
    )
    body(meta)  
end

function reduct(generator_meta::Vector, sym::Symbol)
    if !isdefined(:primval) && length(generator_meta) > 0
        primval = getfield(generator_meta[1], sym)
    end
    for ii in generator_meta
        if !ismissing(getfield(ii, sym))
            if ismissing(primval) || rule_dispatcher(getfield(ii, sym), primval, sym)
                primval = getfield(ii, sym)
            end
        end
    end
    primval
end

function rule_dispatcher(fieldvar::Vector, prevvar::Vector, sym::Symbol)
    (length(fieldvar) > length(prevvar))
end

function rule_dispatcher(fieldvar::Union{Date,DateTime,String}, prevvar::Union{Date,DateTime,String}, sym::Symbol)
    if (isa(fieldvar, Date) || isa(fieldvar, DateTime))
        # For dates, Date formats are always preferred over Strings
        return true
    end
    if sym == Symbol("license")
        # Shorter (nonzero) license text is better
        return (length(fieldvar) < length(prevvar)) ? length(fieldvar) !=0 : false
    end
    # General rule: Longer texts are better. More descript.
    return (length(fieldvar) > length(prevvar))
end

function remove_cite_version(cite::String)
    replace(cite, r"\(Version 1\) " => "")
end

remove_cite_version(cite::Missing) = missing

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
    netString *= format_meta(meta.dataurls)
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


function generate(repo::DataRepo,
                  dataname,
                  shortname = nothing
    )
    generators = create_generators(repo::DataRepo,dataname::Any)
    generator_meta = []
    for ii in generators
        push!(generator_meta, find_metadata(ii, dataname, shortname))
    end
    aggregate(generator_meta)
end

function format_checksums(csums::Vector)
    csumvec = join(format_checksums.(csums), ", ")
    "[$csumvec]"
end

function create_generators(repo::DataRepo, dataname)
    generators = []
    if (match_doi(dataname)) != nothing
        # generators = [DataCite(), Figshare()]
        generators = []
    end
    if !any(x->x==repo, generators)
        push!(generators, repo)
    end
    generators
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

end # module
