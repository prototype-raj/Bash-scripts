def call(String applicationName, String tagName) {
  echo "This is building the code!"
  sh "docker build -t ${applicationName}:${tagName} ." 
}
