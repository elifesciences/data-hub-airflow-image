elifePipeline {
    def DockerImage image

    node('containers-jenkins-plugin') {
        stage 'Checkout', {
            checkout scm
        }
        stage 'Build images', {
            sh 'docker build ./helm -t elifesciences/data-hub-airflow'
            image = DockerImage.elifesciences(this, 'data-hub-airflow', 'latest')
        }

        stage 'Push images', {
             latest = image.tag('latest').push()
        }
    }
}
