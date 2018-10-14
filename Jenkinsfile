timestamps {

 node () {

  stage ('checkout repository') {
   checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GitHub_User', url: 'https://github.com/oktacon95/logstash']]]) 
  }
  stage ('build docker image') {
   sh 'docker build -t mylogstash --build-arg GEMS="logstash-filter-cpu_temp" .'
  }
  stage ('stop old docker image') {
   sh "docker stop logstash" 
  }
  stage ('create new docker container') {
   sh 'docker run -d --rm --name logstash --network elknet -p 9600:9600 -p 5044:5044 -v /etc/logstash/conf.d:/etc/logstash/conf.d -v /etc/logstash/config/logstash.yml:/opt/logstash/config/logstash.yml mylogstash'
  }
 }
}
