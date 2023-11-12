Note: this is a fork of https://github.com/haskell-CI/haskell-ci, rebased on the original.

Change(s) in this fork:

1. Default distribution is `focal` instead of `bionic`.
   So, consistently only GHC 7.10.3 and up are supported.
   See: https://github.com/haskell-CI/haskell-ci/issues/628.

2. Default install method is `ghcup` rather than `hvr-ppa`.
   See: https://github.com/haskell-CI/haskell-ci/pull/685

3. Use `.0` for GHC prereleases instead of `.1`.
   E.g. here you declare `tested-with: GHC == 9.8.0` to get CI for a prerelease of GHC 9.8.
   In the original, you declare `tested-with: GHC == 9.8.1`.
   See: https://github.com/haskell-CI/haskell-ci/issues/631

   Note: After a release of GHC, support for prereleases is dropped even from this fork of `haskell-ci`.

Full change set at: https://github.com/haskell-CI/haskell-ci/compare/master...andreasabel:haskell-ci:master


haskell-ci - CI generator for multiple [GHC](http://haskell.org/ghc) versions
=============================================================================

At the moment `haskell-ci` support GitHub Actions workflow generation.
There is also legacy Travis-CI configuration generator, which is unmaintained.

`haskell-ci` relies on [`hvr-ppa`](https://launchpad.net/~hvr/+archive/ubuntu/ghc)
or [`ghcup`](https://www.haskell.org/ghcup/) to install GHC
and `cabal-install`.

### Quick-start instructions

* Step 1: Clone and install this project in/from any directory

    ```bash
    $ git clone https://github.com/haskell-CI/haskell-ci.git
    $ cd haskell-ci
    $ cabal new-install haskell-ci:exe:haskell-ci
    ```

  or

    ```bash
    cabal new-install haskell-ci
    ```

* Step 2: Change directories to your project:

    ```bash
    $ cd path/to/your-project
    ```

* Step 3: Edit your project's `*.cabal` file to add a `Tested-With` line, such as this one:

    ```bash
    $ cat your-project.cabal
    ...
    Tested-With: GHC ==8.6.5 || ==8.4.4 || ==8.2.2
    ...
    ```

    Add as many or as few GHC versions to test as you want.

* Step 4: Generate a workflow file for your project:

    ```bash
    $ # You run the following command from your project's directory, even
    $ # though it references the script from the `haskell-ci` project
    $ haskell-ci github your-project.cabal
    ```

    Note: If you have multiple local Cabal projects that you wish to build together
    using a `cabal.project` file, pass that file to haskell-ci instead:
    ```bash
    $ haskell-ci github cabal.project
    ```

    The `haskell-ci` tool looks at the `Tested-With` line in your
    `*.cabal` files and generates a configuration that tests each compiler
    version you listed in parallel.

* Step 5: Create a branch with your new CI configuration file and push your branch:

    ```bash
    $ git checkout master            # Check out `master`
    $ git pull --ff-only             # Get the latest version of `master`
    $ git checkout -b new-ci         # Create a `new_travis` branch
    $ git add .
    $ git commit -m "New CI script"
    $ git push -u origin new-ci      # Push your branch upstream
    ```

* Step 6: Fix the build

    If you're lucky, your repository will build for every compiler version
    you listed.  If that's the case, then just merge your changes into `master`:

    ```bash
    $ git checkout master
    $ git merge new-ci  # Update `master` with your new CI script
    $ git push
    ```

    You can also merge your branch into `master` from Github's pull request view.

    If you're not lucky, then your new CI branch will fail for one or more
    versions of GHC, which is okay!  Look at the build and fix any build failures
    you find and commit the fixes to your branch:

    ```bash
    $ # Fix any build failures you find and commit your changes
    $ ...
    $ git push  # Push your branch updates upstream
    ```

    Sometimes you may need to regenerate CI script, for example, when
    adding new compiler version to `tested-with`.
    You may simply run `haskell-ci regenerate`.

Real-world Examples
-------------------

 - [aeson](https://github.com/haskell/aeson)
 - [lens](https://github.com/ekmett/lens)
 - [unordered-containers](https://github.com/haskell-unordered-containers/unordered-containers)
