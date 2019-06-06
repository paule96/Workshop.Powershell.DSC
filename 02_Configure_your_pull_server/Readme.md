# Configure your own pull server

> Important: For detail instructions and information please read the [official documentation](https://docs.microsoft.com/en-us/powershell/dsc/pull-server/pullserversmb).

To use a pull server we must do 4 simple steps:

* create a folder on the pull server
* add read access for all computers that must pull from the server
* share the folder with all computers that want pull from this server
* configure your servers to pull from this server

> Important: there is a second method for pull servers. You can read more about this [here](https://docs.microsoft.com/en-us/powershell/dsc/pull-server/pullserver).

## Configure the server

You can install the pull server with DSC it self. That's cool 😎.

> But you can also do it with a simple PowerShell script if you more familiar with this.

```powershell
Configuration DSCSMBPullServer
{
    param
    (
        [parameter(Mandatory)]
        [String]
        $domainName="contoso"
    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName cNtfsAccessControl

    Node $AllNodes.Where{$_.Role -eq "DscSmbPullServer"}.NodeName
    {

        File CreateFolder
        {
            DestinationPath = 'D:\DscSmbShare'
            Type = 'Directory'
            Ensure = 'Present'
        }

        xSMBShare CreateShare
        {
            Name = 'DscSmbShare'
            Path = 'D:\DscSmbShare'
            FullAccess = 'administrator'
            ReadAccess = '$domainName\Contoso-Server$'
            FolderEnumerationMode = 'AccessBased'
            Ensure = 'Present'
            DependsOn = '[File]CreateFolder'
        }

        cNtfsPermissionEntry PermissionSet1
        {
            Ensure = 'Present'
            Path = 'D:\DscSmbShare'
            Principal = '$domainName\Contoso-Server$'
            AccessControlInformation = @(
                cNtfsAccessControlInformation
                {
                    AccessControlType = 'Allow'
                    FileSystemRights = 'ReadAndExecute'
                    Inheritance = 'ThisFolderSubfoldersAndFiles'
                    NoPropagateInherit = $false
                }
            )
            DependsOn = '[File]CreateFolder'
        }
    }
}
```

Note that your configuration data must contain a node with the role `DscSmbPullServer` and you must define the domain name.

## Configure the clients

To configure the LCM (Local configuration manager) of your clients you must run the following script.

> Warning: Please use only the FDQN of the Pull Server. If you use the direct IP address the SMB protocol will fallback to NTML instead of Keberos.

```powershell
[DSCLocalConfigurationManager()]
configuration ConfigureClientToUsePullServer
{
    Node $AllNodes.NodeName
    {
        Settings
        {
            RefreshMode = 'Pull'
            RefreshFrequencyMins = 30
            RebootNodeIfNeeded = $true
            ConfigurationID    = $Node.ConfigurationId
        }

        ConfigurationRepositoryShare SmbConfigShare
        {
            SourcePath = '\\PullServer\DscSmbShare'
        }

        ResourceRepositoryShare SmbResourceShare
        {
            SourcePath = '\\PullServer\DscSmbShare'

        }
    }
}

$ConfigurationData = @{
    AllNodes = @(
        @{
            NodeName="Client01";
            ConfigurationId= ((New-Guid).ToString());
        })
}
```

## Add a DSC configuration to the PULL Server



