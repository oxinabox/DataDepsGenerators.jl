# DataDepsGenerators


This package should not be used as a dependancy.
Instread the interactive features of this package should be used from the Julia REPL,
to get a good registration block, which is output to a file (or STDOUT),
which can be added to your package.

While it can be used to directly create and invoke a registration,
this use handy for interactive and prototyping use,
but not great for packages, as it involves triggering a webscraper everytime the package is loaded.
Not to mention DataDepsGenerators has a pretty heavy set of dependencies,
that you don't really want weighing down your package.
