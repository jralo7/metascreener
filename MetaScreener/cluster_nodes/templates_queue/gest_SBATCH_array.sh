#!/usr/bin/env bash
# Builds a single SLURM job-array script that runs every chunk of the experiment
# as an array task (one task per chunk), instead of submitting one job per chunk.
#
# Expected variables (set by send_job_array in lanza_job.sh):
#   array_index_max  -> highest 0-based task index for THIS array submission
#   array_offset     -> global task offset for THIS array submission
#   array_chunk_size -> number of tasks in THIS array submission
#   array_count      -> total number of tasks across the whole run
#   array_resto      -> size of the last chunk (numFicheros % nRuns)
echo "#!/bin/sh"                                                >$name_template_job
if [ "$renice" != "N/A" ];then
	echo "#SBATCH --nice=$renice"						>>$name_template_job
fi
if [ "${GPU}" != "N/A" ];then
	echo "#SBATCH --gres=gpu:${GPU}" 					>>$name_template_job
fi
if [ "${mem}" != "N/A" ];then
	# If user passed a plain number, interpret it as GB for Slurm
	if [[ "${mem}" =~ ^[0-9]+$ ]]; then
		echo "#SBATCH --mem=${mem}G" 						>>$name_template_job
	else
		echo "#SBATCH --mem=${mem}" 						>>$name_template_job
	fi
fi
if [ "$project" != "N/A" ];then
	echo ${queue_direc_project}${project}				>>$name_template_job
fi

# Use '%A-%a' (array-master-id - task-id) so per-task .err files keep the '*-*.err'
# shape expected by extra_metascreener/used_by_metascreener/get_time_resume.sh.
echo "#SBATCH --output=${folder_out_jobs}%A-%a.out"    >>$name_template_job
echo "#SBATCH --error=${folder_out_jobs}%A-%a.err"    >>$name_template_job
echo "#SBATCH -p "${queue}>>$name_template_job
echo "#SBATCH -J ${name_job}"							>>$name_template_job
echo "#SBATCH --time=$time_job"							>>$name_template_job
echo "#SBATCH --cpus-per-task=$cores"						>>$name_template_job
echo "#SBATCH --nodes=${nodos}"							>>$name_template_job
if [ -n "${array_throttle}" ] && [ "${array_throttle}" != "N/A" ];then
	echo "#SBATCH --array=0-${array_index_max}%${array_throttle}"	>>$name_template_job
else
	echo "#SBATCH --array=0-${array_index_max}"			>>$name_template_job
fi
source ${path_cluster_nodes}templates_queue/array_range.sh
source ${path_cluster_nodes}templates_queue/codigo_array.sh
