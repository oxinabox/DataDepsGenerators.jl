immutable GitHub <: DataRepo
end

base_url(::GitHub) = "https://github.com"

git_repo_page_url(page) = base_url(GitHub()) * getattr(first(matchall(sel"strong[itemprop=\"name\"] a", page.root)), "href")

function description(::GitHub, mainpage)
    # Just load the readme -- it is all that we can do as this level of generic
    get_docfile(GitHub(), mainpage, "README") * "\n\n" *
    get_docfile(GitHub(), mainpage, "LICENSE")    
end

function get_docfile(::GitHub, page, docname)
    function inner(page)
        nodes = matchall(Selector(".content span a :contains($(docname))"), page.root)
        if length(nodes)>0
            node = first(nodes)
            url = "https://rawgit.com" * getattr(node.parent, "href")
            url = replace(url, "blob/", "")
            String(read(quiet_download(url)))
        else
            ""
        end
    end
    
    doc = inner(page)
    if doc==""
        doc = inner(getpage(git_repo_page_url(page))) # Try the base dir of the repository
    end
    doc
end

function get_readme(::GitHub, mainpage)
end

function get_license(::GitHub, mainpage)
end


function get_cdn_url_converter(mainpage)
    commit_ele = matchall(sel".commit-tease", mainpage.root)[1]
    commit = match(r"\b[0-9a-f]{5,40}\b", commit_ele.attributes["src"])
    function(urlsub)
        ret = "https://cdn.rawgit.com"*urlsub
        if commit === nothing
            warn("Not able to retrieve commit hash. Switching to master.")
            rep_string = "master"
        else
            rep_string = commit.match
        end
        replace(ret, "blob/master", rep_string)
    end
end


function get_urls(repo::GitHub, page, cdn_url_converter=get_cdn_url_converter(page))
    links = matchall(sel".content span a", page.root)
    urls = Any[]
    for link in links
        urlsub =  getattr(link, "href")
        github_url = base_url(repo) * urlsub
        if contains(getattr(link.parent.parent.parent[1][1], "class"), "directory") # is a dirctory
            push!(urls, get_urls(repo, getpage(github_url), cdn_url_converter)) # making a list of lists
        else # it is a file
            push!(urls, cdn_url_converter(urlsub))
        end
        
    end
    urls
end

function get_checksums(repo::GitHub, page)
    checksums = []
    checksums
end

function data_fullname(::GitHub, mainpage)
    text_only(last(matchall(sel"h1", mainpage.root)))
end
