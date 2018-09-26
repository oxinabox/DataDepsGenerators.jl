
"""
    lift(func, arg)
Calls `func(arg)`, propagating `missing` values
"""
lift(func, ::Missing)=missing
lift(func, arg) = func(arg)


miss_null(::Nothing) = missing
miss_null(x) = x


"""
    getfirst(dict, keys...)

Returns the element coresponding to the first key that is found.
Returns `missing` if no key is found.
"""
function getfirst(json, key, otherkeys...)
    get(json,  key) do
        getfirst(json, otherkeys...)
    end
end
getfirst(json) = missing

###############################
"""
    getpage_raw(url)

Downloads the page from the URL,
returning the raw (unparsed) text of the body.
"""
getpage_raw(url) = String(HTTP.request("GET", url).body)


"""
    getpage(url)

downloads and parses the page from the URL
"""
const getpage = parsehtml ∘ getpage_raw

###

"""
    text_only(doc)

Extracts just the unformatted text (no attributes etc),
from a HTML document or fragment(/s)
"""
text_only(doc::HTMLDocument) = text_only(doc.root)
text_only(frag) = join([replace(text(leaf), "\r" => "") for leaf in Leaves(frag) if leaf isa HTMLText], " ")
text_only(frags::Vector) = join(text_only.(frags), " ")


"""
    filter_html(text)

Strips any HTML tags out of the `text`.
If that is required.
"""
function filter_html(text)
    # Check if the text is a HTML or not
    # Note we are not parsing it, just checking if we should parse it
    if occursin(r"<(\"[^\"]*\"|'[^']*'|[^'\">])*>", text)
        # It seems like it may be HTML, so now parse it.
        text_only(parsehtml(text))
	else
    	text
    end
end

filter_html(::Missing) = missing



###########

"
    indent(str)

Indents each line in a string
"
indent(str, indentwith="\t") = join(indentwith.*strip.(split(str, "\n")), "\n")


"""
    escape_multiline_string

like Escape string, but does not escape newlines
"""
function escape_multiline_string(s::AbstractString)
    escaped = s
    escaped = replace(escaped, '\$' => raw"\$")
    escaped = replace(escaped, '\\' =>  raw"\\")
    escaped
end

function remove_cite_version(code)
    replace(code, r"\(Version \d+\) " => "")
end

"""
    leaf_subtypes(T)
Returns all the nonabstract types decedent from `T`.
"""
function leaf_subtypes(T)
       if isconcretetype(T)
           T
       else
           vcat(leaf_subtypes.(subtypes(T))...)
       end
end

##############################################

"""
	match_doi(uri::String
"""
function match_doi(uri::String)
    identifier_match = match(r"\b(10[.][0-9]{4,}(?:[.][0-9]+)*\/(?:(?![\"&\'<>])\S)+)\b", uri)
    identifier_match === nothing ? nothing : identifier_match.match
end

