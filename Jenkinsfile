elifePipeline {
    def DockerImage image

    node('containers-jenkins-plugin') {
        stage 'Checkout', {
            checkout scm
        }
        stage 'Build images', {
            sh 'docker build ./helm -t elifesciences/datahub-airflow'
            image = DockerImage.elifesciences(this, 'datahub-airflow', 'latest')
        }

        stage 'Push images', {
             latest = image.tag('latest').push()
        }
    }
}
