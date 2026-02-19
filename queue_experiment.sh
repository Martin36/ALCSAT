
EXPERIMENTS_FOLDER="/work/rleap1/martin.funkquist/experiments/ALCSAT"
INPUT_FOLDER=/work/rleap1/martin.funkquist/ALCSAT/tests/C3
INPUT_FOLDER_NAME=$(basename "$INPUT_FOLDER")
OUTPUT_FOLDER="$EXPERIMENTS_FOLDER/$INPUT_FOLDER_NAME"
mkdir -p "$OUTPUT_FOLDER"
pushd ${OUTPUT_FOLDER} > /dev/null
sbatch -J "ALCSAT-C3" run_spell.sh "$INPUT_FOLDER"
popd > /dev/null
