elifePipeline {

    node('containers-jenkins-plugin') {
        def commit

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
        }
        stage 'Build image', {
            sh "make IMAGE_TAG=${commit} build-image"
            sh "make IMAGE_TAG=${commit} push-image"
        }
        elifeMainlineOnly {
            stage 'Push image', {
                sh "make IMAGE_TAG=${commit} push-image"
            }

            stage 'Merge to master', {
                elifeGitMoveToBranch commit, 'master'
            }
        }
    }
}
