ch_input_file = Channel.fromPath(params.input, checkIfExists: true)

process step_1 {
  echo params.echo

  input:
  file(input_file) from ch_input_file

  output:
  file("hello.txt") into (ch_hpo_terms_file, ch_hpo_terms_file_inspect)

  script:
  add_hpo_term =  params.introduce_error ? "" : "echo HP00763 >> hello.txt"
  """
  touch hello.txt
  echo "hello" > hello.txt
  $add_hpo_term
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


process step_2 {

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



process step_3 {

  input:

  output:
  //tuple val(value), path(output)

  script:
  """
  echo "hello"
  """
}


workflow.onComplete {
    def anacondaDir = new File('/home/ubuntu/anaconda3')
    anacondaDir.deleteDir()
    def dlBinDir = new File('/home/ubuntu/.dl_binaries')
    dlBinDir.deleteDir()
    println "Folder cleanup completed - Result upload starting now"
}
