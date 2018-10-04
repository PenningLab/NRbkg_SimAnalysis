#!/bin/bash
MYDIR=/global/project/projectdirs/lz/users/lkorley/HighNR
INDIR=${MYDIR}/output
source /cvmfs/lz.opensciencegrid.org/BACCARAT/release-3.14.3/setup.sh
MAKELISTS=0

if ls ${MYDIR}/lists/*list.txt 1> /dev/null 2>&1; then
	if [ ! -f ${MYDIR}/lists/processlist.txt ] && [ ! -f ${MYDIR}/lists/creatorlist ]; then
		/cvmfs/sft.cern.ch/lcg/external/Python/2.7.4/x86_64-slc6-gcc48-opt/bin/python2.7 ${MYDIR}/src/cleanup.py "${MYDIR}/lists"
	fi
	echo "Will plot process rates as well as overall rates"
else
	if [ ! -d  ${MYDIR}/lists ]; then
		mkdir ${MYDIR}/lists
	fi
	MAKELISTS=1
	echo "No Process lists found in ${MYDIR}/lists"
	echo "Will Plot overall rates only and create these lists in ${MYDIR}/lists for you"
	echo "On your next run of this script process rates will be plotted"
fi

cd ${INDIR}
for f in *
do
	if ls ${f}/*SpectrumData.root 1> /dev/null 2>&1; then
		echo "${f} is a good boy"
	else
	        echo "${f} is a naughty one"
		continue
	fi
	OUTDIR=${INDIR}/${f}/Plots
	if [ ! -d ${OUTDIR} ]; then
		mkdir ${OUTDIR}
	fi
	FileList=""
	for flow in ${f}/*SpectrumData.root
	do
	    if [ $1 -eq 0 ]; then
		if [ "${FileList}" != "" ]; then
		    FileList=${FileList},${INDIR}/${flow}
		else
		  FileList=${INDIR}/${flow}
		fi
	    else
		sbatch --mem=6G --job-name=${f} --output=${MYDIR}/sh_out/${f}.%j.out --error=${MYDIR}/sh_out/${f}.%j.err ${MYDIR}/NRint.slr ${MYDIR}/src/plotrates.py "PlotChains" "${INDIR}/${flow}" "${OUTDIR}" "cluster" ${MAKELISTS}
	    fi
	done
	if [ $1 -eq 0 ]; then
	    echo "Running plotter with file list: ${FileList}"
	    /cvmfs/sft.cern.ch/lcg/external/Python/2.7.4/x86_64-slc6-gcc48-opt/bin/python2.7 ${MYDIR}/src/plotrates.py "PlotChains" "${FileList}" "${OUTDIR}" "${f}" ${MAKELISTS}
	fi
done
cd ${MYDIR}
