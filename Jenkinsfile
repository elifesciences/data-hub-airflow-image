elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def image_repo = 'elifesciences/data-hub-with-dags'
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
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=${commit} IMAGE_REPO=${dev_image_repo} retag-push-image"
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=latest IMAGE_REPO=${dev_image_repo} retag-push-image"
            }

        }

        elifeTagOnly { tagName ->
            def candidateVersion = tagName - "v"

            stage 'Push release image', {
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=latest IMAGE_REPO=${image_repo} retag-push-image"
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=${candidateVersion} IMAGE_REPO=${image_repo} retag-push-image"
            }
        }

    }
}
