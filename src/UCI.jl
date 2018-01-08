

immutable UCI <: DataRepo
end


function find_metadata(::UCI, dataname)
    base_url = "https://archive.ics.uci.edu/ml/datasets/"
    mainpage_url = joinpath(base_url, dataname)
    mainpage = getpage(mainpage_url)

    datapage_link = first(matchall(sel"tr tr a", mainpage.root))
    datapage_url = joinpath(base_url, attrs(datapage_link)["href"])

    data_urls = get_dataurls_from_webserver_index(datapage_url)



    Metadata(
        data_fullname(UCI(), mainpage),
        mainpage_url,
        to_cite(UCI(), mainpage),
        description(UCI(), mainpage),
        data_urls
    )

end

function to_cite(::UCI, mainpage)
    repo  = ["Lichman, M. (2013). UCI Machine Learning Repository [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, School of Information and Computer Science."]
    papers = try
        paper = text_only(first(Gumbo.children(last(matchall(sel"p + p.normal", mainpage.root)))))
        if !startswith(paper, "Please refer to")
            [paper]
        else
            String[]
        end
    catch ex #if not found then throws bounds error
        ex isa BoundsError || rethrow(ex)
        String[]
    end
    [papers; repo]
end

function description(::UCI, mainpage)
    text_only(first(matchall(sel"p.normal", mainpage.root)))
end

function data_fullname(::UCI, mainpage)
    data_fullname = text_only(matchall(sel".heading b", mainpage.root))
    data_fullname*= " (UCI ML Repository)"
end
