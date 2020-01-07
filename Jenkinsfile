elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def k8s_gcp = 'gcp-credentials'
        def k8s_aws = 'credentials'
        def k8s_google_auth = 'google-auth'
        def deployment_namespace = 'default'

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }

        stage 'Build image', {
            sh "make IMAGE_TAG=${commit} build-image"
        }

        elifeMainlineOnly {
            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
            }

            stage 'Push image', {
                sh "make IMAGE_TAG=${commit} IMAGE_SUFFIX=_unstable push-image"
            }

            stage 'Create k8s secrets', {
                deployment_namespace = 'staging'
                createOverwriteK8sSecret(k8s_gcp, 'credentials.json', deployment_namespace, 'credentials', 'secret/containers/data-hub/gcp')
                createOverwriteK8sSecret(k8s_aws, 'credentials', deployment_namespace, 'credentials', 'secret/containers/data-hub/aws')
                createOverwriteK8sSecret(k8s_google_auth, 'AIRFLOW__GOOGLE__CLIENT_ID', deployment_namespace, 'client_id', 'secret/containers/data-hub/google-auth')
                addDataToK8sSecret(k8s_google_auth, 'AIRFLOW__GOOGLE__CLIENT_SECRET', deployment_namespace, 'client_secret', 'secret/containers/data-hub/google-auth')
            }

            stage 'Deploy image to k8s staging', {
                sh "make IMAGE_TAG=${commit} DEPLOYMENT_ENV=staging CREATED_AWS_K8S_SECRET=${k8s_aws} CREATED_G_APPLICATION_CRED_K8S_SECRET=${k8s_gcp} CREATED_GOOGLE_OAUTH_SECRET=${k8s_google_auth} IMAGE_SUFFIX=_unstable FORMULA_GIT_REPO_REF=f3e03f1 deploy-image-to-k8s"
            }
        }

        elifeTagOnly { tagName ->
            def candidateVersion = tagName - "v"

            stage 'Push release image', {
                sh "make IMAGE_TAG=latest push-image"
                sh "make IMAGE_TAG=candidateVersion push-image"
            }
        }

    }
}


def createOverwriteK8sSecret(k8s_secret_name, k8s_secret_file_name, k8s_namespace, vault_field, vault_key) {
    try {
        sh "vault.sh kv get -field ${vault_field} ${vault_key} > ${k8s_secret_file_name}"
        sh 'kubectl create secret generic ${k8s_secret_name} --from-file=${k8s_secret_file_name} --namespace ${k8s_namespace} --dry-run -o yaml |   kubectl apply -f -'
    }
    finally {
        sh "echo > ${k8s_secret_file_name}"
    }
}


def addDataToK8sSecret(k8s_secret_name, k8s_secret_file_name, k8s_namespace, vault_field, vault_key) {
    try {
        sh "vault.sh kv get -field ${vault_field} ${vault_key} > ${k8s_secret_file_name}"
        sh "kubectl get secret ${k8s_secret_name} -o json --namespace ${k8s_namespace}  | jq --arg b64_content \"\$(cat ${k8s_secret_file_name} | base64)\" '.data[\"${k8s_secret_file_name}\"]=\$b64_content'"
    }
    finally {
        sh "echo > ${k8s_secret_file_name}"
    }
}
