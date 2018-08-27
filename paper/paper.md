---
title: 'DataDepsGenerators.jl: making reusing data easy by automatically generating DataDeps.jl registration code'
tags:
  - julialang
  - opendata
  - metadata
authors:
 - name: Lyndon White
   orcid: 0000-0003-1386-1646
   affiliation: 1
 - name: SebastinSanty
   affiliation: 2

affiliations:
 - name: The University of Western Australia
   index: 1
 - name: Birla Institute of Technology and Science, Pilani
   index: 2

date: 24 Aug 2018
bibliography: paper.bib
---

# Summary

DataDepsGenerators.jl is an tool written to help users of the Julia programming language ([@Julia]),
to observe best practices when making use of published datasets.
Using the metadata present in published datasets, in generates the code for the data dependency registration blocks required by DataDeps.jl ([@2018arXiv180801091W]).
These registration blocks are effectively executable metadata,
which can be resolved by DataDeps.jl to download the dataset.
They include a message that is displayed to the user whenever the data set is automatically downloaded.
This message should include provenance information on the dataset,
so that downstream users know its original source and details on its processing.

DataDepsGenerators.jl attempts to use the metadata available for a dataset to capture and record:
 - The dataset name.
 - A URL for a website about the dataset.
 - The names of the authors and maintainers
 - The creation date, publication date, and the date of the most recent modification.
 - The license that the dataset is released under.
 - The formatted bibliographic details of any paper about or relating to the dataset.
 - The formatted bibliographic details of how to cite the dataset itself.
 - A list of URLs where the files making up the dataset can be downloaded.
 - A corresponding list of file hashes, such as MD5 or SHA256, to validate the files after download.
 - A description of the dataset.

Depending on the APIs supported by the repository some of this information may not be available.
DataDepsGenerators.jl makes a best-effort attempt to acquire as much provenance information as possible.
Where multiple APIs are supported, it makes use of all APIs possible, merging their responses to fill any gaps.
It thus often produces higher quality and more comprehensive dataset metadata than is available from any one source.

DataDepsGenerators.jl leavages many different APIs to support a very large number of repositories.
By current estimates tens of millions of datasets are supported, from hundreds of repositories.
The APIs supported include:
 - [DataCite](https://datacite.org/) / [CrossRef](https://www.crossref.org/)
    - This is valid for the majority of all dataset with a DOI.
 - [DataOne](https://www.dataone.org/)
    - This supports a number of data repositories used in the earth sciences.
 - [FigShare](http://figshare.com/)
    - A popular general purpose data repository.
 - [DataDryad](http://datadryad.org/)
    - A data repository particularly popular with evolutionary biology and ecology.
 - [UCI ML repository](https://archive.ics.uci.edu/ml/)
    - A data repository commonly used for small-medium machine learning benchmark datasets.
 - [GitHub](https://github.com)
    - Most well known for hosting code; but is fairly regularly used to host versioned datasets.
 - [CKAN](http://ckan.org/)
    - This is the system behind a large number of government open data initiatives;
	- such as Data.Gov](https://data.gov), [data.gov.au](https://data.gov.au/), and the [European Data Portal](https://www.europeandataportal.eu/)
 - Embedded JSON-LD fragments in HTML pages.
    - This is commonly used on many websites to describe their datasets.
	- Including many of those listed above.
	- But also [Zenodo](https://zenodo.org/), [Kaggle Datasets](https://www.kaggle.com/datasets), all [DataVerse](https://dataverse.org/) sites and many others.

DataDepsGenerators.jl as the name suggests, generates static code which the user can add into their project's julia source code to make use of with DataDeps.jl.
There are a number of reasons why static code generation is preferred over directly using the APIs.
 - On occasion the information reported by the APIs is wrong or incomplete. By generating code that the user may edit they may tweak the details as required.
 - The process of accessing the APIs requires a number of heavy dependencies, such as HTML and JSON parsers. If these APIs were to be access directly by a project, it would require adding this large dependency tree to the project.
 - It is important to know if a dataset has changed. As such retrieving the file hash and last modification date would be pointless if they are updated automatically.
Finally: having the provenance information recorded in plain text, makes the dataset metadata readily accessible to anyone reading the source code; without having to run the project's application.


The automatic downloading of data is important to allow for robustly replicable scientific code.
The inclusion of provenance information is required to give proper credit and to allow for good understanding of the dataset's real world context.
DataDepsGenerators.jl makes this easy by automating most of the work.
	
## Acknowledgements
 
This work was largely carried out as a [Google Summer of Code project](https://medium.com/@sebastinsanty/google-summer-of-code-2018-julia-computing-report-8d3f553d7050), as part of the NumFocus organisation.
It also benefited from funding from Australian Research Council Grants DP150102405 and LP110100050.  

We also wish to thank the support teams behind the APIs and repositories listed above.
In the course of creating this tool we thoroughly exercised a number of APIs.
In doing so we encountered a number of bugs and issues; almost all of which have now been fixed,
by the attentive support and operation staff of the providers.


# References
