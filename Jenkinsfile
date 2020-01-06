elifePipeline {

    node('containers-jenkins-plugin') {
        def commit

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
