elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def image_repo = 'elifesciences/data-hub-with-dags'
        def image_tag = 'develop'
        def deployment_env = 'staging'
        def deployment_namespace = 'data-hub'

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }



        stage 'Deploy image to k8s staging', {
            triggerDeployment(dev_image_repo, image_tag, deployment_env, deployment_namespace)
        }


        elifeTagOnly { tagName ->
            def candidateVersion = tagName - "v"
            deployment_env = 'prod'

            stage 'Push release image', {
                sh "make IMAGE_TAG=latest  IMAGE_REPO=${image_repo}  push-image"
                sh "make IMAGE_TAG=candidateVersion IMAGE_REPO=${image_repo}  push-image"
            }

            stage 'Deploy image to k8s prod', {
                triggerDeployment(image_repo, candidateVersion, deployment_env, deployment_namespace)
            }
        }

    }
}


def triggerDeployment(image_repo, image_tag, deployment_env, deployment_namespace ){
    build job: 'data-hub-k8s-deployment', wait: false, parameters: [string(name: 'imageRepo', value: image_repo), string(name: 'imageTag', value: image_tag), string(name: 'deploymentEnv', value: deployment_env), string(name: 'deploymentNamespace', value: deployment_namespace) ]
}
