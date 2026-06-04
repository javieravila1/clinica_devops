pipeline {
agent any

```
environment {
    APP_NAME       = 'clinica-paliativos'
    SONAR_TOKEN    = credentials('sonar-token')
    SONAR_HOST_URL = 'http://sonarqube:9000'
    ZAP_TARGET_URL = 'http://paliativos-web:5000'
    DOCKER_NETWORK = 'proyecto_final_new_default'
}

stages {

    stage('Checkout') {
        steps {
            checkout scm
        }
    }

    stage('Install Dependencies') {
        steps {
            sh '''
            mkdir -p reports
            pip install --break-system-packages \
            -r requirements.txt \
            -r requirements-dev.txt
            '''
        }
    }

    stage('Unit Tests') {
        steps {
            sh '''
            python -m pytest tests/ -v \
            --junitxml=reports/junit.xml \
            --cov=utils \
            --cov-report=xml:reports/coverage.xml \
            --cov-report=html:reports/htmlcov
            '''
        }

        post {
            always {
                junit 'reports/junit.xml'

                publishHTML([
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports/htmlcov',
                    reportFiles: 'index.html',
                    reportName: 'Coverage Report'
                ])
            }
        }
    }

    stage('SonarQube Analysis') {
        steps {
            sh """
            sonar-scanner \
            -Dsonar.projectKey=${APP_NAME} \
            -Dsonar.sources=. \
            -Dsonar.python.coverage.reportPaths=reports/coverage.xml \
            -Dsonar.python.xunit.reportPath=reports/junit.xml \
            -Dsonar.host.url=${SONAR_HOST_URL} \
            -Dsonar.token=${SONAR_TOKEN} \
            -Dsonar.exclusions=**/tests/**,**/*.html,**/static/**
            """
        }
    }

    stage('Build Docker Image') {
        steps {
            sh '''
            docker build \
            -t ${APP_NAME}:${BUILD_NUMBER} \
            -t ${APP_NAME}:latest .
            '''
        }
    }

    stage('Deploy for Security Scan') {
        steps {
            sh '''
            docker compose -f docker-compose.yml up -d db
            sleep 20

            docker compose -f docker-compose.yml up -d web
            sleep 15
            '''
        }
    }

    stage('OWASP ZAP Scan') {
        steps {
            sh '''
            mkdir -p reports/zap

            docker run --rm \
            --network=${DOCKER_NETWORK} \
            -v $(pwd)/reports/zap:/zap/wrk/:rw \
            ghcr.io/zaproxy/zaproxy:stable \
            zap-baseline.py \
            -t ${ZAP_TARGET_URL} \
            -r zap_report.html \
            -x zap_report.xml \
            -J zap_report.json \
            -I || true
            '''
        }

        post {
            always {
                publishHTML([
                    allowMissing: true,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports/zap',
                    reportFiles: 'zap_report.html',
                    reportName: 'ZAP Security Report'
                ])
            }
        }
    }

    stage('Deploy to Production') {
        when {
            branch 'main'
        }

        steps {
            sh '''
            docker compose -f docker-compose.yml \
            up -d --force-recreate web
            '''
        }
    }
}

post {
    always {
        sh 'docker compose -f docker-compose.yml down || true'
        cleanWs()
    }

    success {
        echo 'Pipeline ejecutado exitosamente'
    }

    failure {
        echo 'Pipeline falló - revisar logs'
    }
}
```

}
