abstract type JSONLD <: DataRepo
end

export JSONLD_Web, JSONLD_DOI

include("JSONLD_Web.jl")
include("JSONLD_DOI.jl")

description(repo::JSONLD, mainpage) = filter_html(handle_keys(mainpage, "description"))

author(repo::JSONLD, mainpage) = get_authors(repo, mainpage)

license(::JSONLD, mainpage) = filter_html(get_license(mainpage))

published_date(repo::JSONLD, mainpage) = get_dates(repo, mainpage)


function get_authors(repo::JSONLD, mainpage)
    inner(authors::Vector) = map(inner, authors)
    inner(::Missing) = missing
    inner(author::Dict) = handle_keys(author, "name")

    authors = handle_keys(mainpage, "author", "creator") |> inner
    if !(authors isa AbstractVector) # then there was just one
        return [authors]
    end
    authors
end

function get_dates(repo::JSONLD, mainpage)
    rawdate = handle_keys(mainpage, "datePublished", "dateCreated", "dateModified")
    # Dates can be like '2007' or '2016-12-20'. Need to account for all.
    try
        return Dates.format(Dates.DateTime(rawdate), "U d, yyyy")
    catch err
        if err isa MethodError ||  err isa ArgumentError
            # Method error occurs if rawdate==missing
            # Argument error can occur if it is a weirdly formatted string
            # Either way, it is probably alright
            return rawdate
        else
            rethrow()
        end
    end
end

function get_license(mainpage)
    license = handle_keys(mainpage, "license")
    if license isa Dict
        return handle_keys(license, "url", "text")
    end
    license # Returns Strings and Missings (and anything else)
end

handle_keys(json, key, otherkeys...) = get(json,  key) do
    handle_keys(json, otherkeys...)
end

handle_keys(json) = missing

function get_urls(repo::JSONLD, page)
    lift(handle_keys(page, "distribution")) do url_list
        urls = collect(skipmissing(handle_keys.(url_list, "contentUrl")))
    end
end

function data_fullname(::JSONLD, mainpage)
    mainpage["name"]
end

function website(::JSONLD, mainpage_url, mainpage)
    mainpage_url
end
