alias a=aws

ause() {
  export AWS_SDK_LOAD_CONFIG=1
  export AWS_PROFILE="${1?}"
}

