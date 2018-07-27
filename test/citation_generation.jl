using DataDepsGenerators
using Base.Test

@test remove_cite_version(citation_text("10.3732/ajb.1000481")) ==
    "Smith, S. A., Beaulieu, J. M., Stamatakis, A., & Donoghue, M. J. (2011). Understanding angiosperm diversification using small and large phylogenetic trees. American Journal of Botany, 98(3), 404–414. doi:10.3732/ajb.1000481"



@test remove_cite_version(citation_text("https://doi.org/10.5061/dryad.8790")) ==
    "Smith, S. A., Beaulieu, J. M., Stamatakis, A., & Donoghue, M. J. (2011). Data from: Understanding angiosperm diversification using small and large phylogenetic trees [Data set]. Dryad Digital Repository. https://doi.org/10.5061/dryad.8790"
