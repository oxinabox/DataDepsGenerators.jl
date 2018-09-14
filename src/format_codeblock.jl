function format_codeblock(meta)
    netString =  """
    register(DataDep(
        \"$(meta.shortname)\",
        \"\"\""""
    netString *= format_meta(meta.fullname, "Dataset")
    netString *= format_meta(meta.website, "Website")
    ## Start of the message
    netString *= format_meta(format_authors(meta.author), "Author")
    netString *= format_meta(meta.maintainer, "Maintainer")
    netString *= format_meta(format_dates(meta.published_date), "Date of Publication")
    netString *= format_meta(format_dates(meta.create_date), "Date of Creation")
    netString *= format_meta(format_dates(meta.modified_date), "Date of Last Modification")
    netString *= format_meta(meta.license, "License")
    netString *= "\n"
    netString *= format_meta(meta.description)
    netString *= format_meta(meta.paper_cite, "\nPlease cite this paper")
    netString *= format_meta(meta.dataset_cite, "\nPlease cite this dataset")
    netString *= "\n\t\"\"\","
    netString = netString |> strip
    ## End of the message
    netString *= format_meta(ismissing(meta.dataurls) ? "missing" : meta.dataurls)
    netString *= ","
    netString *= format_meta(format_checksums(meta.datachecksums))
    netString *= "\n))"

    netString
end

format_meta(::Missing, args...; kwargs...) = ""

function format_meta(data::Any, label="")
    if label != ""
        label*=": "
    end
    return "\n" * indent(label * string(data))
end
format_dates(rawdate) = rawdate #Catches the missing and the string
format_dates(rawdate::Dates.Date) = Dates.format(rawdate, "U d, yyyy")


function format_checksums(csums::Vector)
    csumvec = join(format_checksums.(csums), ", ")
    "[$csumvec]"
end

function format_checksums(csum::Tuple{T,<:AbstractString}) where T<:Symbol
    func = string(csum[1])
    hashstring = format_checksums(csum[2])
    "($func, $hashstring)"
end

format_checksums(::Missing) = missing

function format_checksums(csum::AbstractString)
    if length(csum)>0 "\"$csum\"" else "" end
end

format_authors(authors::Missing) = "Authors not specified"

format_authors(authors::AbstractString) = authors

function format_authors(authors::Vector)
    if length(authors) == 1
        authors[1]
    elseif length(authors) == 2
        authors[1] * ", " * authors[2]
    elseif length(authors) >2
        authors[1] * " et al."
    else
        warn("Not able to retrieve any authors")
        format_authors(missing)
    end
end

function format_papers(authors::Vector, year::String, name::String, link::String)
    #APA format. Other formats can be included here later.
    join(authors, ", ") * " ($year). " * name * " " * link
end

