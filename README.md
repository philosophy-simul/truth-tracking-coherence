This is the Julia code for the simulations reported in a paper Measuring Coherence: Agreement, Dependence, and Truth.

It is based on Igor Douven's code for simulations of confirmation measures (https://github.com/IgorDouven/Tracking), although adapted in many ways (described in the corresponding paper).

Our simulations may be reproduced by first running coherence_simulations.jl and following the steps as documented in the file.
Then the results may be (re-)analyzed and the aggregated plots obtained by running auc_reanalyzer.jl.

Note: data from the simulations in csv files should be placed in folder "csvs/standard" for auc_reanalyzer.jl to work (or else pointed to this folder from Julia). The generation of the data takes long, so we also include the (fully reproducible) AUC data in this repository. 

The script also exports additional data for each simulation at each number of possible worlds. This (fully reproducible) data altogether takes over 10 GB, so we omit it from the repository.

The plots used in the paper are:

Figure 3:
/plots/aggregations/auc-all_n_and_all_a0.pdf

Figure 4:
/plots/individual-runs/auc-n7-a0_0.1confirmed_prop_autogenerated_7_trueenough_prop.pdf 

/plots/individual-runs/auc-n7-a0_0.9confirmed_prop_autogenerated_7_trueenough_prop.pdf


Note on csv data file names:

There are two types of files: those ending with "prop.csv" and "propfull.csv". The latter contain simulated data for every of 250 repetitions, while the former takes the average value of them (and is represented in the plots).

The names are structured as follows:

auc-nX-a0_YYYconfirmed_prop_autogenerated_Z-trueenough_prop(full).csv

where

X - cardinality of the information set

YYY - prior probability of the information set

Z - how many pieces of information must be true for the set to be considered true (enough)

Note on Z: Although the paper omits this possibility, we also investigated how good the measures of coherence are when we relax the requirement for the information in a set to be considered to be true. Particularly, the information in the information set is currently true if all propositions (pieces of information) are true. However, we can also check what happens if information is considered to be true (or, more precisely, true enough) when some information is false (e.g., a set with 5 true pieces of information out of 7 may count as true on this approach). This was included for exploration only, but we include the plots and data for full transparency. These can be found in the corresponding "trueenough-exploraton" folders.

The reuse_sim_data.jl script may be used to investigate the exported data (which is not included here as it is over 10GB but it is produced when the coherence_simulations.jl run through) and, if wished, to add further measures of coherence.
