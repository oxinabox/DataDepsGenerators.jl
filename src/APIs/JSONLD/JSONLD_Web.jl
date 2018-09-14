struct JSONLD_Web <: JSONLD end

function mainpage_url(repo::JSONLD_Web, dataname)
    page=getpage(dataname)
    pattern = sel"script[type=\"application/ld+json\"]"
    jsonld_blocks = eachmatch(pattern, page.root)
    if length(jsonld_blocks)==0
        throw(GeneratorError(repo, "No JSON-LD Linked Data Found"))
    end
    @assert length(jsonld_blocks)==1
    script_block = text_only(first(jsonld_blocks))
    json = JSON.parse(script_block)
    return json, dataname
end
