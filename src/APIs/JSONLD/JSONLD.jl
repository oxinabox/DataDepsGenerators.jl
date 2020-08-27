abstract type JSONLD <: DataRepo
end

include("JSONLD_Web.jl")
include("JSONLD_DOI.jl")

data_fullname(::JSONLD, mainpage) = mainpage["name"]
website(::JSONLD, mainpage_url, mainpage) = mainpage_url
description(repo::JSONLD, mainpage) = filter_html(getfirst(mainpage, "description"))


function author(repo::JSONLD, mainpage)
    inner(authors::Vector) = map(inner, authors)
    inner(::Missing) = missing
    inner(author::Dict) = getfirst(author, "name")

    authors = getfirst(mainpage, "author", "creator") |> inner
    if !(authors isa AbstractVector) # then there was just one
        return [authors]
    end
    authors
end

function published_date(repo::JSONLD, mainpage)
    rawdate = getfirst(mainpage, "datePublished", "dateCreated", "dateModified")
    # Dates can be like '2007' or '2016-12-20'. Need to account for all.
    try
        return Dates.format(Dates.DateTime(rawdate), "U d, yyyy")
    catch err
        if err isa MethodError ||  err isa ArgumentError
            # `MethodError` occurs if `rawdate==missing`
            # `ArgumentError` can occur if it is a weirdly formatted string
            # Either way, it is probably alright
            return rawdate
        else
            rethrow()
        end
    end
end

function license(::JSONLD, mainpage)
    license = getfirst(mainpage, "license")
    if license isa Dict
        license = getfirst(license, "url", "text")
    end
    filter_html(license)
end


function get_urls(repo::JSONLD, page)
    lift(getfirst(page, "distribution")) do url_list
        if url_list isa AbstractDict  # sometimes it is just 1 dict.
            url_list = (url_list,)  # make it a collection
        end
        urls = collect(skipmissing(getfirst.(url_list, "contentUrl")))
    end
end


