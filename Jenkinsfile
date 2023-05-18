pipeline{
  agent any

  stages{
    stage('Create App'){
      steps{
        echo 'npx create-react-app my-app'
      }
    }

    stage('Install Dependencies'){
      steps{
        dir('my-app'){
          echo 'npm install'
        }
      }
    }

    stage('build'){
      steps{
        dir('my-app'){
          echo 'npm run build'
        }
      }
    }

    stage('test'){
      steps{
        dir('my-app'){
          echo 'npm test'
        }
      }
    }
  }
}
