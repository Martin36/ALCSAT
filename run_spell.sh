#!/bin/bash
#SBATCH --output=spell_job_%j.out
#SBATCH --error=spell_job_%j.err
#SBATCH --time=12:05:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8

# SLURM script for running SPELL DL concept learning
# Usage: sbatch run_spell.sh INPUT_FOLDER

echo "============================================"
echo "SPELL DL Concept Learning Job"
echo "Job ID: $SLURM_JOB_ID"
echo "Started at: $(date)"
echo "Running on node: $(hostname)"
echo "============================================"
echo ""

EXPERIMENTS_FOLDER="/work/rleap1/martin.funkquist/experiments/ALCSAT"

# Define input files
INPUT_FOLDER=$1
shift

OWL_FILE="$INPUT_FOLDER/background.owl"
POS_EXAMPLES="$INPUT_FOLDER/P.txt"
NEG_EXAMPLES="$INPUT_FOLDER/N.txt"

# Get the input file folder name
INPUT_FOLDER_NAME=$(basename "$INPUT_FOLDER")
OUTPUT_FOLDER="$EXPERIMENTS_FOLDER/$INPUT_FOLDER_NAME"
mkdir -p "$OUTPUT_FOLDER"
cd "$OUTPUT_FOLDER"

OUTPUT_FILE="log.txt"
SPARQL_OUTPUT="concept.sparql"

# SPELL parameters
LANGUAGE="alc"           # Options: el, el_alcsat, fl0, ex-or, all-or, elu, alc
MAX_SIZE=20             # Maximum concept size
TIMEOUT=43200            # Timeout in seconds (43,200 = 12 hours)

echo "Configuration:"
echo "  OWL file: $OWL_FILE"
echo "  Positive examples: $POS_EXAMPLES"
echo "  Negative examples: $NEG_EXAMPLES"
echo "  Language: $LANGUAGE"
echo "  Max size: $MAX_SIZE"
echo "  Timeout: ${TIMEOUT}s"
echo ""

# Activate Conda environment
source ~/.bashrc
conda activate /work/rleap1/martin.funkquist/conda/envs/ALCSAT

# Run SPELL
echo "Starting SPELL concept learning..."
echo "============================================"
python /work/rleap1/martin.funkquist/ALCSAT/spell_cli.py \
    --language "$LANGUAGE" \
    --max_size "$MAX_SIZE" \
    --timeout "$TIMEOUT" \
    --output "$SPARQL_OUTPUT" \
    "$OWL_FILE" \
    "$POS_EXAMPLES" \
    "$NEG_EXAMPLES" \
    2>&1 | tee "$OUTPUT_FILE"

EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo "============================================"
echo "Job finished at: $(date)"
echo "Exit code: $EXIT_CODE"
echo "============================================"

# Create a summary email body
EMAIL=martin.funkquist@liu.se
EMAIL_SUBJECT="SPELL Job $SLURM_JOB_ID - "
if [ $EXIT_CODE -eq 0 ]; then
    EMAIL_SUBJECT="${EMAIL_SUBJECT}Completed Successfully"
else
    EMAIL_SUBJECT="${EMAIL_SUBJECT}Failed (Exit code: $EXIT_CODE)"
fi

# Generate email body with results
EMAIL_BODY="/tmp/spell_email_${SLURM_JOB_ID}.txt"
cat > "$EMAIL_BODY" <<EOF
SPELL DL Concept Learning Results
==================================

Job ID: $SLURM_JOB_ID
Node: $(hostname)
Started: $(head -n 3 spell_job_${SLURM_JOB_ID}.out | tail -n 1 | cut -d: -f2-)
Finished: $(date)
Exit Code: $EXIT_CODE

Configuration:
--------------
OWL file: $OWL_FILE
Positive examples: $POS_EXAMPLES
Negative examples: $NEG_EXAMPLES
Language: $LANGUAGE
Max size: $MAX_SIZE
Mode: $MODE
Timeout: ${TIMEOUT}s

Results Summary:
----------------
EOF

# Append the actual results
if [ -f "$OUTPUT_FILE" ]; then
    echo "" >> "$EMAIL_BODY"
    echo "Full Output:" >> "$EMAIL_BODY"
    echo "============" >> "$EMAIL_BODY"
    cat "$OUTPUT_FILE" >> "$EMAIL_BODY"
else
    echo "WARNING: Output file not found!" >> "$EMAIL_BODY"
fi

if [ -f "$SPARQL_OUTPUT" ]; then
    echo "" >> "$EMAIL_BODY"
    echo "" >> "$EMAIL_BODY"
    echo "Generated SPARQL Query:" >> "$EMAIL_BODY"
    echo "=======================" >> "$EMAIL_BODY"
    cat "$SPARQL_OUTPUT" >> "$EMAIL_BODY"
fi

# Send email with results
mail -s "$EMAIL_SUBJECT" "$EMAIL" < "$EMAIL_BODY"

# Clean up temporary email file
rm -f "$EMAIL_BODY"

echo "Email sent to: $EMAIL"
echo "Results saved to: $OUTPUT_FILE"
if [ -f "$SPARQL_OUTPUT" ]; then
    echo "SPARQL query saved to: $SPARQL_OUTPUT"
fi

exit $EXIT_CODE
