
"""
    generate([repo/s], url/id, [shortname]; show_failures=false)

Generates a DataDeps code block.
The only required parameter is the url/id.

 - `url/id` The identifier for the dataset
     - a URL for a landing page is normally best
     - Other IDs like a DOIs also work.
 - `repo/s` either a single repository/API or a list of such
     - this takes on of the `DataRepo` types exported by this package.
         - E.g `CKAN()`, or `Figshare()`.
     - If not provided, this defaults to checking all of them.
     - If only one repo is provided, and it fails, the error will be thrown.
     - If multiple repos are provided, them the metadata from all of them is combined.
 - `shortname`, the name to use in the generated DataDep
     - if not provided will use the dataset's title, but these are often very long.
 - `show_failures`, weather or not to list all the `repos` that fail and why.
     - You generally do not want to turn this on, unless you are debugging.
     - It is fine and expected for most repos to fail (after all the data is probably only on one of them)
     - If *all* repos fail, then the failure list will be shown, regardless of if this is set or not.
"""
function generate(repo::DataRepo, dataname, shortname=nothing; kwargs...)
    metadata = find_metadata(repo, dataname, shortname)
    format_codeblock(metadata)
end

function generate(dataname, shortname=nothing; kwargs...)
    all_repos = [T() for T in leaf_subtypes(DataRepo)]
    generate(all_repos, dataname, shortname; kwargs...)
end


function generate(repos::Vector, dataname, shortname = nothing; show_failures=false)
    retrieved_metadatas_ch = Channel{Any}(128)
    failures_ch = Channel{Tuple{DataRepo, Exception}}(128)
    
    # Get all the metadata we can
    @sync for repo in repos
        @async try
            metadata = find_metadata(repo, dataname, shortname)
            push!(retrieved_metadatas_ch, metadata)
        catch err
            push!(failures_ch, (repo, err))
        end
    end
    close(retrieved_metadatas_ch)
    close(failures_ch)
    
    retrieved_metadatas = collect(retrieved_metadatas_ch)
    failures = collect(failures_ch)
    # ============ Handle errors ===========
    
    # Display errors
    if length(retrieved_metadatas) == 0 || show_failures
        for (repo, err) in failures
            @warn("$repo failed", exception=err)
        end
    end
    
    # ============= Produce final result ===========
    merged_metadata = aggregate(retrieved_metadatas)
    format_codeblock(merged_metadata)
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

function data_shortname(repo, shortname::Nothing, fullname)
    # Remove any characters not allowed in a file path
    reduce((s,r)->replace(s, r => ""), ['\\', '/', ':', '*', '?', '<', '>', '|']; init=fullname)
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
    else # not a URL
        url = joinpath(base_url(repo), dataname)
    end
    getpage(url), url
end

