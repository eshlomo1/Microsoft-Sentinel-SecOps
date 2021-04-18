[DSCLocalConfigurationManager()]

Configuration LCM_Pull {

    Node Pull {

        Settings {
            ConfigurationMode = 'ApplyAndAutoCorrect'
            RefreshMode = 'Pull'
        }

        ConfigurationRepositoryWeb PullServer {
            ServerURL = 'https://pull:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey = 'ff7e4129-5c8a-4f23-bbeb-30a85aafb708'
            ConfigurationNames = @('WebServerConfig')
        }

        ResourceRepositoryWeb PullServerModules {
            ServerURL = 'https://pull:8080/PsDscPullserver.svc'
            AllowUnsecureConnection = $false
            RegistrationKey = 'ff7e4129-5c8a-4f23-bbeb-30a85aafb708'
        }
    }
}

LCM_Pull

Set-DscLocalConfigurationManager -ComputerName pull -Path .\LCM_Pull -Verbose -Force

Update-DscConfiguration -ComputerName pull -Verbose -Wait

