elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def k8s_gcp
        def k8s_aws
        def k8s_google_auth
        def deployment_namespace = 'default'


        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }
        stage 'Build image', {
                deployment_namespace = 'staging'
                k8s_gcp = UpsertK8sSecret('gcp-credentials', 'credentials.json', deployment_namespace, 'credentials', 'secret/containers/data-hub/gcp')
                k8s_aws = UpsertK8sSecret('credentials', 'credentials', deployment_namespace, 'credentials', 'secret/containers/data-hub/aws')
                k8s_google_auth = UpsertK8sSecret('google-auth', 'AIRFLOW__GOOGLE__CLIENT_ID', deployment_namespace, 'client_id', 'secret/containers/data-hub/google-auth')
                k8s_google_auth = UpsertK8sSecret('google-auth', 'AIRFLOW__GOOGLE__CLIENT_SECRET', deployment_namespace, 'client_secret', 'secret/containers/data-hub/google-auth')
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
                k8s_gcp = UpsertK8sSecret('gcp-credentials', 'credentials.json', deployment_namespace, 'credentials', 'secret/containers/data-hub/gcp')
                k8s_aws = UpsertK8sSecret('credentials', 'credentials', deployment_namespace, 'credentials', 'secret/containers/data-hub/aws')
                k8s_google_auth = UpsertK8sSecret('google-auth', 'AIRFLOW__GOOGLE__CLIENT_ID', deployment_namespace, 'client_id', 'secret/containers/data-hub/google-auth')
                k8s_google_auth = UpsertK8sSecret('google-auth', 'AIRFLOW__GOOGLE__CLIENT_SECRET', deployment_namespace, 'client_secret', 'secret/containers/data-hub/google-auth')
            }

            stage 'Deploy image to k8s staging', {
                sh "make IMAGE_TAG=${commit} DEPLOYMENT_ENV=staging IMAGE_SUFFIX=_unstable FORMULA_GIT_REPO_REF=f3e03f1 deploy-image-to-k8s"
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


def UpsertK8sSecret(k8s_secret_name, k8s_secret_file_name, k8s_namespace, vault_field, vault_key) {
    def created_key

    try {
        sh "echo  ${vault_field} ${vault_key} ${k8s_secret_file_name}"
        sh "vault.sh kv get -field ${vault_field} ${vault_key} > ${k8s_secret_file_name}"
        sh "echo '{\"name\": \"George\",\"id\": 12,\"email\": \"george@domain.com\"}' |  jq -r . | jq --arg b64_content \"\$(cat ${k8s_secret_file_name} | base64)\" '.data[${k8s_secret_file_name}]=\$b64_content'"

        created_key = k8s_secret_name
    }
    catch (e) {
        created_key = ""
    }
    finally {
        sh "echo > ${k8s_secret_file_name}"
    }
    return created_key
}