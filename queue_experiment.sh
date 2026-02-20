
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

queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_6/C3-6"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_7/C3-7"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_8/C3-8"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_9/C3-9"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_10/C3-10"

queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_6/C6-6"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_7/C6-7"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_8/C6-8"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_9/C6-9"
queue_experiment "$REPO_FOLDER/tests/gripper/gripper-atomic_10/C6-10"
