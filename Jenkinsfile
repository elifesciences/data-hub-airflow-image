elifePipeline {

    node('containers-jenkins-plugin') {
        def commit
        def image_repo = 'elifesciences/data-hub-with-dags'

        stage 'Checkout', {
            checkout scm
            commit = elifeGitRevision()
            commitShort = elifeGitRevision().substring(0, 8)
            branch = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
            timestamp = sh(script: 'date --utc +%Y%m%d.%H%M', returnStdout: true).trim()
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
                sh "make EXISTING_IMAGE_TAG=${commit} EXISTING_IMAGE_REPO=${image_repo} IMAGE_TAG=${branch}-${commitShort}-${timestamp} IMAGE_REPO=${dev_image_repo} retag-push-image"
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
