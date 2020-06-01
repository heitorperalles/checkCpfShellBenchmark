# ------------------------------------------------------------------------------
# From http://github.com/heitorperalles/checkCpfShellBenchmark
#
# Distributed under The MIT License (MIT) <http://opensource.org/licenses/MIT>
#
# Copyright (c) 2020 Heitor Peralles <heitorgp@gmail.com>
#
# Permission is hereby  granted, free of charge, to any  person obtaining a copy
# of this software and associated  documentation files (the "Software"), to deal
# in the Software  without restriction, including without  limitation the rights
# to  use, copy,  modify, merge,  publish, distribute,  sublicense, and/or  sell
# copies  of  the Software,  and  to  permit persons  to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS  IS", WITHOUT WARRANTY  OF ANY KIND,  EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT  LIMITED TO  THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR  A PARTICULAR PURPOSE AND  NONINFRINGEMENT. IN NO EVENT  SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE  LIABLE FOR  ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF  CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE  OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ------------------------------------------------------------------------------
echo "Welcome to [checkCpf]* Benchmark!"
echo "First step: reading configuration file (./config)..."

BASEDIR=$(cd `dirname $0` && pwd)
echo "Current directory: "$BASEDIR

source ${BASEDIR}/config

declare -A AVG
declare -A MIN
declare -A MAX

declare -a commandLineTools=(
	curl
	checkCpfGo
	checkCpfC
	checkCpfCxx
)

declare -a restApiApplications=(
	checkCpfRestApiGo
	checkCpfRestApiGoBind
	checkCpfRestApiGoExec
	checkCpfRestApiGoCgo
	checkCpfRestApiGoCxxWrap
	checkCpfRestApiGoCxxSwig
)

echo "-------------------------------------------------------------"

echo -n "Benchmark at "$(date) > ${reportFile}
for ((request=1; request<=amountOfRequests; request++)); do	echo -n ", Run ${request}" >> ${reportFile}; done
echo -n ", AVG, MIN, MAX" >> ${reportFile}
echo "" >> ${reportFile}

for binary in ${commandLineTools[*]} ${restApiApplications[*]}
do
	if [[ $binary == *curl* ]]
	then
		binaryFullPath=$(which curl)
		echo "[${binary}] binary full path: " ${binaryFullPath}
	else
		binaryPath=${binary}"Path"
		binaryFullPath=${BASEDIR}/${!binaryPath}
		echo "[${binary}] binary full path: " ${binaryFullPath}
	fi

	echo "Killing any ${binary} remaining process..."
	pkill -9 ${binary}

	echo "Running ${binary}..."
	echo "-------------------------------------------------------------"

	AVG[${binary}]=0
	MIN[${binary}]=999999999999
	MAX[${binary}]=0

	echo -n "${binary}" >> ${reportFile}

	if [[ $binary == *RestApi* ]]
	then
		echo "Starting API routing..."
		$binaryFullPath &
		sleep 3 # Waiting some time to the API arise
	fi

	for ((request=0; request<amountOfRequests; request++))
	do
		echo "Call [$(($request+1))] ${binary}..."
		start=$(date +%s%3N)

		if [[ $binary == *RestApi* ]]
		then
			curl localhost:8000/api/v1/verify -i -X POST -d '{"cpf":"'${CPF}'}"}'
		elif [[ $binary == *curl* ]]
		then
			curl ${serproURL}${CPF} -H "Authorization: Bearer ${serproTOKEN}" -X "GET" -w "\n"
		else
			$binaryFullPath $CPF # Command line tool execution
		fi

		delta=$(($(date +%s%3N)-$start))
		echo "Call [$(($request+1))] ${binary} took [$delta] milliseconds"
		echo -n ",${delta}" >> ${reportFile}
		AVG[${binary}]=$((${AVG[${binary}]}+$delta))
		MIN[${binary}]=$((${MIN[${binary}]}<$delta?${MIN[${binary}]}:$delta))
		MAX[${binary}]=$((${MAX[${binary}]}>$delta?${MAX[${binary}]}:$delta))
		echo "-------------------------------------------------------------"
		sleep ${sleepTime} # Waiting 1 second to avoid server flood
	done

	AVG[${binary}]=$((${AVG[${binary}]}/$amountOfRequests))

	echo "${binary} AVG: " ${AVG[${binary}]} " milliseconds"
	echo "${binary} MIN: " ${MIN[${binary}]} " milliseconds"
	echo "${binary} MAX: " ${MAX[${binary}]} " milliseconds"

	echo -n ",${AVG[${binary}]}"  >> ${reportFile}
	echo -n ",${MIN[${binary}]}"  >> ${reportFile}
	echo -n ",${MAX[${binary}]}" >> ${reportFile}
	echo "" >> ${reportFile}
	echo "-------------------------------------------------------------"
done

echo "Results for" ${amountOfRequests} "calls:"
for binary in ${commandLineTools[*]} ${restApiApplications[*]}
do
		printf "%-27s %s%d%s%d%s%d%s\n" "["${binary}"]" " AVG: " ${AVG[${binary}]} "ms, MIN: " ${MIN[${binary}]} "ms, MAX: " ${MAX[${binary}]} "ms"
done
echo "-------------------------------------------------------------"
echo "Full information recorded on ${reportFile}"

exit 0
