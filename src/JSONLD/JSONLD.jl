abstract type JSONLD <: DataRepo
end

export JSONLD_Web, JSONLD_DOI

include("JSONLD_Web.jl")
include("JSONLD_DOI.jl")

function description(repo::JSONLD, mainpage)
    desc = filter_html(handle_keys(mainpage, "description"))
    authors = get_authors(repo, mainpage)
    author = format_authors(authors)
    license = get_license(mainpage)
    date = get_dates(repo, mainpage)

    """
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)
    """
end

function get_authors(repo::JSONLD, mainpage)
    authors = handle_keys(mainpage, "author", "creator")
    if authors isa Vector
        return collect(skipmissing(handle_keys.(authors, "name")))
    elseif authors isa Dict
        return [handle_keys(authors, "name")]
    else
        return []
    end
    
end

function get_dates(repo::JSONLD, mainpage)
    rawdate = handle_keys(mainpage, "datePublished", "dateCreated", "dateModified")
    try
        return Dates.format(Dates.DateTime(rawdate), "U d, yyyy")
    catch error
        if error isa MethodError
            return rawdate
        end
    end
end

function get_license(mainpage)
    license = handle_keys(mainpage, "license")
    if license isa String
        return license
    elseif license isa Dict
        return handle_keys(license, "url", "text")
    end
end

handle_keys(json, key, otherkeys...) = get(json,  key) do
    handle_keys(json, otherkeys...)
end

handle_keys(json) = nothing

function get_urls(repo::JSONLD, page)
    urls = []
    url_list = handle_keys(page, "distribution")
    if url_list != nothing
        urls = [handle_keys(ii, "contentUrl") for ii in url_list if handle_keys(ii, "contentUrl") != nothing]
    else
        urls = []
    end
    urls
end

function data_fullname(::JSONLD, mainpage)
    mainpage["name"]
end

function website(::JSONLD, mainpage_url, mainpage)
    mainpage_url
end
