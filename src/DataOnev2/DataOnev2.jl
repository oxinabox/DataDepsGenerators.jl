abstract type DataOneV2 <: DataRepo end

export KNB
include("KNB.jl")

function description(repo::DataOneV2, mainpage)
    desc = desc_(repo, mainpage)
    authors = authors_(repo, mainpage)
    author = format_authors(authors)
    license = license_(repo, mainpage)
    year, date = pubDate(repo, mainpage)
    # references = ""
    # paper = join(authors, ", ") * " ($(year)) " * data_fullname(repo, mainpage) * " " * references

    final = escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite the website (and DOI) noted above if you use this in your research.
    """, "\$")
end

get_urls(repo::DataOneV2, page) = []

function data_fullname(::DataOneV2, mainpage)
    text_only(first(matchall(sel"description title", mainpage.root)))
end

function pubDate(repo::DataOneV2, mainpage)
    date_ele = matchall(sel"pubDate", mainpage.root)
    if length(date_ele) > 0
        rawdate = Dates.Date(text_only(first(date_ele)), "yyyy-mm-dd")
        Dates.year(rawdate), Dates.format(rawdate, "U d, yyyy")
    else
        "", ""
    end
end

function authors_(repo::DataOneV2, mainpage)
    author_ele = matchall(sel"individualName", mainpage.root)
    if length(author_ele)> 0
        [text_only(i) for i in author_ele if contains(string(i.parent), "creator")]
    else
        []
    end
end

function license_(repo::DataOneV2, mainpage)
    license_ele = matchall(sel"intellectualRights", mainpage.root)
    if length(license_ele) > 0
        text_only(first(license_ele))
    else
        ""
    end
end

function desc_(repo::DataOneV2, mainpage)
    desc_ele = matchall(sel"description para", mainpage.root)
    if length(desc_ele) > 0
        text_only(first(desc_ele))
    else
        ""
    end
end