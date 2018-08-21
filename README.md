# DataDepsGenerators
Travis CI Master: [![Build Status](https://travis-ci.org/oxinabox/DataDeps.jl.svg?branch=master)](https://travis-ci.org/oxinabox/DataDepsGenerators.jl)
AppVeyor Master: [![Build status](https://ci.appveyor.com/api/projects/status/2q9u3a961j438aq9/branch/master?svg=true)](https://ci.appveyor.com/project/oxinabox/datadepsgenerators-jl/branch/master)


**Generating registration blocks for [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl) in one key press.**

This package should not be used as a dependancy
Instead the interactive features of this package should be used from the Julia REPL,
to get a good registration block, which is output to a file (or STDOUT),
which can be added to your package.

While it can be used to directly create and invoke a registration,
this use handy for interactive and prototyping use,
but not great for packages, as it involves triggering a webscraper everytime the package is loaded.
Not to mention DataDepsGenerators has a pretty heavy set of dependencies,
that you don't really want weighing down your package.


**Note:** DataDepsGenerators does it's best to generate the correct registration code block.
But it is up to you make sure it is right.
The code it generates isn't always the cleanest.
It may capture too much, or too little information.
It might get things wrong (particularly when it is scraping websites that are not very consitantly formatted).
After generating make sure to take a few minutes to check the code is code you are happy with.
Make a few tweaks, and it should be good to go.

An example of use [is in this blog-post](http://white.ucc.asn.au/2018/01/18/DataDeps.jl-Repeatabled-Data-Setup-for-Repeatable-Science.html#example-3-538-avenegers-comic-book-characters--datadepsgeneratorsjl)

## Usage

Basic usage is around the `generate` command.

`generate(::DataRepo, id_or_url, [datadep_name])::String`

 - the first argument is a data repository.
     - Where the data is from.
     - Basically this determines which generator to use.
     - this is an instance of a type, like `GitHub()`, or `UCI()`
 - the second is the `id_or_url`
     - this lets us know which dataset (from that repository) is being targetted.
     - in general just copy and paste the URL of the webpage discribing the dataset out of your webbrowser
 - the last is the `datadep_name`, this is what to use as the name of the datadep
     - i.e. if you put `"Foo"`, when you use the datadep in your code, you'll write `datadep"Foo"`
     - if you skip it, DataDepsGenerators will generate a name from the page
     - you can always edit the resulting code anyway
     
This returns a `String`.
On the REPL if you just return it, it will be full of escape characters.
So best to `print` it, or write it to file.
     

### Write to file

To write the dependency block to a file, you just need to open the file (`"data.jl"` in this example) and write to it.

```julia
using DataDepsGenerators

open("data.jl", "w") do fh
  generate(UCI(), "https://archive.ics.uci.edu/ml/datasets/Air+quality", "UCI Air"))
end
```

Then in your project you can do:

```julia
using DataDeps

function __init__()
    include("data.jl")
end
```

to load registration up

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

eval(parse(generate(UCI(), "https://archive.ics.uci.edu/ml/datasets/Air+quality", "UCI Air"))
```

Then just use anywhere in your code (later in the REPL session for example)  `datadep"UCI Air"` as if it were the name of a directory holding that data.
(Which indeed what that string macro expands into -- even if it has to download the data first).


## Wildcard Use

The above examples show the usage of `generate()` with a DataRepo. There are instances when the user isn’t sure of the data generators to use or if the user wants to reap maximum benefits from all the generators. Hence in order to facilitate that, you can use `generate()` without providing the DataRepo as an argument:

```julia
    generate("10.5061/dryad.74699")
```

This will scrounge in all the available supported DataRepos asynchronously to get the best of all the data according to rules defined.

## Supported DataRepos 

For the API based DataRepos, we give a short description of all the data repositories we have tested it out and found to be working.
 
 
### `UCI()` - Web Based
 https://archive.ics.uci.edu/ml/datasets
 
A fairly classic repository for (mostly) small Machine Learning datasets
 
It not very consistantly written or formatted, so the registrations can be a bit chopy and may e.g. contain links that should have been removed etc.
 
 
### `GitHub()` - Web Based
 https://github.com

Notable Datasets:
 - the folders with-in https://github.com/fivethirtyeight/data
 - The repositories in https://github.com/BuzzFeedNews ([index page](https://github.com/BuzzFeedNews/everything))
 - Everything from https://github.com/collections/open-data
 
 
Note that storing data in github is bad.
However, a fair few datasets are stored there anyway.
A lot of these are plain-text and small files so it works out ok enough.

The generator for Github works on whole repositories, or on folders within repositories.
When downloadining whole repositories, your other option would be to download a `zip` or `tarball` which github provides; rather than generating a datadep with datadep generators which will result in downloading each file separately.
You could even manipulate DataDeps into doing a `git clone`.

Note github does not like being used as a CDN.
For this reason DataDepsGenerators generates URLs to http://cdn.rawgit.com which is a CDN wrapper over github, so you won't thrash github's servers.
Also note that the DataDepGenerator will produce URLs pointing to the current commit.
So the if the repository is updated, the DataDep will still download the old data.
(This is a feature).

At present, we do not support generating for any branch's other than master.
Though it is a simple matter to do a find and replace for the commit SHAs in the generated code so as to point at any commit.

Also, the reference tests present in this package have been stripped off of urls, as they are observed to be changing frequently.

### `DataDryad()` - Web Based

https://datadryad.org

DataDryad is one of the bigger research data stores.
Almost all the data in it is directly linked to one paper or another.

Example of use:
```julia
    generate(DataDryad(), "https://datadryad.org/resource/doi:10.5061/dryad.74699", "Wild Crop Genomics")
```

### `CKAN()` - API Based

http://docs.ckan.org/en/2.8/

CKAN is majorly used by government organizations.

Data Repositories and examples of use:
* CKAN Demo API: `generate(CKAN(), "https://demo.ckan.org/dataset/gold-prices")`
* Data.gov: `generate(CKAN(), "https://catalog.data.gov/api/3/action/package_show?id=consumer-complaint-database")`
* Data.gov.au: `generate(CKAN(), "https://data.gov.au/api/3/action/package_show?id=2016-soe-atmosphere-hourly-co-and-24h-pm2-5-concentrations-measured-during-the-hazelwood-mine-fire")`

### `DataCite()` - API Based

https://www.datacite.org/

Example of use:
```julia
    generate(DataCite(), "10.5063/F1HT2M7Q")
    generate(DataCite(), "https://search.datacite.org/works/10.15148/0e999ffc-e220-41ac-ac85-76e92ecd0320")
```
Either URL or DOI can be provided as arguments.

### `Figshare()` - API Based

https://figshare.com/

Example of use:
```julia
    generate(Figshare(), "10.5281/zenodo.1194927")
    generate(Figshare(), "https://figshare.com/articles/Youth_Activism_in_Chile_from_urban_educational_inequalities_to_experiences_of_living_together_and_solidarity/6504206")
```
URL or DOI or Figshare ID can be provided as arguments.

### `DataOneV1()` - API Based

https://releases.dataone.org/online/api-documentation-v1.2.0/

Data repositories like DataDryad, support version 1 API of the DataOne. 

Data Repositories:
* DataDryad: `generate(DataOneV1(), "https://datadryad.org/resource/doi:10.5061/dryad.74699", "Wild Crop Genomics")`

### `JSONLD_DOI()` - API Based

https://json-ld.org/

A lot of DOIs are stored as JSONLD. This generator helps in retrieving such.

Example of use:
```julia
    generate(JSONLD_DOI(), "10.1371/journal.pbio.2001414")
```

### `JSONLD_Web()` - Web Based

https://json-ld.org/

A lot of data hosting websites like Kaggle, Zenodo, ICRISAT store information in the form of JSONLD on their pages. This generator helps in retrieving such JSONLDs.

Example of use:
```julia
    generate(JSONLD_Web(), "https://www.kaggle.com/stackoverflow/stack-overflow-2018-developer-survey")
```

### `DataOneV2`

https://releases.dataone.org/online/api-documentation-v2.0/apis/index.html

Supports DataOne API version 2. There are differences in the API structure in each of them, hence are accounted for, separately:

Data Repositories:
* Knowledge Network for Biocomplexity `KnowledgeNetworkforBiocomplexity()`: `generate(KnowledgeNetworkforBiocomplexity(), "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/doi:10.5063/F1T43R7N")`
* Arctic Data Center `ArcticDataCenter()`: `generate(ArcticDataCenter(), "https://knb.ecoinformatics.org/knb/d1/mn/v2/object/doi:10.5063%2FF1HT2M7Q")`
* Terrestrial Ecosystem Research Network `TERN()`: `generate(TERN(), "https://dataone.tern.org.au/mn/v2/object/aekos.org.au/collection/nsw.gov.au/nsw_atlas/vis_flora_module/KAHDRAIN.20150515")`




    
