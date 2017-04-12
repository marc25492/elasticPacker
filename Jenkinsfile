#!groovy

node {

  def err = null
  currentBuild.result = "SUCCESS"

  try { 
    stage 'Checkout'
      checkout scm

    stage 'Validate'
      def packer_file = 'elasticClusterAmazonLinux.json'
      print "Running packer validate on : ${packer_file}"
      sh "/usr/local/packer validate ${packer_file}" 

    stage 'Build'
    withCredentials(
      [
        [$class: 'StringBinding', credentialsId: 'AWS_ACCESS_KEY', variable: 'AWS_ACCESS_KEY'],
        [$class: 'StringBinding', credentialsId: 'AWS_SECRET_KEY', variable: 'AWS_SECRET_KEY']
      ])
    {
      sh "/usr/local/packer build -var 'aws_access_key=$AWS_ACCESS_KEY' -var 'aws_secret_key=$AWS_SECRET_KEY' ${packer_file}" 
    }

    stage 'Test'
      print "Testing goes here."
  } 

  catch (caughtError) {
    err = caughtError
    currentBuild.result = "FAILURE"
  }

  finally {
    /* Must re-throw exception to propagate error */
    if (err) {
      throw err
    }
  }
}
