ch_input_file = Channel.fromPath(params.input, checkIfExists: true)

process test_nf {
  echo true
  container 'quay.io/lifebitai/cloudos-cli:0.0.2'

  input:
  file(input_file) from ch_input_file

  output:
  file("hello.txt") into (ch_hpo_terms_file, ch_hpo_terms_file_inspect)

  script:
  """
  touch hello.txt
  echo "hello" > hello.txt
  echo "###########"
  echo "storage size where this process is running"
  df -h
  head $input_file
  """
}

ch_hpo_terms_file_inspect.dump(tag:'ch_hpo_terms (txt file)')
ch_hpo_terms = ch_hpo_terms_file
                  .splitCsv(sep: ',', skip: 1)
                  .unique()
                  .map {it -> it.toString().replaceAll("\\[", "").replaceAll("\\]", "")}
                  .map {it -> "'"+it.trim()+"'"}
                  .reduce { a, b -> "$a,$b" }

(ch_hpo_terms, ch_hpo_terms_inspect) = ch_hpo_terms.into(2)
ch_hpo_terms_inspect.dump(tag:'ch_hpo_terms (tokenised string)')


process test_nf_2 {

  input:
  val(hpo_terms) from ch_hpo_terms

  output:
  //tuple val(value), path(output)

  script:
  """
  echo $hpo_terms
  HPO_TERMS="$hpo_terms"
  if [[ "\${HPO_TERMS}" == "null" ]]; then
    echo "ERROR: No HPO terms found"
    exit 203
  fi
  """
}



process test_nf_3 {

  input:

  output:
  //tuple val(value), path(output)

  script:
  """
  echo "hello"
  """
}


// Completion notification

// workflow.onComplete {
//     def work_dir = workflow.workDir
//     println "Workflow dir - $work_dir"
//     if(workflow.success) work_dir.deleteDir() println "Successfully finished"
// }
