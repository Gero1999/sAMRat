# shiny `AMR` analysis tool (`sAMRat`)
<img src='man/figures/logo1.png' align="right" alt="sAMRat logo" width="150">

<br/>
<br/>

> An Open Source Shiny Application that uses the `AMR` package to facilitate Antimicrobial Resistance Data Analysis and Reporting.
<br/>

## Description

The Application depends on the [AMR](https://github.com/msberends/AMR) package to perform data analysis on microbiological data. It provides an interactive interface to upload datasets, map them to the `AMR` package structure, and generate various reports and visualizations.

It is still in active development, and new features will be added over time. Feel free to contribute or suggest new functionalities!


## Installation

For now there is no CRAN release of the package yet, so you will need to install by cloning the repository.


### Via cloning the repository

Alternatively, you can set up the package by cloning the repository through your terminal/shell:

```bash
git clone https://github.com/Gero1999/sAMRat
```

and then loading it directly using [devtools](https://github.com/r-lib/devtools) in your IDE (e.g. RStudio) console:

```R
if (!requireNamespace("devtools", quietly = FALSE)) {
  install.packages("devtools")
}
devtools::load_all()
```

## Quick start

To run the application, simply invoke:

```R
devtools::load_all()
shiny::runApp(system.file("shiny/app", package = "sAMRat"))
```

## Contributing

The project is in an early stage and highly open to spontaneous or active contributors!
Check our [contributing guidelines](https://github.com/Gero1999/sAMRat/CONTRIBUTING.md).


## Documentation and references

- Visit our [Website](https://gero1999.github.io/sAMRat/) for comprehensive documentation, tutorials, and guides.
- The main package the App depends on is `AMR`. You can find more of it on its [website](https://amr-for-r.org/index.html)
