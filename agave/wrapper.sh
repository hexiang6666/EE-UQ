
set -x
WRAPPERDIR=$( cd "$( dirname "$0" )" && pwd )

${AGAVE_JOB_CALLBACK_RUNNING}

MODULESTOLOAD='${modules}'
for i in $(echo $MODULESTOLOAD | sed "s/,/ /g")
do
    module load "$i"
done

# just grab the filename if they dropped in the entire agave url (works if they didn't as well)
echo "inputScript is ${inputFile}"
INPUTFILE='${inputFile}'
INPUTFILE="${INPUTFILE##*/}"

echo "driver is ${driverFile}"
DRIVERFILE='${driverFile}'
DRIVERFILE="${DRIVERFILE##*/}"

# Run the script with the runtime values passed in from the job request
cd "${inputDirectory}"
pwd
ls -al
env

# make scripts executable in template dir and copy up the driver file
cd templatedir
chmod 'a+x' $DRIVERFILE
chmod 'a+x' dpreproSimCenter
cp $DRIVERFILE ../
cd ..

#run the exe
ibrun dakota -in $INPUTFILE -out dakota.out -err dakota.err

cd ..

if [ ! $? ]; then
        echo "dakota exited with an error status. $?" >&2
        ${AGAVE_JOB_CALLBACK_FAILURE}
        exit
fi