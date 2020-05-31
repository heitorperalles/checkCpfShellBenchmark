# checkCpfShellBenchmark

Benchmark solution to compare performance between "checkCpf_" applications.<br>
A Shell/Bash script that manages calls to the binaries and APIs using libCurl ([curl.haxx.se](https://curl.haxx.se)).

The input of all tested solutions is a CPF (Brazilian Physical Person Register) to be checked.<br>
This CPF is validated on SERPRO (Brazilian Federal Data Processing Service) RESTful API by each solution.<br>

Two kinds of software are being tested: RESTful APIs and Command line tools.

**Command line tools - Direct calls to each binary:**

* **Curl:** The libCurl compiled binary [github.com/curl](https://github.com/curl/curl)
* **checkCpfGo:** Pure GO solution [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfGo)
* **checkCpfCxx:** C++ solution using libCurl shared library [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfCxx)

**RESTful API solutions - Requests to each API forwarded to libCurl compiled binary:**

* **checkCpfRestApiGo:** Pure GO solution [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfRestApiGo)
* **checkCpfRestApiGoBind:**  GO solution using libCurl shared library [github.com/heitorperalles](https://github.com/heitorperalles/check**CpfRestApiGoBind)
* **checkCpfRestApiGoExec:** GO solution calling libCurl binary [github.com/heitorperalles](https://github.com/heitorperalles/check**CpfRestApiGoExec)
* **checkCpfRestApiGoCgo:** GO and C solution integrated by CGO and using libCurl shared library [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfRestApiGoCgo)
* **checkCpfRestApiGoCxxWrap:** GO and C++ solution integrated by CGO and using libCurl shared library [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfRestApiGoCxxWrap)
* **checkCpfRestApiGoCxxSwig:** GO and C++ solution integrated by SWIG and using libCurl shared library [github.com/heitorperalles](https://github.com/heitorperalles/checkCpfRestApiGoCxxSwig)

**Important considerations about the tests**

* The GO, C and C++ solutions scopes are similar, but not exactly the same.
* The Curl binary just return the received response, while GO and C++ solutions treat this data.
* The binary calls intervals counts the time to arise the process, while the REST API requests are made with the service already started.
* There is no error treatment on the script, so a problem during a request will cause some noise at the result.

## Instructions (on Linux)

### Check the Shell

This script was tested with GNU **bash** version `5.0.16`. To check the version of BASH, run:
```bash
bash --version
```

### Install the command-line tool Curl

``` bash
sudo apt-get install curl
```
This application was tested with CURL release `7.68.0`. To check the installed version of CURL, run:
```bash
curl --version
```

### Download the Source codes

Download the sources of all "checkCpf_" solutions. For example:

```bash
git clone git@github.com:heitorperalles/checkCpfGo
git clone git@github.com:heitorperalles/checkCpfCxx
git clone git@github.com:heitorperalles/checkCpfRestApiGo
git clone git@github.com:heitorperalles/checkCpfRestApiGoBind
git clone git@github.com:heitorperalles/checkCpfRestApiGoExec
git clone git@github.com:heitorperalles/checkCpfRestApiGoCgo
git clone git@github.com:heitorperalles/checkCpfRestApiGoCxxWrap
git clone git@github.com:heitorperalles/checkCpfRestApiGoCxxSwig
```

### Compile and test the solutions

Read the instructions of each solution to compile them.

It will be necessary install some softwares, for example:<br>
GO compiler, g++, SWIG, libCurl for development, Go-Curl library, Gorilla/Mux library, and more.

Compile the solutions, and run its automated tests if possible.

### Set the Configuration file

There is a file named `config` with all necessary parameters to run.<br>
This file cames with default values, and if all projects be installed at the same root folder, nothing needs to be done.

### Run the Benchmark script
```bash
./checkCpfShellBenchmark.sh
```
Note: All applications uses a service provided by SERPRO, so any test depends on this service being online.<br>

### Check the Results

A complete log of all executions will be printed. <br>

At the end, a summary will also be printed, for example:

```
Results for 2 calls:
[curl]                       AVG: 421ms, MIN: 410ms, MAX: 433ms
[checkCpfGo]                 AVG: 612ms, MIN: 588ms, MAX: 636ms
[checkCpfCxx]                AVG: 438ms, MIN: 438ms, MAX: 439ms
[checkCpfRestApiGo]          AVG: 438ms, MIN: 426ms, MAX: 451ms
[checkCpfRestApiGoBind]      AVG: 422ms, MIN: 422ms, MAX: 422ms
[checkCpfRestApiGoExec]      AVG: 476ms, MIN: 445ms, MAX: 508ms
[checkCpfRestApiGoCgo]       AVG: 528ms, MIN: 434ms, MAX: 622ms
[checkCpfRestApiGoCxxWrap]   AVG: 400ms, MIN: 392ms, MAX: 409ms
[checkCpfRestApiGoCxxSwig]   AVG: 400ms, MIN: 379ms, MAX: 422ms
```
And a CSV file called `checkCpfShellBenchmark.csv` will be generated with all structured information.

## More Configuration

### Paths:

The paths of each binary must be specified.<br>
They must be set considering the relative path from the current directory.

### Delays:

A delay (in seconds) is specified to wait a time between successive calls.<br>
This delay is necessary to avoid servers flood (some servers doesn't allow more than 60 requests per minute, for example).

### Amount:

This parameters sets how many times each solution will be called.<br>
The greater the number of requests, the more assertive the average will be.

### CSV output

Its possible to change the name (or path) of the output CSV file.

### Input CPF:

The CPFs provided by SERPRO for testing are:

```
40442820135: Regular (Register OK)
63017285995: Regular (Register OK)
91708635203: Regular (Register OK)
58136053391: Regular (Register OK)
40532176871: Suspended (Problem with the registry)
47123586964: Suspended (Problem with the registry)
07691852312: Regularization Pending (Problem with the registry)
10975384600: Regularization Pending (Problem with the registry)
01648527949: Canceled by Multiplicity (Problem with the registry)
47893062592: Canceled by Multiplicity (Problem with the registry)
98302514705: Null (Problem with the registry)
18025346790: Null (Problem with the registry)
64913872591: Registration Canceled (Problem with the registry)
52389071686: Registration Canceled (Problem with the registry)
05137518743: Deceased Holder (Problem with the registry)
08849979878: Deceased Holder (Problem with the registry)
```

There is a parameter to choose which CPF will be used.<br>
A real CPF might also be used (will return a Not Found error)

### API Credentials:

The application is configured with a personal TOKEN, please change it.<br>
Its possible to generate a new TOKEN on SERPRO service page: [servicos.serpro.gov.br](https://servicos.serpro.gov.br/inteligencia-de-negocios-serpro/biblioteca/consulta-cpf/teste.html).

The SERPRO token and URL are specified on the `config` file.

Attention: This credentials are only used during script `curl` call, not inside each binary.<br>
To change the credentials of the "checkCpf_" binaries please check their documentation.

## Implementation

### File structure

The application is composed by a set of source code files:

**config** : Configuration file.<br>

**checkCpfShellBenchmark.sh** : Main script file.<br>

**README.md** : This file, explaining how the application works.<br>

**.gitignore** : List of non-versioned files (such as the compiled binary).

After the compilation process, the non-versioned output file `checkCpfShellBenchmark.csv` will be generated.

### Author

Heitor Peralles<br>
[heitorgp@gmail.com](mailto:heitorgp@gmail.com)<br>
[linkedin.com/in/heitorperalles](https://www.linkedin.com/in/heitorperalles)

### Source

[github.com/heitorperalles/checkCpfShellBenchmark](https://www.github.com/heitorperalles/checkCpfShellBenchmark)

### License

MIT licensed. See the **LICENSE** file for details.
