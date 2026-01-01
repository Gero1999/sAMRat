# sAMRat ![sAMRat logo](reference/figures/logo1.png)

> An Open Source Shiny Application that uses the `AMR` package to
> facilitate Antimicrobial Resistance Data Analysis and Reporting.

## Overview

**sAMRat** (Shiny Antimicrobial Resistance Analysis Tool) is an
interactive web application built with R Shiny that simplifies
antimicrobial resistance (AMR) data analysis. It leverages the powerful
[AMR package](https://amr-for-r.org/index.html) to provide:

- 🔬 **Easy Data Upload**: Import your microbiological data in various
  formats
- 🗺️ **Intuitive Mapping**: Map your dataset columns to AMR-compatible
  format
- 📊 **Comprehensive Analysis**: Generate resistance patterns, trends,
  and statistics
- 📈 **Beautiful Visualizations**: Create publication-ready plots and
  charts
- 💾 **Flexible Export**: Export results in multiple formats

## Why sAMRat?

The AMR package is powerful but can be complex for users unfamiliar with
R programming. sAMRat bridges this gap by providing:

- **No Coding Required**: Point-and-click interface for all operations
- **Interactive Experience**: Real-time feedback and previews
- **Guided Workflow**: Step-by-step process from data upload to
  reporting
- **Professional Output**: Generate reports ready for publication or
  presentation

## Installation

Currently, sAMRat is not available on CRAN. Install from GitHub:

### Via cloning the repository

``` bash
git clone https://github.com/Gero1999/sAMRat
```

Then load it using [devtools](https://github.com/r-lib/devtools):

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::load_all()
```

## Quick Start

Launch the application with:

``` r
devtools::load_all()
shiny::runApp(system.file("shiny/app", package = "sAMRat"))
```

For detailed instructions, see the [Getting
Started](https://gero1999.github.io/sAMRat/articles/getting-started.md)
guide.

## Features

### Current Features

- **Data Upload & Preview**: Support for common data formats
- **Column Mapping**: Interactive mapping interface for AMR data
  structure
- **Analysis Tools**: Basic resistance pattern analysis
- **Visualization**: Standard AMR visualizations
- **Export Options**: Download results and plots

### Planned Features

- Database connectivity for large datasets
- Advanced statistical analyses
- Customizable report templates
- Batch processing capabilities
- Multi-language support

## Documentation

- **[Getting
  Started](https://gero1999.github.io/sAMRat/articles/getting-started.md)**:
  Learn the basics of using sAMRat
- **[Architecture](https://gero1999.github.io/sAMRat/articles/architecture.md)**:
  Understand how sAMRat is built
- **[Contributing](https://gero1999.github.io/sAMRat/articles/contributing.md)**:
  Join our community of contributors
- **[Function
  Reference](https://gero1999.github.io/sAMRat/reference/index.md)**:
  Detailed documentation of all functions

## Contributing

We welcome contributions! sAMRat is in active development and we’d love
your help to make it better. Whether you’re:

- 🐛 Reporting bugs
- 💡 Suggesting features  
- 📝 Improving documentation
- 💻 Contributing code

Check out our [Contributing
Guide](https://gero1999.github.io/sAMRat/articles/contributing.md) to
get started!

## Support

- **Issues**: Report bugs or request features on [GitHub
  Issues](https://github.com/Gero1999/sAMRat/issues)
- **Discussions**: Ask questions on [GitHub
  Discussions](https://github.com/Gero1999/sAMRat/discussions)
- **Email**: Contact the maintainer at <gerardo.jrac@gmail.com>

## Acknowledgments

This package builds on the excellent work of:

- **[AMR package](https://amr-for-r.org/)**: The foundation for all AMR
  analysis
- **[Shiny](https://shiny.rstudio.com/)**: The web application framework
- **R Community**: For the amazing ecosystem of packages

**For the AMR package:**

    Berends MS, Luz CF, Friedrich AW, Sinha BNM, Albers CJ, Glasner C (2022).
    "AMR: An R Package for Working with Antimicrobial Resistance Data."
    Journal of Statistical Software, 104(3), 1-31. doi:10.18637/jss.v104.i03

**Maintained by**: Gerardo Jose Rodriguez
([@Gero1999](https://github.com/Gero1999))
