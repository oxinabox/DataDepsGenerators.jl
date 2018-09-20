const Opt{T} = Union{Missing, T}
struct Metadata
    shortname::Opt{String}
    fullname::Opt{String}
    website::Opt{String}
    description::Opt{String}
    author::Opt{Vector{String}}
    maintainer::Opt{String}
    license::Opt{String}
    published_date::Opt{Union{Date, DateTime,String}}
    create_date::Opt{Union{Date, DateTime,String}}
    modified_date::Opt{Union{Date, DateTime,String}}
    paper_cite::Opt{String}
    dataset_cite::Opt{String}
    dataurls::Opt{Vector}
    datachecksums::Any
end


"""
    aggregate(metadatas)

Given a collection of `Metadata` from differenct sources,
combined them to create the most complete and detailed accounting of metadata.
"""
function aggregate(metadatas)
    Metadata(
        combine_all(metadatas, :shortname),
        combine_all(metadatas, :fullname),
        combine_all(metadatas, :website),
        combine_all(metadatas, :description),
        combine_all(metadatas, :author),
        combine_all(metadatas, :maintainer),
        combine_all(metadatas, :license),
        combine_all(metadatas, :published_date),
        combine_all(metadatas, :create_date),
        combine_all(metadatas, :modified_date),
        combine_all(metadatas, :paper_cite),
        combine_all(metadatas, :dataset_cite),
        combine_all(metadatas, :dataurls),
        combine_all(metadatas, :datachecksums),
    )
end


function combine_all(metadatas::Vector, field::Symbol)
    ret = missing
    for value in getfield.(metadatas, Ref(field))
        ret = combine(ret, value, Val{field})
    end
    ret
end

# ====dispatch based on Value of fieldname ====

combine(::Missing, ::Missing, ::Any) = missing
combine(::Missing, x, ::Any) = x
combine(x, ::Missing, ::Any) = x

combine(x::Vector, y::Vector, ::Any) = tblength(x) > tblength(y) ? x : y

combine(x::AbstractString, y::AbstractString, ::Any) = tblength(x) > tblength(y) ? x : y

# Shorter is better for lisences as is is likely a human readble name or a URL, rather than the full text.
combine(x::AbstractString, y::AbstractString, ::Val{:license}) = length(x) > 0 && tblength(x) < tblength(y) ? x : y

combine(x::Union{DateTime, Date}, y::AbstractString, ::Any) = x
combine(x::AbstractString, y::Union{DateTime, Date}, ::Any) = y


#Tie-Breaking length: Returns a tuple, that will break ties on things of equal lengths)"
tblength(x) = (length(x), hash(x))

