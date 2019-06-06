configuration BasicWebServer {    

    Import-DscResource -ModuleName NetworkingDsc;

    node ("Node1", "Node2", "Node3")
    {
        WindowsFeature WebServer {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        File WebsiteContent {
            Ensure          = "Present"
            Contents = "<html><body><h1>Hello World</h1></body></html>"            
            DestinationPath = "c:\inetpub\wwwroot\index.html"
            Type            = "File"
            DependsOn       = "[WindowsFeature]WebServer"
        }

        Firewall LetHttpTraficIn {
            Name        = 'HttpHttpsTrafficForTheWebsite'
            DisplayName = 'Http(S) traffic for the website'
            Group       = 'HttpWebServer'
            Ensure      = 'Present'
            Enabled     = 'True'
            Profile     = ('Public')
            Direction   = 'InBound'
            LocalPort   = ('80', '443')
            Protocol    = 'TCP'
            Description = 'Http(S) traffic for the website'
            DependsOn   = "[File]WebsiteContent"
        }
    }
}