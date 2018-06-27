abstract type DataOneV2 <: DataRepo end

export KNB, TERN
include("KNB.jl")
include("TERN.jl")

function description(repo::DataOneV2, mainpage)
    desc = desc_(repo, mainpage)
    paper_title = paper_title_(repo, mainpage)
    authors = authors_(repo, mainpage)
    author = format_authors(authors)
    license = license_(repo, mainpage)
    year, date = pub_date(repo, mainpage)
    # references = ""
    # paper = join(authors, ", ") * " ($(year)) " * data_fullname(repo, mainpage) * " " * references

    final = escape_multiline_string("""
    Paper Title: $(paper_title)
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this work appropriately if you use it in your research.
    """, "\$")
end

get_urls(repo::DataOneV2, page) = []

function license_(repo::DataOneV2, mainpage)
    license_ele = matchall(sel"intellectualRights", mainpage.root)
    if length(license_ele) > 0
        text_only(first(license_ele))
    else
        ""
    end
end

function paper_title_(repo::DataOneV2, mainpage)
    paper_title_ele = matchall(sel"title", mainpage.root)
    if length(paper_title_ele) > 0
        text_only(first(paper_title_ele))
    else
        ""
    end
end
