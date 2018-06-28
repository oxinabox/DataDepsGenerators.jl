immutable DataOneV1 <: DataRepo
end

# The only APIs known to be supported by DataOne Version 1 is DataDryad
# As and when we come to know of other APIs supported by DataOne, more abstraction layers will be introduced.
# Named as DataOneV1 to make new contributors to the package aware that DataOneV1 exists.
base_url(::DataOneV1) = "https://datadryad.org/mn/object/http://dx.doi.org/"

function description(repo::DataOneV1, mainpage)
    desc = text_only(first(matchall(sel"dcterms\:description", mainpage.root)))
    authors = matchall(sel"dcterms\:creator", mainpage.root)
    author = format_authors([text_only(i) for i in authors])
    license = "http://creativecommons.org/publicdomain/zero/1.0/"
    rawdate = Dates.DateTime(chop(text_only(first(matchall(sel"dcterms\:dateSubmitted", mainpage.root)))))
    year = Dates.year(rawdate)
    date = Dates.format(rawdate, "U d, yyyy")
    references_ref = text_only(first(matchall(sel"dcterms\:references", mainpage.root)))
    paper_cite = citation_text(references_ref)
    dataset_ref = text_only(first(matchall(sel"dcterms\:identifier", mainpage.root)))
    dataset_cite = citation_text(dataset_ref)

    """
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this paper:
    $(paper_cite)
    as well as this dataset:
    $(dataset_cite)
    if you use this in your research.
    """
end

function get_urls(repo::DataOneV1, page)
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

function get_checksums(repo::DataOneV1, page)
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

function data_fullname(::DataOneV1, mainpage)
    text_only(first(matchall(sel"dcterms\:title", mainpage.root)))
end

function website(::DataOneV1, mainpage_url, mainpage)
    replace(mainpage_url, "https://datadryad.org/mn/object/", "")
end
