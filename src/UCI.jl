

immutable UCI <: DataRepo
end


base_url(::UCI) = "https://archive.ics.uci.edu/ml/datasets/"


function to_cite(::UCI, mainpage)
    section = text_only(Gumbo.children(last(matchall(sel"p + p.normal", mainpage.root))))

    section = replace(section, "Available at: \n[Web Link]", "")
    section = replace(section, r"\(?\s*\[Web Link\]\s*\)?","")
    section *= "\nLichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, School of Information and Computer Science."

    replace(section, r"\n+","\n")
end

function description(::UCI, mainpage)
    desc =  text_only(first(matchall(sel"p.normal", mainpage.root)))
    desc * "\n\n" *  to_cite(UCI(), mainpage)
end

function data_fullname(::UCI, mainpage)
    data_fullname = text_only(matchall(sel".heading b", mainpage.root))
    data_fullname*= " (UCI ML Repository)"
end

function get_urls(::UCI, mainpage)
    datapage_link = first(matchall(sel"tr tr a", mainpage.root))
    datapage_url = joinpath(base_url(UCI()), attrs(datapage_link)["href"])

    data_urls = get_dataurls_from_webserver_index(datapage_url)
end

function get_checksums(::UCI, page)
    checksums = nothing
    checksums
end
