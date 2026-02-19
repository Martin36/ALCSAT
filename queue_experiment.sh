
EXPERIMENTS_FOLDER="/work/rleap1/martin.funkquist/experiments/ALCSAT"
REPO_FOLDER="/work/rleap1/martin.funkquist/ALCSAT"

ID=1 # ID of this particular set of experiments
# Search for an available ID
while [ -d "${EXPERIMENTS_FOLDER}/${ID}" ]
do
    ID=$(( ${ID} + 1 ))
done

mkdir -p "${EXPERIMENTS_FOLDER}/${ID}"
echo "Assigned ID: ${ID}"

EXPERIMENTS_FOLDER="${EXPERIMENTS_FOLDER}/${ID}"

queue_experiment () {
    local INPUT_FOLDER="$1"

    INPUT_FOLDER_NAME=$(basename "$INPUT_FOLDER")
    OUTPUT_FOLDER="$EXPERIMENTS_FOLDER/$INPUT_FOLDER_NAME"
    mkdir -p "$OUTPUT_FOLDER"

    pushd ${OUTPUT_FOLDER} > /dev/null

    echo "Queuing job for input folder: $INPUT_FOLDER"
    sbatch -J "ALCSAT-$INPUT_FOLDER_NAME" "$REPO_FOLDER/run_spell.sh" "$INPUT_FOLDER"

    popd > /dev/null
}

queue_experiment "$REPO_FOLDER/tests/C3"
queue_experiment "$REPO_FOLDER/tests/C3-2"
queue_experiment "$REPO_FOLDER/tests/C3-2-eq"
queue_experiment "$REPO_FOLDER/tests/C3-10-eq"
