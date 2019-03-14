# Contributing to ImportMesh package

If you would like to modify ImportMesh package yourself or contribute back to the original repository,
then the following instructions can help you.
First you need to install [Git](https://git-scm.com/) and
[clone](https://help.github.com/articles/cloning-a-repository/) the project
from its GitHub homepage to your local computer.

## Prerequisites

Essential:

* [Mathematica](https://www.wolfram.com/mathematica/) version 11.1 or later

Recommended:

* [WolframScript](https://www.wolfram.com/wolframscript/) for building the `.paclet` file from command line.
 On most systems it already comes bundled with Mathematica installation.

## Testing code

It is considered good practice that every (public) function in this package includes its own set of unit tests.
A bunch of them is collected in `Tests/Tests.wl` file, using the Mathematica testing
[framework](https://reference.wolfram.com/language/guide/SystematicTestingAndVerification.html).
It is recommended that you run them periodically during development and especially before every commit.
This can be done by calling script file `Tests/RunTests.wls` in command line
(first change directory to project root directory) or by evaluating whole notebook `Tests/RunTests.nb`.

### Integration of tests in Git hook

Unit test can be run automatically before every commit via Git client-side
[hooks](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks).
File `pre-commit` should contain call to `Tests/RunTests.wls` script,
which exits with value 0 if all tests pass and aborts the commit otherwise.
Minimal example of `pre-commit` file content is:

    #!/bin/sh
    ./Tests/RunTests.wls

## How to build the package

Package currently has no documentation in notebook format (.nb). To build the package source files just need to be packaged into a `.paclet` file.

### Packaging ImportMesh

Open terminal window (command line) in ImportMesh root directory and run file `Build.wls`.
This will leave you with a ImportMesh-X.Y.Z.paclet file in the _build_ folder.
