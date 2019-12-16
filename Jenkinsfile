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
                sh "make IMAGE_TAG=${commit} UNSTABLE_IMAGE_SUFFIX=_unstable push-image"
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
