def call(String gitUrl, String branchName) {
  echo "This is cloning the code!"
  git url: "${gitUrl}", branch: "${branchName}"
  echo "Code cloned successfully!!"
}
