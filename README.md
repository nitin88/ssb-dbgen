 # Star Schema Benchmark data set generator (dbgen) 

This repository holds the data generation utility for the Star Schema Benchmark (SSB) for DBMS analytics. It generates schema data as table files, in a simple textual format, which can then be loaded into a DBMS for running the benchmark.

| Table of contents|
|:----------------|
| ["What? _Another_ fork of ssb-dbgen? Why?"](#another-fork)<br>  [About the Star Schema Benchmark](#about-ssb)<br> [Building the generation utility](#building)<br> [Using the utility to generate data](#using)<br> [Differences of the generated data from the TPC-H schema](#difference-from-tpch)<br>[Trouble building/running](#trouble)<br> |

## <a name="another-fork">"What? _Another_ fork of ssb-dbgen? Why?"</a>

The `ssb-dbgen` utility is based on the [TPC-H benchmark](http://tpc.org/tpch/)'s data generation utility, also named `dbgen`. While the latter is pretty stable and gets updated if bugs or build issues are found, that is not true of the former. The SSB does not have an official website; and the original code of its own `dbgen` was forked from an older version of TPC-H `dbgen`, and not maintained by the benchmark's creators since its release.

The result has been several repositories here on github with various changes to the code, intended to resolve this or the other issue with compilation or execution, occasionally adding new files (such as scripts for loading the data into a DBMS, generating compressed data files, removing the trailing pipe characters etc.). The result is a tree of mostly unsynchronized repositories - with most having been essentially abandoned: Last commits several years ago with more than a couple of issues unresolved.

This is an attempt to **unify** all the repositories, taking all changes to the code which - to my opinion - are generally applicable, and applying them altogether while resolving any conflicts. Details of what's already been done can be found on the [Closed Issues Page](https://github.com/eyalroz/ssb-dbgen/issues?q=is%3Aissue+is%3Aclosed) and of course by examining the commit comments.

If you are the author of one of the other repositories - please [contact me](mailto:eyalroz@technion.ac.il) for better coordination of this effort.

## <a name="about-ssb">About the Star Schema Benchmark</a>

The Star Schema Benchmark is a modification of the [TPC-H benchmark](http://tpc.org/tpch/), which is the Transaction Processing Council's (older) benchmark for evaluating the performance of Database Management Systems (DBMSes) on analytic queries - that is, queries which do not modify the data.

The TPC-H has various known issues and deficiencies which are beyond the scope of this document. Researchers [Patrick O'Neil](http://www.cs.umb.edu/~poneil/), [Betty O'Neil](http://www.cs.umb.edu/~eoneil/) and [Xuedong Chen](https://www.linkedin.com/in/xuedong-chen-18414ba/), from the University of Massachusats Boston, proposed a modification of the TPC-H benchmark which addresses some of these shortcomings, in several papers, the latest and most relevant being [Star Schema Benchmark, Revision 3](http://www.cs.umb.edu/~poneil/StarSchemaB.PDF) published June 2009. One of the key features of the modifcation is the conversion of the [TPC-H schemata](http://kejser.org/wp-content/uploads/2014/06/image_thumb2.png) to Star Schemata ("Star Schema" is a misnomer), by some denormalizing as well as dropping some of the data; more details appear <a href="#difference-from-tpch">below</a> and even more details in the paper itself.

The benchmark was also accompanied by the initial versions of the code in this repository - a modified utility to generate schema data on which to run the benchmark.

For a recent discussion of the benchmark, you may wish to also read [A Review of Star Schema Benchmark](https://arxiv.org/pdf/1606.00295.pdf), by Jimi Sanchez.

## <a name="building">Building the generation utility</a>

The build process is not completely automated, unfortunately (an inheritance from the TPC-H dbgen utility), and comprises of two phases: Semi-manually generating a [Makefile](https://en.wikipedia.org/wiki/Makefile), then an automated build using that Makefile.

#### Generating a Makefile

Luckily, the Makefile is all-but-written for you, in the form of a template, [`makefile.suite`](https://github.com/eyalroz/ssb-dbgen/blob/master/makefile.suite). What remains for you to do is (assuming a non-Windows system):

1. Copy `makefile.suite` to `Makefile`
2. Set the values of the variables `DATABASE`, `MACHINE`, `WORKLOAD` and `CC`:

|Variable   |How to set it?   | List of options |
|-----------|-----------------|-----------------|
| `DATABASE`  | Use `DB2` if you can't tell what you should use; try one of the other options if that's the DBMS you're going to benchmark with  | `INFORMIX`, `DB2`, `TDAT`, `SQLSERVER`, `SYBASE` |
| `MACHINE`  | According to the platform/operating system you're using  | `ATT`, `DOS`, `HP`, `IBM`, `ICL`, `MVS`, `SGI`, `SUN`, `U2200`, `VMS`, `LINUX`, `MAC` |
| `WORKLOAD`  | Use `SSB`   | `SSB`, `TPCH`, `TPCR` (but better not try the last two)
| `CC`  |  Use the base name of your system's C compiler (assuming it's in the search path)  | N/A |

<!--2. Set the value of the  variable to `DB2` - or, if you know what you're doing and you have a specific reason to do so, to one of the other databases in the commented list of possibilities.
3. Set `MACHINE` to the value closest to your platform (mostly commonly it's either `LINUX`, or `MAC`; Windows users - see note below)
4. Set `WORKLOAD` to `SSB` (theoretically, `TPCH` might also work and generate TPC-H data, but don't count on it)
5. Set your C compiler invocation string - either the base name if it's on your search path (e.g. `CC=gcc`) or a full pathname otherwise. -->


**Notes:** Windows users will need to set additional variables (see `makefile.suite`).

#### Building using the Makefile

Your system should have the following software:

* GNU Make (which is standard on essentially all Unix-like systems today, specifically on Linux distributions), or Microsoft's NMake (which comes bundled with MS Visual Studio).
* A C language compiler (C99/C2011 support is not necessary) and linker. GNU's compiler collection (gcc) is know to work on Linux; and MSVC probably works on Windows. clang, ICC or others should be ok as well.

Now, simply execute `make -C /path/to/your/ssb-dbgen`; on Windows, you will need to be in the repository's directory and execute `nmake`. If you're in a terminal/command prompt session, the output should have several lines looking something like this:
```
gcc -O -DDBNAME=\"dss\" -DLINUX -DDB2  -DSSB    -c -o bm_utils.o bm_utils.c
```
and finally, the executable files `dbgen` and `qgen` (or `dbgen.exe` and `qgen.exe` on Windows) should now appear in the source folder.

## <a name="using">Using the utility to generate data</a>

The `dbgen` utility should be run from within the source folder (it can be run from elsewhere but you would need to specify the location of the `dists.dss` file). A typical invocation:

    $ ./dbgen -v -s 10
    
will create all tables in the current directory, with a scale factor of 10. This will have, for example, 300,000 lines in `customer.tbl`, beginning with something like:
```
1|Customer#000000001|j5JsirBM9P|MOROCCO  0|MOROCCO|AFRICA|25-989-741-2988|BUILDING|
2|Customer#000000002|487LW1dovn6Q4dMVym|JORDAN   1|JORDAN|MIDDLE EAST|23-768-687-3665|AUTOMOBILE|
3|Customer#000000003|fkRGN8n|ARGENTINA7|ARGENTINA|AMERICA|11-719-748-3364|AUTOMOBILE|
4|Customer#000000004|4u58h f|EGYPT    4|EGYPT|MIDDLE EAST|14-128-190-5944|MACHINERY|
```
the fields are separated by a pipe character (`|`), and there's a trailing pipe at the end of the line. 

After generating `.tbl` files for the CUSTOMER, PART, SUPPLIER, DATE and LINEORDER tables, you should now either load them directly into your DBMS, or apply some textual processing to them before loading.

**Note:** On Unix-like systems, it is also possible to write the generated data into a FIFO filesystem node, reading from the other side with a compression utility, so as to only write compressed data to disk. This may be useful of disk space is limited and you are using a particularly high scale factor.

<br>

## <a name="difference-from-tpch">Differences of the generated data from the TPC-H schema</a>


For a detailed description of the differences betwen SSB data and its distributions, as well as motivation for the differences, please read the SSB's epoynmous [paper](http://www.cs.umb.edu/~poneil/StarSchemaB.PDF).

In a nutshell, the differences are as follows:

1. Removed: Snowflake tables such as `NATION` and `REGION`
2. Removed: The `PARTSUPP` table
3. Denormalized/Removed: The `ORDERS` table - data is denormaized into `LINEORDER`
4. Expanded/Modified/Renamed: The fact table `LINEITEM` is now `LINEORDER`; many of its fields have been added/removed, including fields denormalized from the `ORDERS` table.
5. Added: A `DATE` dimension table
6. Modified: Removed and added fields in existing dimension tables (e.g. `SUPPLIER`)
7. `LINEORDER` now has data cross-reference for supplycost and revenue 

Also, refreshing is only applied to `LINEORDER`.

## <a name="trouble">Trouble building/running?</a>
Have you encountered some other issue with `dbgen` or `qgen`? Please open a new issue on the [Issues Page](https://github.com/eyalroz/ssb-dbgen/issues); be sure to list exactly what you did and enter a copy of the terminal output of the commands you used.


