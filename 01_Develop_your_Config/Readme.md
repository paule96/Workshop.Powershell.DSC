# Develop your configuration

PowerShell DSC basically always use two files. The first file is the configuration it self. That file define what role applied to which system in your farm of computers.

That file looks like this:

```powershell

Configuration NameOfYourConfiguration{
    # A block with all needed DSC modules to use this configuration
    Import-DscResource -ModuleName NeededModule; 
    
    # Specify what computers need this configuration
    node ("Node1", "Node2", "Node3")
    {
        DSCResourceName FriendlyTaskName{
            ..... # here a are configuration for this dsc resource
        }
    }
}

```

The second file have a more variable content. It's like a parameter file.

> For more information read [here](https://docs.microsoft.com/en-us/powershell/dsc/configurations/configdata).

```powershell
@{
    AllNodes =
    @(
        @{
            NodeName    = 'Node1'
            FeatureName = 'Web-Server'
        },

        @{
            NodeName    = 'Node2'
            FeatureName = 'Hyper-V'
        }
    )
    NonNodeData="hello world"
}
```

As you can see you can define an hash table to define what server does what. You can also react to all the properties of an node.

To run a configuration you do simply this:

```powershell

. ./pathToYourConfigurationFile.ps1 # this adds your configuration to your powershell session

# if you don't have configuration data you simply run
nameOfYourConfiguration
# if you have configuration data then run
nameOfYourConfiguration -ConfigurationData ./pathToYourConfiguration.ps1

```

## Run the example

> To use this example you must install [`NetworkingDsc`](https://www.powershellgallery.com/packages/NetworkingDsc/7.2.0.0).

To run the example we first let PowerShell read the configuration with:

```powershell
. ./basic_Webserver_config.ps1
```
After this our PowerShell session knew a new command. Run it:

```powershell
BasicWebServer
```

After this the DSC file is compiled to `MOF` files. That are another representation of our DSC file. (it is more verbose) For each server there is an separate file. So it creates three files: `Node1.mof`, `Node2.mof`, `Node3.mof`.

This files can be applied on the server with the command:

```powershell
Start-DscConfiguration .\BasicWebServer
```

> Impotent: The files are named like the computers that are for. If this doesn't match DSC don't do anything