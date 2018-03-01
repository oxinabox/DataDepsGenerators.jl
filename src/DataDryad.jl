immutable DataDryad <: DataRepo
end

base_url(::DataDryad) = "https://datadryad.org/mn/"

function description(::DataDryad, mainpage)
    desc = replace(text_only(first(matchall(sel".article-abstract", mainpage.root))), "Abstract ", "")
    author = text_only(first(matchall(sel".pub-authors a", mainpage.root)))
    license = getattr(first(matchall(sel".single-image-link", mainpage.root)), "href")
    date = now()
    paper = text_only(first(matchall(sel".citation-sample a", mainpage.root)))
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
    paper = text_only(last(matchall(sel".publication-header p", page.root)))
    download_url = replace(paper, "DOI: https://", "https://datadryad.org/mn/object/http://dx.") * "/1/bitstream"
    push!(urls, download_url)
    md5 = ("md5", text_only(getpage(replace(paper, "DOI: https://doi.org/", "https://datadryad.org/mn/checksum/doi:") * "/1").root))
    push!(urls, md5)
    urls
end

function data_fullname(::DataDryad, mainpage)
    # mainpage = replace(mainpage, "resource", "mn/object")
    text_only(first(matchall(sel".pub-title", mainpage.root)))
end
