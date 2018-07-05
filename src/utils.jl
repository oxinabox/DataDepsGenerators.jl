
quiet_download(url) = @suppress(download(url))

"""
    getpage(url)

downloads and parses the page from the URL
"""
getpage(url) = parsehtml(String(read(quiet_download(url))))

# function parsehtml(junk::String)
#     println(junk)
#     ""
# end

"""
    text_only(doc)

Extracts just the unformatted text (no attributes etc),
from a HTML document or fragment(/s)
"""
text_only(doc::HTMLDocument) = text_only(doc.root)
text_only(frag) = join([replace(text(leaf), "\r","") for leaf in Leaves(frag) if leaf isa HTMLText], " ")
text_only(frags::Vector) = join(text_only.(frags), " ")

function filter_html(random)
    if random isa Void
        return ""
    end
    if ismatch(r"<(\"[^\"]*\"|'[^']*'|[^'\">])*>", random)
        return text_only(parsehtml(random))
    end
    return random
end

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
    escaped = replace(escaped, '\$', raw"\$")
    escaped = replace(escaped, '\\', raw"\\")
    escaped
end
