# unique identifier for the job (the span server supports multiple jobs at once)
jobid="$RANDOM"

cd vw-tutorial
cd sharded-files

njobs=$(nproc)

# use gnu parallel to generate commands

cmd="vw --bit_precision 24 --loss_function logistic"
# cmd="$cmd --kill_cache --cache --passes 10"
cmd="$cmd -q :: --l2 1e-6 --l1 1e-6 --hash all --holdout_off"
cmd="$cmd --node {} --unique_id ${jobid} "
cmd="$cmd --span_server localhost --total ${njobs}"

start=$(date +%s.%N)
# only ask the head node to persist the model
seq -f "%02g" 0 $(($njobs - 1)) | parallel --lb '
  if [ {} -eq 0 ] ; then
      extra_args="--final_regressor parallel.model"
  fi
  echo "node {} reporting for duty"
  '"$cmd"' train.vw.{} ${extra_args} 2>/dev/null'
end=$(date +%s.%N)

dt=$(echo "$end - $start" | bc)
echo "train_sec $dt"
