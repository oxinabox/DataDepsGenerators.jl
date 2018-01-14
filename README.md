# DataDepsGenerators
**Generating registration blocks for [DataDeps.jl](https://github.com/oxinabox/DataDeps.jl) in 1 key press.**


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

```
using DataDepsGenerators

open("data.jl", "w") do fh
  println(fh, generate(UCI(), https://archive.ics.uci.edu/ml/datasets/Air+quality, "UCI Air))
end
```

Then in your project you can do:

```
using DataDeps

function __init__()
    include("data.jl")
end
```

to load registration up

### Output it to the screen

This is pretty easy:

```
println(generate(UCI(), https://archive.ics.uci.edu/ml/datasets/Air+quality, "UCI Air))
````

then copy and paste into your project.



### Interactive Use
While this isn't advise for use in packages -- since it throws away many of the benifits of using DataDeps, it can be done.
It is probably most useful in the REPL/IJulia.

```
using DataDeps
using DataDepsGenerators

`eval(parse(generate(UCI(), https://archive.ics.uci.edu/ml/datasets/Air+quality, "UCI Air))
```

Then just use anywhere in your code (later in the REPL session for example)  `datadep"UCI Air"` as if it were the name of a directory holding that data.
(Which indeed what that string macro expands into -- even if it has to download the data first).





 ## Supported DataRepos 
 
 
### `UCI()`
 https://archive.ics.uci.edu/ml/datasets
 
A fairly classic repository for (mostly) small Machine Learning datasets
 
It not very consistantly written or formatted, so the registrations can be a bit chopy and may e.g. contain links that should have been removed etc.
 
 
 
