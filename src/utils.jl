

"""
    getpage(url)

downloads and parses the page from the URL
"""
getpage(url) = parsehtml(readstring(download(url)))


"""
    text_only(doc)

Extracts just the unformatted text (no attributes etc),
from a HTML document or fragment(/s)
"""
text_only(doc::HTMLDocument) = text_only(doc.root)
text_only(frag) = join([replace(text(leaf), "\r","") for leaf in Leaves(frag) if leaf isa HTMLText], " ")
text_only(frags::Vector) = join(text_only.(frags), " ")


"
    indent(str)

Indents each line in a string
"
indent(str, indentwith="\t") = join(indentwith.*split(str, "\n"),"\n")


Base.escape_string(s::AbstractString, esc::AbstractString) = sprint(endof(s), escape_string, s, esc*"\"")

"""
    escape_multiline_string

like Escape string, but does not escape newlines
"""
function escape_multiline_string(s::AbstractString, esc::AbstractString)
    escaped = escape_string(s, esc)
    replace(escaped, "\\n", "\n")
end
