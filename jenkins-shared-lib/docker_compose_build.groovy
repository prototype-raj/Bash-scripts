def call(){
  echo "This is deploying the code!"
  sh "docker compose up -d"
}
