abstract type DataOnev2 <: DataRepo end

export KNB
include("KNB.jl")

function description(repo::DataOnev2, mainpage)
    desc = try text_only(matchall(sel"description para", mainpage.root)) catch "" end
    authors = try [text_only(i) for i in matchall(sel"individualName", mainpage.root) if contains(string(i.parent), "creator")] catch [] end
    author = format_authors(authors)
    license = try text_only(first(matchall(sel"intellectualRights", mainpage.root))) catch "" end
    rawdate = try Dates.Date((text_only(first(matchall(sel"pubDate", mainpage.root)))), "yyyy-mm-dd") catch "" end
    year = try Dates.year(rawdate) catch "" end
    date = try Dates.format(rawdate, "U d, yyyy") catch "" end
    references = ""
    paper = join(authors, ", ") * " ($(year)) " * data_fullname(repo, mainpage) * " " * references

    final = escape_multiline_string("""
    Author: $(author)
    License: $(license)
    Date: $(date)

    $(desc)

    Please cite this paper:
    $(paper)
    as well as the website noted above if you use this in your research.
    """, "\$")
end

get_urls(repo::DataOnev2, page) = []

function data_fullname(::DataOnev2, mainpage)
    text_only(first(matchall(sel"description title", mainpage.root)))
end