# Getting Started with sAMRat

## Introduction

Welcome to **sAMRat** (Shiny Antimicrobial Resistance Analysis Tool)!
This package provides an interactive Shiny application designed to
facilitate antimicrobial resistance (AMR) data analysis and reporting.

The application builds on the powerful [AMR
package](https://amr-for-r.org/index.html) to provide an intuitive
interface for:

- Uploading and mapping microbiological datasets
- Performing comprehensive AMR data analysis
- Generating visualizations and statistical reports
- Exporting results for further use

## Installation

Currently, sAMRat is not available on CRAN, so you’ll need to install it
from the GitHub repository.

### Via cloning the repository

Clone the repository through your terminal/shell:

``` bash
git clone https://github.com/Gero1999/sAMRat
```

Then load it directly using
[devtools](https://github.com/r-lib/devtools) in your IDE (e.g.,
RStudio) console:

``` r
if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}
devtools::load_all()
```

### Installing dependencies

Make sure you have all required dependencies installed:

``` r
# Install required packages
install.packages(c("AMR", "dplyr", "ggplot2", "shiny"))
```

## Quick Start

To run the application, simply invoke:

``` r
devtools::load_all()
shiny::runApp(system.file("shiny/app", package = "sAMRat"))
```

This will launch the Shiny application in your default web browser.

## Using the Application

### 1. Data Upload

The first step is to upload your microbiological data. The application
accepts various data formats and helps you map your columns to the AMR
package structure.

### 2. Data Mapping

Once your data is uploaded, you’ll need to map your dataset columns to
the expected AMR format. This includes:

- Microorganism identification
- Antimicrobial agent codes
- Test results (MIC values, disk zones, or interpretations)
- Patient/sample metadata

### 3. Analysis

After mapping your data, you can perform various analyses including:

- Resistance patterns
- Susceptibility trends over time
- Comparison between different organisms or antibiotics
- Statistical summaries

### 4. Visualization and Export

Generate publication-ready visualizations and export results in various
formats for further analysis or reporting.

## Core Functionality

### Creating AMR Objects

The
[`create_amr_obj()`](https://gero1999.github.io/sAMRat/reference/create_amr_obj.md)
function is the core function for creating AMR-compatible data objects:

``` r
library(sAMRat)

# Example: Create an AMR object from your data
amr_data <- create_amr_obj(
  data = your_data,
  # Additional parameters as needed
)
```

## Next Steps

- Read the [Architecture - not yet
  available](https://gero1999.github.io/sAMRat/articles/architecture.md)
  article to understand how the package is structured
- Check out the [Contributing - not yet
  available](https://gero1999.github.io/sAMRat/articles/contributing.md)
  guide if you’d like to contribute
- Visit the [AMR package website](https://amr-for-r.org/index.html) for
  more information about the underlying functionality

## Getting Help

If you encounter any issues or have questions:

1.  Check the [GitHub Issues](https://github.com/Gero1999/sAMRat/issues)
    page
2.  Open a new issue with a reproducible example
