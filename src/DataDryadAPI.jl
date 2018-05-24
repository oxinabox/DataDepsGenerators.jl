immutable DataDryadAPI <: DataRepo
end

base_url(::DataDryadAPI) = "https://datadryad.org/mn/object/http://dx.doi.org/"

function description(repo::DataDryadAPI, mainpage)
    desc = text_only(first(matchall(sel"dcterms\:description", mainpage.root)))
    authors = matchall(sel"dcterms\:creator", mainpage.root)
    author = text_only(first(authors))
    license = "http://creativecommons.org/publicdomain/zero/1.0/"
    rawdate = chop(text_only(first(matchall(sel"dcterms\:dateSubmitted", mainpage.root))))
    year = Dates.year(Dates.DateTime(rawdate))
    month = Dates.monthname(Dates.DateTime(rawdate))
    day = Dates.day(Dates.DateTime(rawdate))
    date = "$(month) $(day), $(year)"
    references = text_only(first(matchall(sel"dcterms\:references", mainpage.root)))
    paper = text_only(authors) * " ($(year)) " * data_fullname(repo, mainpage) * " " * references
    dataset = text_only(first(matchall(sel"dcterms\:identifier", mainpage.root)))

    final = escape_multiline_string("""
    Author: $(author) et. al.
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this paper:
    $(paper)
    as well as this dataset:
    $(dataset)
    if you use this in your research.
    """, "\$")
end

function get_urls(repo::DataDryadAPI, page)
    urls = []
    links = matchall(sel"dcterms\:hasPart", page.root)
    for link in links
        downloadlinks = matchall(sel".image-link", getpage(text_only(link)).root)
        for downloadlink in downloadlinks
            push!(urls, downloadlink.attributes["href"])
        end
    end
    urls
end

function get_checksums(repo::DataDryadAPI, page)
    checksums = []
    links = matchall(sel"dcterms\:hasPart", page.root)
    for link in links
        spans = matchall(sel".file-list span", getpage(text_only(link)).root)
        for span in spans
            if ismatch(r"^[a-f0-9]{32}$", text_only(span))
                push!(checksums, (:md5, text_only(span)))
            end
        end
    end
    if length(checksums) > 0
        info("The generated registration block uses md5 hash, " *
            "the MD5.jl package must be loaded to run the registration")
    end
    checksums
end

function data_fullname(::DataDryadAPI, mainpage)
    text_only(first(matchall(sel"dcterms\:title", mainpage.root)))
end