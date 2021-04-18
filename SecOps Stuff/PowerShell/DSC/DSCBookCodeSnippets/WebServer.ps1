Configuration WebServer {

Import-DscResource -ModuleName 'PSDesiredStateConfiguration'
Import-DscResource -ModuleName "xWebAdministration"

    Node WebServerConfig {

        WindowsFeature WindowsServer {
            Name = 'Web-Server'
        }

        File GlobomanticsPath {
            DestinationPath = $env:SystemDrive+'\Globomantics'
            Type = 'Directory'
            Ensure = 'Present'
        }

        xWebVirtualDirectory Globomantics {
            Name = 'Globomantics'
            PhysicalPath = $env:SystemDrive+'\Globomantics'
            WebApplication = ''
            Website = 'Default Web Site'
            Ensure = 'Present'
            DependsOn = '[File]GlobomanticsPath'
        }
    }
}

WebServer -OutputPath $env:SystemDrive'\dsc\WebServer'

new-dscchecksum -path $env:SystemDrive'\dsc\WebServer\WebServerConfig.mof'