struct DataOneV1 <: DataRepo
end

# The only APIs known to be supported by DataOne Version 1 is DataDryad
# As and when we come to know of other APIs supported by DataOne, more abstraction layers will be introduced.
# Named as DataOneV1 to make new contributors to the package aware that DataOneV1 exists.
base_url(::DataOneV1) = "https://datadryad.org/mn/object/http://dx.doi.org/"

description(repo::DataOneV1, mainpage) = text_only(first(eachmatch(sel"dcterms\:description", mainpage.root)))

author(::DataOneV1, mainpage) = [text_only(i) for i in eachmatch(sel"dcterms\:creator", mainpage.root)]

license(::DataOneV1, mainpage) = "http://creativecommons.org/publicdomain/zero/1.0/"

published_date(::DataOneV1, mainpage) = Dates.DateTime(chop(text_only(first(eachmatch(sel"dcterms\:dateSubmitted", mainpage.root)))))

paper_cite(::DataOneV1, mainpage) = citation_text(text_only(first(eachmatch(sel"dcterms\:references", mainpage.root))))

dataset_cite(::DataOneV1, mainpage) = citation_text(text_only(first(eachmatch(sel"dcterms\:identifier", mainpage.root))))

function get_urls(repo::DataOneV1, page)
    urls = []
    links = eachmatch(sel"dcterms\:hasPart", page.root)
    for link in links
        downloadlinks = eachmatch(sel".image-link", getpage(text_only(link)).root)
        for downloadlink in downloadlinks
            push!(urls, downloadlink.attributes["href"])
        end
    end
    urls
end

function get_checksums(repo::DataOneV1, page)
    checksums = []
    links = eachmatch(sel"dcterms\:hasPart", page.root)
    for link in links
        spans = eachmatch(sel".file-list span", getpage(text_only(link)).root)
        for span in spans
            if occursin(r"^[a-f0-9]{32}$", text_only(span))
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
    text_only(first(eachmatch(sel"dcterms\:title", mainpage.root)))
end

function website(::DataOneV1, mainpage_url, mainpage)
    replace(mainpage_url, "https://datadryad.org/mn/object/", "")
end
