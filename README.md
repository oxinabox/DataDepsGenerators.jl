# DataDepsGenerators
Travis CI Master: [![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDepsGenerators.jl)
AppVeyor Master: [![Build status](https://ci.appveyor.com/api/projects/status/2q9u3a961j438aq9/branch/master?svg=true)](https://ci.appveyor.com/project/oxinabox/datadepsgenerators-jl/branch/master)
[![JOSS status](http://joss.theoj.org/papers/f52340014957dc0e74d5935162221c29/status.svg)](http://joss.theoj.org/papers/f52340014957dc0e74d5935162221c29)

**Generating registration blocks for [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl) in one key press.**
An example of use [is in this blog-post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html#example-3-538-avenegers-comic-book-characters--datadepsgeneratorsjl)

DataDepsGenerators.jl is a tool written to help users of the Julia programming language
to observe best practices when making use of published datasets.
Using the metadata present in published datasets, it generates the code for the data dependency registration blocks required by DataDeps.jl [@2018arXiv180801091W].
These registration blocks are effectively executable metadata,
which can be resolved by DataDeps.jl to download the dataset.
They include a message that is displayed to the user whenever the data set is automatically downloaded.
This message should include provenance information on the dataset,
so that downstream users know its original source and details on its processing.



This package should not be used as a direct dependency.
Instead its interactive features should be used from the Julia REPL,
to generate a good registration code block
which can be added to your package.

The registration block can be immediately evaluated using `eval(Meta.parse(generate(...)))`
which is handy for interactive prototyping,
it is not great to put this code in a package packages;
as it involves triggering web requests every time the package is loaded.
Not to mention DataDepsGenerators.jl has a pretty heavy set of dependencies,
that you don't really want weighing down your package.


**Note:** DataDepsGenerators does it's best to generate the correct registration code block.
But it is up to you make sure it is right.
The code it generates isn't always the cleanest.
It may capture too much, or too little information.
It might get things wrong (particularly when the metadata retrieved is wrong).
You should take a few moments to check you are happy with the registration block code generated.
Make a few tweaks, and it should be good to go.


## Usage

All usage revolves around the `generate` command. `generate()` is an overloaded method with two ways of usage:

### Normal Usage:
The normal way to use the package is to use the the one or two argument form.

```julia
generate(id_or_url, [datadep_name])::String
```

- `id_or_url` an identifier for the dataset that we can use to look up the metadata on.
	 - In general copy and pasting the URL of a  web-page describing the dataset works.
	 - A DOI also works, as does some internal identifiers of particular repositories.
	 - If you don't get good results it may be worth trying a few different pages on the site 
	 - Feel encouraged to raise an issue on this repo documenting your experience we may need to tweak some of our heuristics.
 - `datadep_name` is an optional argument, this is what to use as the name of the datadep
     - i.e. if you put `"Foo"`, when you use the datadep in your code, you'll write `datadep"Foo"`
     - if you skip it, DataDepsGenerators will generate a name from the page, though it is often very long.
     - you can always edit the resulting code anyway

 - This returns a `String` containing the generated DataDeps registration block
	 - `diplay`ing it in the REPL will show it as full of escape characters.
     - If it is `print`ed or written to file, it will be the understandable julia code you expect.

	 
Example of use:
```julia
generate("https://datadryad.org/resource/doi:10.5061/dryad.74699", "Wettberg 2018,  important crop's wild relatives")
```
	 
Using this non-repository specific generate command causes DataDepGenerators
to query all repositories and metadata sources about this `id_or_url`.
Often more than one succeeds, since for example the data may have both a record in a DOI register,
as well as being on a platform we support the API for,
and on a page that has an in-line JSONLD fragment.



### Specific Repo Usage

```julia
generate(datarepo::DataRepo, id_or_url, [datadep_name])::String
```

An extra argument needs to be provided to specify the data repository

 - the new first argument, `datarepo` is a data repository.
     - Basically this determines which generator to use.
     - this is an instance of the DataRepo type, like `GitHub()`, or `UCI()`
	 - See below for a list, with examples.


## Using the results:

### Write to file

To write the dependency block to a file, you just need to open the file (`"data.jl"` in this example) and write to it.

```julia
using DataDepsGenerators

open("data.jl", "w") do fh
  registation = generate("https://archive.ics.uci.edu/ml/datasets/Air+quality", "UCI Air"))
  print(fh, registation)
end
```

Then in your project to load the registration you can do:

```julia
using DataDeps

function __init__()
    include("data.jl")
end
```


### Output it to the screen

This is pretty easy:

```
println(generate(UCI(), "https://archive.ics.uci.edu/ml/datasets/Air+quality", "UCI Air"))
````

then copy and paste into your project.



### Interactive Use
While this isn't advise for use in packages -- since it throws away many of the benifits of using DataDeps, it can be done.
It is probably most useful in the REPL/IJulia.

```julia
using DataDeps
using DataDepsGenerators

eval(Meta.parse(generate(UCI(), "https://archive.ics.uci.edu/ml/datasets/Air+quality", "UCI Air"))
```

Then just use anywhere in your code (later in the REPL session for example)  `datadep"UCI Air"` as if it were the name of a directory holding that data.
(Which indeed what that string macro expands into -- even if it has to download the data first).

## Supported DataRepos 


### `CKAN()` - API Based

http://docs.ckan.org/en/2.8/

CKAN is primarily used by government organizations.

Data Repositories and examples of use:
* CKAN Demo API: `generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")`
* Data.gov: `generate(CKAN(), "https://catalog.data.gov/api/3/action/package_show?id=consumer-complaint-database")`
* Data.gov.au: `generate(CKAN(), "https://data.gov.au/api/3/action/package_show?id=2016-soe-atmosphere-hourly-co-and-24h-pm2-5-concentrations-measured-during-the-hazelwood-mine-fire")`

### `DataCite()` - API Based

https://www.datacite.org/

DataCite is the largest providers of DOI for things other than papers, especially for data.

Example of use:
```julia
    generate(DataCite(), "10.5063/F1HT2M7Q")
    generate(DataCite(), "https://search.datacite.org/works/10.15148/0e999ffc-e220-41ac-ac85-76e92ecd0320")
```

Either URL or DOI can be provided as arguments.

DataCite can not generate complete and usable registration blocks on its own,
as it does not include the download URLs.

### `DataDryad()` - Web Based

https://datadryad.org

DataDryad is one of the bigger research data stores.
Almost all the data in it is directly linked to one paper or another.

Example of use:
```julia
    generate(DataDryad(), "https://datadryad.org/resource/doi:10.5061/dryad.74699", "Wild Crop Genomics")
```


### `DataOneV1()` - API Based

https://releases.dataone.org/online/api-documentation-v1.2.0/

Data repositories like DataDryad, support version 1 API of the DataOne. 

Data Repositories:
* DataDryad: `generate(DataOneV1(), "https://datadryad.org/resource/doi:10.5061/dryad.74699", "Wild Crop Genomics")`



### `DataOneV2`

https://releases.dataone.org/online/api-documentation-v2.0/apis/index.html

Supports DataOne API version 2. There are differences in the API structure in each of them, hence are accounted for, separately:

Data Repositories:
* Knowledge Network for Biocomplexity `KnowledgeNetworkforBiocomplexity()`: `generate(KnowledgeNetworkforBiocomplexity(), "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/doi:10.5063/F1T43R7N")`
* Arctic Data Center `ArcticDataCenter()`: `generate(ArcticDataCenter(), "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/doi:10.5063%2FF1HT2M7Q")`
* Terrestrial Ecosystem Research Network `TERN()`: `generate(TERN(), "https://dataone.tern.org.au/mn/v2/object/aekos.org.au/collection/nsw.gov.au/nsw_atlas/vis_flora_module/KAHDRAIN.20150515")`


 
 
### `GitHub()` - Web Based
 https://github.com

Notable Datasets:
 - the folders with-in https://github.com/fivethirtyeight/data
 - The repositories in https://github.com/BuzzFeedNews ([index page](https://github.com/BuzzFeedNews/everything))
 - Everything from https://github.com/collections/open-data
 
 
Note that storing data in GitHub is generally not great particularly for large binary data.
However, a fair few datasets are stored there anyway.
A lot of these are plain-text and small files so it works out ok enough.

The generator for GitHub works on whole repositories, or on folders within repositories.
When downloading whole repositories, your other option would be to download a `zip` or `tarball` which GitHub provides; rather than generating a datadep with datadep generators which will result in downloading each file separately.
You could even manipulate DataDeps into doing a `git clone`.

Note GitHub does not like being used as a CDN.
For this reason DataDepsGenerators generates URLs to http://cdn.rawgit.com which is a CDN wrapper over GitHub, so you won't thrash github's servers.
Also note that the DataDepGenerator will produce URLs pointing to the current commit.
So the if the repository is updated, the DataDep will still download the old data.
(This is a feature).

At present, we do not support generating for any branch's other than master.
Though it is a simple matter to do a find and replace for the commit SHAs in the generated code so as to point at any commit.


### `Figshare()` - API Based

https://figshare.com/

FigShare is a popular website for sharing figures and data.

Example of use:
```julia
    generate(Figshare(), "10.5281/zenodo.1194927")
    generate(Figshare(), "https://figshare.com/articles/Youth_Activism_in_Chile_from_urban_educational_inequalities_to_experiences_of_living_together_and_solidarity/6504206")
```

A URL, DOI or Figshare ID can be provided as arguments.


### `JSONLD_DOI()` - API Based

https://data.datacite.org/

This uses a DataCite json-ld service to retrieve the metadata for CrossRef or DataCite issues DOIs.
Like the DataCite generate this can not usually generate complete registration blocks as the API does not include the download URLs.

Example of use:
```julia
    generate(JSONLD_DOI(), "10.1371/journal.pbio.2001414")
```

### `JSONLD_Web()` - Web Based

https://json-ld.org/

A lot of data hosting websites like Kaggle, Zenodo, Dataverse etc (including several with their own generators)
store information in the form of JSON-LD `<script>` fragments embedding in the HTML webpages.
It is used by [Google Dataset search engine](https://toolbox.google.com/datasetsearch) too,
so any result from Google Dataset search should work out of the box with DataDepGenerators.
The completeness of the information in the JSON-LD fragment varies depending on the site.
So this may generate incomplete registration blocks, e.g. with the download URL missing.


Example of use:
```julia
    generate(JSONLD_Web(), "https://www.kaggle.com/stackoverflow/stack-overflow-2018-developer-survey")
```


### `UCI()` - Web Based
 https://archive.ics.uci.edu/ml/datasets
 
A fairly classic repository for (mostly) small Machine Learning datasets
This uses webscraping, and since it is a hand written website it is not perfectly consistently written or formatted,
thus the registrations can be a bit choppy and may e.g. contain links that should have been removed etc.
 
    
