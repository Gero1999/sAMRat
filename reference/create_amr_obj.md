# Create an AMR-ready object by converting selected columns

This helper converts specified columns in a data.frame to AMR-friendly
types using the \[AMR\] package (for example \`as.mo()\`, \`as.sir()\`,
\`as.mic()\`, \`as.disk()\`) and collects metadata for microorganisms
and antimicrobials. It will also attempt to coerce a date column to
\`Date\` using common formats and can optionally filter to the first
isolate per subject and microorganism.

This helper converts specified columns in a data.frame to AMR-friendly
types using the \[AMR\] package (for example \`as.mo()\`, \`as.sir()\`,
\`as.mic()\`, \`as.disk()\`) and collects metadata for microorganisms
and antimicrobials. It will also attempt to coerce a date column to
\`Date\` using common formats and can optionally filter to the first
isolate per subject and microorganism.

## Usage

``` r
create_amr_obj(
  df,
  mo_col = NULL,
  sir_cols = NULL,
  mic_cols = NULL,
  disk_cols = NULL,
  date_col = NULL,
  subject_col = NULL,
  filter_first_isolate = FALSE
)

create_amr_obj(
  df,
  mo_col = NULL,
  sir_cols = NULL,
  mic_cols = NULL,
  disk_cols = NULL,
  date_col = NULL,
  subject_col = NULL,
  filter_first_isolate = FALSE
)
```

## Arguments

- df:

  A data.frame containing the raw isolate or susceptibility data.

- mo_col:

  Character (single) name of the microorganism column in \`df\`. If
  provided, values are coerced with \`as.mo()\` and microorganism
  metadata is returned.

- sir_cols:

  Character vector of column names containing S/I/R results. Each found
  column will be coerced with \`as.sir()\`.

- mic_cols:

  Character vector of column names containing MIC results. Each found
  column will be coerced with \`as.mic()\`.

- disk_cols:

  Character vector of column names containing disk diffusion results.
  Each found column will be coerced with \`as.disk()\`.

- date_col:

  Character (single) name of a date column. The function will try a few
  common formats and coerce the column to \`Date\`.

- subject_col:

  Character (single) name of the column used as subject/patient
  identifier. If provided a \`SUBJID\` factor column is added to the
  returned data.

- filter_first_isolate:

  Logical, if \`TRUE\` the data is filtered to only the first isolate
  per subject x microorganism (earliest date). The function uses
  \`dplyr::filter()\` with an internal helper and will fall back to
  returning the unfiltered data on error.

## Value

A named list with at least: \* \`data\`: the transformed \`data.frame\`.
\* \`mo\` (optional): list with \`naming\`, \`traits\`, \`taxonomy\`,
and \`details\` data.frames for the microorganism column. \* \`ab\`
(optional): list with \`group\`, \`details\`, \`atc\`, \`tradenames\`
and \`loinc\` information for antibiotic columns.

A named list with at least: \* \`data\`: the transformed \`data.frame\`.
\* \`mo\` (optional): list with \`naming\`, \`traits\`, \`taxonomy\`,
and \`details\` data.frames for the microorganism column. \* \`ab\`
(optional): list with \`group\`, \`details\`, \`atc\`, \`tradenames\`
and \`loinc\` information for antibiotic columns.

## Details

The returned object is a list with at least a \`data\` element (the
transformed data.frame). When a microorganism column is provided, a
\`mo\` sub-list with naming, traits, taxonomy and details is included.
When antibiotic columns are provided a corresponding \`ab\` sub-list is
returned with group and details information.

This function wraps a number of convenience conversions from the \[AMR\]
package. It uses \`try()\`/\`tryCatch()\` in several places to avoid
hard failures for partial or unexpected inputs.

The returned object is a list with at least a \`data\` element (the
transformed data.frame). When a microorganism column is provided, a
\`mo\` sub-list with naming, traits, taxonomy and details is included.
When antibiotic columns are provided a corresponding \`ab\` sub-list is
returned with group and details information.

This function wraps a number of convenience conversions from the \[AMR\]
package. It uses \`try()\`/\`tryCatch()\` in several places to avoid
hard failures for partial or unexpected inputs.

## See also

\[as.mo()\], \[as.sir()\], \[as.mic()\], \[as.disk()\]

\[as.mo()\], \[as.sir()\], \[as.mic()\], \[as.disk()\]

## Examples

``` r
# Minimal example (requires the AMR package):
if (requireNamespace("AMR", quietly = TRUE)) {
  df <- data.frame(
    mo = c("Escherichia coli", "Staphylococcus aureus"),
    AMP = c("R", "S"),
    date = c("2020-01-01", "2020-01-02"),
    id = c("p1", "p2"),
    stringsAsFactors = FALSE
  )
  create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date", subject_col = "id")
}
#> $data
#>                      mo AMP       date id SUBJID
#> 1      Escherichia coli   R 2020-01-01 p1     p1
#> 2 Staphylococcus aureus   S 2020-01-02 p2     p2
#> 
#> $mo
#> $mo$naming
#>                      mo              fullname     short               current
#> 1      Escherichia coli      Escherichia coli   E. coli      Escherichia coli
#> 2 Staphylococcus aureus Staphylococcus aureus S. aureus Staphylococcus aureus
#> 
#> $mo$traits
#>                      mo    gram_stain pathogenicity     oxygen_tolerance
#> 1      Escherichia coli Gram-negative    Pathogenic facultative anaerobe
#> 2 Staphylococcus aureus Gram-positive    Pathogenic facultative anaerobe
#>       type
#> 1 Bacteria
#> 2 Bacteria
#> 
#> $mo$taxonomy
#>                      mo species          genus             family
#> 1      Escherichia coli    coli    Escherichia Enterobacteriaceae
#> 2 Staphylococcus aureus  aureus Staphylococcus  Staphylococcaceae
#>              order               class         phylum  kingdom
#> 1 Enterobacterales Gammaproteobacteria Pseudomonadota Bacteria
#> 2    Caryophanales             Bacilli      Bacillota Bacteria
#> 
#> $mo$details
#>                                          mo     gbif
#> Escherichia coli           Escherichia coli 11286021
#> Staphylococcus aureus Staphylococcus aureus     <NA>
#>                                                                      url
#> Escherichia coli           https://lpsn.dsmz.de/species/escherichia-coli
#> Staphylococcus aureus https://lpsn.dsmz.de/species/staphylococcus-aureus
#> 
#> $mo$columns
#> $mo$columns$mo
#> [1] "mo"
#> 
#> 
#> 
#> $ab
#> $ab$group
#>   col  ab       name                    group
#> 1 AMP AMP Ampicillin Beta-lactams/penicillins
#>                                atc_group1                         atc_group2
#> 1 Beta-lactam antibacterials, penicillins Penicillins with extended spectrum
#> 
#> $ab$details
#>    ab ab_val ddd_oral_amount ddd_oral_units ddd_iv_amount ddd_iv_units
#> 1 AMP    AMP               2              g             6            g
#> 
#> $ab$atc
#> [1] "J01CA01"  "QJ01CA01" "QJ51CA01" "QS01AA19" "S01AA19" 
#> 
#> $ab$tradenames
#>  [1] "adobacillin"     "alpen"           "amblosin"        "amcap"          
#>  [5] "amcill"          "amfipen"         "ampen"           "amperil"        
#>  [9] "ampichel"        "ampicilina"      "ampicillina"     "ampicilline"    
#> [13] "ampicillinesalt" "ampicillinsalt"  "ampicillinum"    "ampifarm"       
#> [17] "ampikel"         "ampimed"         "ampinova"        "ampipenin"      
#> [21] "ampiscel"        "ampisyn"         "ampivax"         "ampivet"        
#> [25] "amplacilina"     "amplin"          "amplipenyl"      "amplisom"       
#> [29] "amplital"        "austrapen"       "bayer"           "binotal"        
#> [33] "bonapicillin"    "britacil"        "cimex"           "citteral"       
#> [37] "copharcilin"     "cymbi"           "delcillin"       "deripen"        
#> [41] "divercillin"     "doktacillin"     "domicillin"      "duphacillin"    
#> [45] "grampenil"       "guicitrina"      "guicitrine"      "lifeampil"      
#> [49] "marcillin"       "morepen"         "norobrittin"     "nuvapen"        
#> [53] "omnipen"         "orbicilina"      "penbristol"      "penbritin"      
#> [57] "penbrock"        "penialmen"       "penicline"       "penimic"        
#> [61] "penizillin"      "pensyn"          "pentrex"         "pentrexl"       
#> [65] "pentrexyl"       "pentritin"       "ponecil"         "princillin"     
#> [69] "principen"       "racenacillin"    "redicilin"       "rosampline"     
#> [73] "roscillin"       "semicillin"      "servicillin"     "sumipanto"      
#> [77] "supen"           "synpenin"        "texcillin"       "tokiocillin"    
#> [81] "tolomol"         "totacillin"      "totalciclina"    "totapen"        
#> [85] "trafarbiot"      "trifacilina"     "ukapen"          "ultrabion"      
#> [89] "ultrabron"       "vampen"          "viccillin"       "vidocillin"     
#> [93] "wypicil"        
#> 
#> $ab$loinc
#>  [1] "101477-8" "101478-6" "18864-9"  "18865-6"  "20374-5"  "21066-6" 
#>  [7] "23618-2"  "27-3"     "28-1"     "29-9"     "30-7"     "31-5"    
#> [13] "32-3"     "33-1"     "3355-5"   "33562-0"  "33919-2"  "34-9"    
#> [19] "43883-8"  "43884-6"  "6979-9"   "6980-7"   "87604-5" 
#> 
#> $ab$columns
#> $ab$columns$sir
#> [1] "AMP"
#> 
#> $ab$columns$mic
#> NULL
#> 
#> $ab$columns$disk
#> NULL
#> 
#> 
#> 


# Minimal example (requires the AMR package):
if (requireNamespace("AMR", quietly = TRUE)) {
  df <- data.frame(
    mo = c("Escherichia coli", "Staphylococcus aureus"),
    AMP = c("R", "S"),
    date = c("2020-01-01", "2020-01-02"),
    id = c("p1", "p2"),
    stringsAsFactors = FALSE
  )
  create_amr_obj(df, mo_col = "mo", sir_cols = "AMP", date_col = "date", subject_col = "id")
}
#> $data
#>                      mo AMP       date id SUBJID
#> 1      Escherichia coli   R 2020-01-01 p1     p1
#> 2 Staphylococcus aureus   S 2020-01-02 p2     p2
#> 
#> $mo
#> $mo$naming
#>                      mo              fullname     short               current
#> 1      Escherichia coli      Escherichia coli   E. coli      Escherichia coli
#> 2 Staphylococcus aureus Staphylococcus aureus S. aureus Staphylococcus aureus
#> 
#> $mo$traits
#>                      mo    gram_stain pathogenicity     oxygen_tolerance
#> 1      Escherichia coli Gram-negative    Pathogenic facultative anaerobe
#> 2 Staphylococcus aureus Gram-positive    Pathogenic facultative anaerobe
#>       type
#> 1 Bacteria
#> 2 Bacteria
#> 
#> $mo$taxonomy
#>                      mo species          genus             family
#> 1      Escherichia coli    coli    Escherichia Enterobacteriaceae
#> 2 Staphylococcus aureus  aureus Staphylococcus  Staphylococcaceae
#>              order               class         phylum  kingdom
#> 1 Enterobacterales Gammaproteobacteria Pseudomonadota Bacteria
#> 2    Caryophanales             Bacilli      Bacillota Bacteria
#> 
#> $mo$details
#>                                          mo     gbif
#> Escherichia coli           Escherichia coli 11286021
#> Staphylococcus aureus Staphylococcus aureus     <NA>
#>                                                                      url
#> Escherichia coli           https://lpsn.dsmz.de/species/escherichia-coli
#> Staphylococcus aureus https://lpsn.dsmz.de/species/staphylococcus-aureus
#> 
#> $mo$columns
#> $mo$columns$mo
#> [1] "mo"
#> 
#> 
#> 
#> $ab
#> $ab$group
#>   col  ab       name                    group
#> 1 AMP AMP Ampicillin Beta-lactams/penicillins
#>                                atc_group1                         atc_group2
#> 1 Beta-lactam antibacterials, penicillins Penicillins with extended spectrum
#> 
#> $ab$details
#>    ab ab_val ddd_oral_amount ddd_oral_units ddd_iv_amount ddd_iv_units
#> 1 AMP    AMP               2              g             6            g
#> 
#> $ab$atc
#> [1] "J01CA01"  "QJ01CA01" "QJ51CA01" "QS01AA19" "S01AA19" 
#> 
#> $ab$tradenames
#>  [1] "adobacillin"     "alpen"           "amblosin"        "amcap"          
#>  [5] "amcill"          "amfipen"         "ampen"           "amperil"        
#>  [9] "ampichel"        "ampicilina"      "ampicillina"     "ampicilline"    
#> [13] "ampicillinesalt" "ampicillinsalt"  "ampicillinum"    "ampifarm"       
#> [17] "ampikel"         "ampimed"         "ampinova"        "ampipenin"      
#> [21] "ampiscel"        "ampisyn"         "ampivax"         "ampivet"        
#> [25] "amplacilina"     "amplin"          "amplipenyl"      "amplisom"       
#> [29] "amplital"        "austrapen"       "bayer"           "binotal"        
#> [33] "bonapicillin"    "britacil"        "cimex"           "citteral"       
#> [37] "copharcilin"     "cymbi"           "delcillin"       "deripen"        
#> [41] "divercillin"     "doktacillin"     "domicillin"      "duphacillin"    
#> [45] "grampenil"       "guicitrina"      "guicitrine"      "lifeampil"      
#> [49] "marcillin"       "morepen"         "norobrittin"     "nuvapen"        
#> [53] "omnipen"         "orbicilina"      "penbristol"      "penbritin"      
#> [57] "penbrock"        "penialmen"       "penicline"       "penimic"        
#> [61] "penizillin"      "pensyn"          "pentrex"         "pentrexl"       
#> [65] "pentrexyl"       "pentritin"       "ponecil"         "princillin"     
#> [69] "principen"       "racenacillin"    "redicilin"       "rosampline"     
#> [73] "roscillin"       "semicillin"      "servicillin"     "sumipanto"      
#> [77] "supen"           "synpenin"        "texcillin"       "tokiocillin"    
#> [81] "tolomol"         "totacillin"      "totalciclina"    "totapen"        
#> [85] "trafarbiot"      "trifacilina"     "ukapen"          "ultrabion"      
#> [89] "ultrabron"       "vampen"          "viccillin"       "vidocillin"     
#> [93] "wypicil"        
#> 
#> $ab$loinc
#>  [1] "101477-8" "101478-6" "18864-9"  "18865-6"  "20374-5"  "21066-6" 
#>  [7] "23618-2"  "27-3"     "28-1"     "29-9"     "30-7"     "31-5"    
#> [13] "32-3"     "33-1"     "3355-5"   "33562-0"  "33919-2"  "34-9"    
#> [19] "43883-8"  "43884-6"  "6979-9"   "6980-7"   "87604-5" 
#> 
#> $ab$columns
#> $ab$columns$sir
#> [1] "AMP"
#> 
#> $ab$columns$mic
#> NULL
#> 
#> $ab$columns$disk
#> NULL
#> 
#> 
#> 
```
