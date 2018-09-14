
function generate(repo::DataRepo, dataname; kwargs...)
    generate([repo], dataname; kwargs...)
end

function generate(dataname; kwargs...)
    all_repos = [T() for T in leaf_subtypes(DataRepo)]
    generate(all_repos, dataname; kwargs...)
end


function generate(repos::Vector, dataname; shortname = nothing, show_failures=false)
    retrieved_metadatas_ch = Channel{Any}(128)
    failures = Channel{Tuple{DataRepo, Exception}}(128)
    
    # Get all the metadata we can
    for repo in repos
        try
            metadata = find_metadata(repo, dataname, shortname)
            push!(retrieved_metadatas_ch, metadata)
        catch err
            push!(failures, (repo, err))
        end
    end
    close(retrieved_metadatas_ch)
    close(failures)
    
    retrieved_metadatas = collect(retrieved_metadatas_ch)
    # Display errors if required
    if length(retrieved_metadatas) == 0 || show_failures
        for (repo, err) in failures
            println(repo, " failed due to")
            println(err)
            println()
        end
    end
    
    # merge them
    aggregate(retrieved_metadatas)
end





function find_metadata(repo, dataname, shortname)
    mainpage, url = mainpage_url(repo, dataname)
    fullname = data_fullname(repo, mainpage)
    shortname = data_shortname(repo, shortname, fullname)

    Metadata(
        shortname,
        fullname,
        website(repo, url, mainpage),
        description(repo, mainpage),
        author(repo, mainpage),
        maintainer(repo, mainpage),
        license(repo, mainpage),
        published_date(repo, mainpage),
        create_date(repo, mainpage),
        modified_date(repo, mainpage),
        paper_cite(repo, mainpage),
        dataset_cite(repo, mainpage),
        get_urls(repo, mainpage),
        get_checksums(repo, mainpage)
    )
end

function data_shortname(repo, shortname::Void, fullname)
    # Remove any characters not allowed in a file path
    reduce((s,r)->replace(s, r, ""), fullname, ['\\', '/', ':', '*', '?', '<', '>', '|'])
end

data_shortname(repo, shortname, fullname) = shortname

website(::DataRepo, url, mainpage) = url
description(::DataRepo, mainpage) = missing
author(::DataRepo, mainpage) = missing
maintainer(::DataRepo, mainpage) = missing
license(::DataRepo, mainpage) = missing
published_date(::DataRepo, mainpage) = missing
create_date(::DataRepo, mainpage) = missing
modified_date(::DataRepo, mainpage) = missing
paper_cite(::DataRepo, mainpage) = missing
dataset_cite(::DataRepo, mainpage) = missing
get_checksums(::DataRepo, mainpage) = missing
get_urls(::DataRepo, mainpage) = missing



function mainpage_url(repo::DataRepo, dataname)
    if startswith(dataname, "http")
        url = dataname
        #TODO: This isn't going to take https/http differences.
        dataname = first(split(replace(url, base_url(repo), ""), "/"))
    else # not a URL
        url = joinpath(base_url(repo), dataname)
    end
    getpage(url), url
end

