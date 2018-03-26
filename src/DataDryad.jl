immutable DataDryad <: DataRepo
end

base_url(::DataDryad) = "https://datadryad.org/mn/"

function description(::DataDryad, mainpage)
    desc = replace(text_only(first(matchall(sel".article-abstract", mainpage.root))), "Abstract ", "")
    author = ""
    try
        author = text_only(first(matchall(sel".pub-authors a", mainpage.root)))
    catch
        author = string(split(text_only(first(matchall(sel".pub-authors", mainpage.root))), ", ")[1])
    end
    license = getattr(first(matchall(sel".single-image-link", mainpage.root)), "href")
    dateelem = matchall(sel".publication-header p", mainpage.root)
    date = replace(text_only(dateelem[length(dateelem)-1]), "Date Published: ", "")
    paper = text_only(first(matchall(sel".citation-sample", mainpage.root)))
    dataset = replace(text_only(last(matchall(sel".publication-header p", mainpage.root))), "DOI: ", "")

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

function get_urls(repo::DataDryad, page)
    urls = []
    links = matchall(sel".package-file-description tbody tr td a", page.root)
    for link in links
        urlhref = getattr(link, "href")
        dryadurl = "https://datadryad.org" * string(urlhref)
        if contains(string(link.parent.parent), "Download")
            push!(urls, dryadurl)
        end
    end
    # download_url = replace(paper, "DOI: https://", "https://datadryad.org/mn/object/http://dx.") * "/1/bitstream"

    # md5 = ("md5", text_only(getpage(replace(paper, "DOI: https://doi.org/", "https://datadryad.org/mn/checksum/doi:") * "/1").root))
    # push!(urls, md5)
    urls
end

function data_fullname(::DataDryad, mainpage)
    # mainpage = replace(mainpage, "resource", "mn/object")
    text_only(first(matchall(sel".pub-title", mainpage.root)))
end
