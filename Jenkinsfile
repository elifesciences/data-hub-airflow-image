elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def image_repo = 'elifesciences/data-hub-with-dags'
        def deployment_env = 'staging'
        def deployment_namespace = 'data-hub'
        def deployment_formula_ci_pipeline = 'elife-data-hub-formula'


        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }

        stage 'Build image', {
            sh "make IMAGE_TAG=${commit} build-image"
        }

        elifeMainlineOnly {

            def dev_image_repo = image_repo + '_unstable'

            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
            }

            stage 'Push image', {
                sh "make IMAGE_TAG=${commit} IMAGE_REPO=${dev_image_repo} create-push-image"
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=${commit} IMAGE_REPO=${dev_image_repo} retag-push-image"
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=latest IMAGE_REPO=${dev_image_repo} retag-push-image"
            }

            stage 'Deploy image to k8s staging', {
                triggerDeployment(deployment_formula_ci_pipeline, dev_image_repo, commit , deployment_env, deployment_namespace)
            }

        }

        elifeTagOnly { tagName ->
            def candidateVersion = tagName - "v"
            deployment_env = 'prod'

            stage 'Push release image', {
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=latest IMAGE_REPO=${image_repo} retag-push-image"
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=${candidateVersion} IMAGE_REPO=${image_repo} retag-push-image"
            }

            stage 'Deploy image to k8s prod', {
                triggerDeployment(deployment_formula_ci_pipeline, image_repo, candidateVersion, deployment_env, deployment_namespace)
            }
        }

    }
}


def triggerDeployment(deployment_formula_ci_pipeline,image_repo, image_tag, deployment_env, deployment_namespace ){
    build job: deployment_formula_ci_pipeline,  wait: false, parameters: [string(name: 'imageRepo', value: image_repo), string(name: 'imageTag', value: image_tag), string(name: 'deploymentEnv', value: deployment_env), string(name: 'deploymentNamespace', value: deployment_namespace) ]
}
