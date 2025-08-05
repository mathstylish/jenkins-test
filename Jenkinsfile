import groovy.json.JsonSlurper

def loadIssuersConfig(branch) {
    def configFile = 'cloudformation/backoffice-issuer-config/_issuers_config.json'
    def jsonText = readFile(configFile)
    def config = new JsonSlurper().parseText(jsonText)

    if (!config?.enabled_issuers?.containsKey(branch)) {
        error "Environment '${branch}' not found in _issuers_config.json"
    }

    return config.enabled_issuers[branch]
}


def loadIssuersConfig(branch) {
    def configFile = 'cloudformation/backoffice-issuer-config/_issuers_config.json'
    def jsonText = readFile(configFile)
    def config = new JsonSlurper().parseText(jsonText)

    if (!config?.enabled_issuers?.containsKey(branch)) {
        error "Environment '${branch}' not found in _issuers_config.json"
    }

    return config.enabled_issuers[branch]
}

pipeline {
    agent any

    stages {
        stage('Teste') {
            steps {
               script {
                    def envName = 'dev'
                    def issuers = loadIssuersConfig(envName)
                    echo "Found ${issuers.size()} issuers for ${envName}: ${issuers}"
               }
            }
        }
    }
}
