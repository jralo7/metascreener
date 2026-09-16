#!/usr/bin/env bash
# Emits, into the job-array script, the mapping from SLURM_ARRAY_TASK_ID (+ offset)
# to the contIni/contFin range that each array task must process.
#
# Expected variables (set by send_job_array in lanza_job.sh):
#   nRuns             -> items processed per task (chunk size)
#   array_resto       -> size of the last chunk (numFicheros % nRuns)
#   array_count       -> total number of tasks/chunks across the whole run
#   array_offset      -> index offset for this array submission (MaxArraySize split)
#   array_chunk_size  -> number of tasks in this array submission
echo "nRuns=${nRuns}"                                                       >>$name_template_job
echo "resto=${array_resto}"                                                 >>$name_template_job
echo "array_count=${array_count}"                                           >>$name_template_job
echo "ARRAY_OFFSET=${array_offset:-0}"                                       >>$name_template_job
echo "CHUNK_SIZE=${array_chunk_size}"                                       >>$name_template_job
echo ""                                                                     >>$name_template_job
echo "run_task() {"                                                         >>$name_template_job
echo "  TASK_ID=\$((\${SLURM_ARRAY_TASK_ID:-0} + ARRAY_OFFSET))"            >>$name_template_job
echo "  contIni=\$((TASK_ID * nRuns))"                                      >>$name_template_job
echo "  if [ \$resto -gt 0 ] && [ \$TASK_ID -eq \$((array_count - 1)) ]; then" >>$name_template_job
echo "    contFin=\$((contIni + resto))"                                    >>$name_template_job
echo "  else"                                                               >>$name_template_job
echo "    contFin=\$((contIni + nRuns))"                                    >>$name_template_job
echo "  fi"                                                                 >>$name_template_job
echo "}"                                                                    >>$name_template_job
echo ""                                                                     >>$name_template_job
