pipeline {
    agent any

    parameters {
        choice(
            name: 'PYTHON_VERSION',
            choices: ['python', 'python3', 'py'],
            description: 'Python executable'
        )
    }

    environment {
        VENV_DIR        = "${WORKSPACE}\\venv"
        REPORTS_DIR     = "${WORKSPACE}\\reports"
        COVERAGE_REPORT = "${WORKSPACE}\\coverage.xml"
        TEST_REPORT     = "${WORKSPACE}\\test-results.xml"

        FLASK_ENV       = 'testing'
        SECRET_KEY      = 'jenkins-secret'

        SONAR_TOKEN     = credentials('sonarqube-token')

        MYSQL_USER      = credentials('mysql-user')
        MYSQL_PASSWORD  = credentials('mysql-password')
    }

    options {
        timeout(time: 60, unit: 'MINUTES')
        timestamps()
        disableConcurrentBuilds()
    }

    stages {

        stage('Preparacion') {
            steps {

                bat """
                if not exist "%REPORTS_DIR%" mkdir "%REPORTS_DIR%"
                if not exist "%REPORTS_DIR%\\htmlcov" mkdir "%REPORTS_DIR%\\htmlcov"

                del /Q "%REPORTS_DIR%\\*.xml" 2>nul
                del /Q "%REPORTS_DIR%\\*.txt" 2>nul
                """

                bat """
                ${params.PYTHON_VERSION} -m venv "%VENV_DIR%"

                call "%VENV_DIR%\\Scripts\\activate"

                python -m pip install --upgrade pip

                pip install -r requirements.txt

                pip install -r requirements-dev.txt
                """
            }
        }

        stage('Flake8') {
            steps {

                bat """
                call "%VENV_DIR%\\Scripts\\activate"

                flake8 app.py utils config.py ^
                --max-line-length=120 ^
                --exclude=venv,__pycache__,.git ^
                --ignore=E302,E305,E501,W293,W291,W292,E128,F401,E402 ^
                --output-file="%REPORTS_DIR%\\flake8-report.txt"

                if exist "%REPORTS_DIR%\\flake8-report.txt" type "%REPORTS_DIR%\\flake8-report.txt"

                exit /b 0
                """
            }
        }

        stage('Bandit') {
            steps {

                bat """
                call "%VENV_DIR%\\Scripts\\activate"

                bandit -r app.py utils config.py ^
                -f json ^
                -o "%REPORTS_DIR%\\bandit-report.json"

                exit /b 0
                """
            }
        }

        stage('Safety') {
            steps {

                bat """
                call "%VENV_DIR%\\Scripts\\activate"

                safety scan -r requirements.txt || exit /b 0
                """
            }
        }

        stage('Tests') {
            steps {

                bat """
                call "%VENV_DIR%\\Scripts\\activate"

                pytest tests/ ^
                -v ^
                --tb=short ^
                --cov=utils ^
                --cov=app ^
                --cov=config ^
                --cov-report=xml:%COVERAGE_REPORT% ^
                --cov-report=html:%REPORTS_DIR%\\htmlcov ^
                --cov-report=term-missing ^
                --junitxml=%TEST_REPORT%
                """
            }

            post {

                always {

                    junit allowEmptyResults: true,
                    testResults: 'test-results.xml'

                    publishHTML([
                        allowMissing: true,
                        alwaysLinkToLastBuild: true,
                        keepAll: true,
                        reportDir: 'reports/htmlcov',
                        reportFiles: 'index.html',
                        reportName: 'Coverage'
                    ])
                }
            }
        }

        stage('Coverage') {
            steps {

                bat """
                call "%VENV_DIR%\\Scripts\\activate"

                coverage report --fail-under=20
                """
            }
        }

        stage('SonarQube') {

            steps {

                withSonarQubeEnv('SonarQube') {

                    script {

                        def scannerHome = tool 'SonarScanner'

                        bat """
                        "${scannerHome}\\bin\\sonar-scanner.bat" ^
                        -Dsonar.projectKey=clinica-paliativos ^
                        -Dsonar.projectName="Clinica Cuidados Paliativos" ^
                        -Dsonar.sources=app.py,utils,config.py ^
                        -Dsonar.tests=tests ^
                        -Dsonar.python.coverage.reportPaths=%COVERAGE_REPORT% ^
                        -Dsonar.python.xunit.reportPath=%TEST_REPORT% ^
                        -Dsonar.exclusions=**/venv/**,**/__pycache__/**,**/static/** ^
                        -Dsonar.coverage.exclusions=tests/** ^
                        -Dsonar.host.url=%SONAR_HOST_URL% ^
                        -Dsonar.login=%SONAR_TOKEN%
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {

            steps {

                timeout(time: 5, unit: 'MINUTES') {

                    waitForQualityGate abortPipeline: false
                }
            }
        }

    }

    post {

        always {

            archiveArtifacts artifacts: '''
reports/**/*,
coverage.xml,
test-results.xml
''', allowEmptyArchive: true
        }

        success {

            echo "PIPELINE EXITOSO"
        }

        failure {

            echo "PIPELINE FALLIDO"
        }
    }
}