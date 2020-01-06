elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def k8s_gcp

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }
        stage 'Build image', {
            k8s_gcp = createK8sSecret('k8s_secret_name', 'k8s_secret_file_name', 'k8s_namespace', 'credentials', 'secret/containers/data-pipeline/gcp')
            sh "echo ${k8s_gcp}"
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
                sh "make IMAGE_TAG=${commit} IMAGE_SUFFIX=_unstable push-image"
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


def createK8sSecret(k8s_secret_name, k8s_secret_file_name, k8s_namespace, vault_field, vault_key) {
    def created_key

    try {
        sh 'echo  ${vault_field} ${vault_field} ${secret_file_name}'
        sh 'vault.sh kv get -field ${vault_field} ${vault_field} > ${secret_file_name}'
        created_key = k8s_secret_name
    }
    catch (e) {
        created_key = ''
    }
    finally {
        sh 'echo > ${secret_file_name}'
    }
    return created_key
}