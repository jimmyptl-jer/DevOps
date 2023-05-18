pipeline{
  agent any

  stages{
    stage('Create App'){
      steps{
        sh 'npx create-react-app my-app'
      }
    }

    stage('Install Dependencies'){
      steps{
        dir('my-app'){
          sh 'npm install'
        }
      }
    }

    stage('build'){
      steps{
        dir('my-app'){
          sh 'npm run build'
        }
      }
    }

    stage('test'){
      steps{
        dir('my-app'){
          sh 'npm test'
        }
      }
    }
  }
}
