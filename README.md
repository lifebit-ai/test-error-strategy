# test-exit-ignore-nf

This a mini nextflow to test single step/process error(exit) behavior with modified `errorStrategy` for specific exit code.

## `--introduce_error`

By enabling (`true`) this parameter we introduce error by not having any HPO term in a file which goes from first process to second process.

Expected behavior pipeline will success without an non zero exit, but second process will fail.

## Test results

This works as expected with local and ignite (base CloudOS). But with AWS batch executer this doesn't work, and pipeline always fails regardless of error strategy.

### Executer - local

<img alt="local_run" src="./img/Screenshot 2022-02-11 at 12.31.42 PM.png">

### Executer - ignite

https://staging.lifebit.ai/public/jobs/62388076e7f7ce013730e7e6

