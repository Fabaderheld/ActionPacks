#Requires -Version 5.1

<#
.SYNOPSIS
    Removes local user account

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/LocalAccounts

.Parameter Name
    Specifies an name of the user account that deletes

.Parameter SID
    Specifies an security ID (SID) of the user account that deletes
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]    
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "BySID")]    
    [string]$SID,
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            Remove-LocalUser -Name $Name -Confirm:$false -ErrorAction Stop
        }
        else {
            Remove-LocalUser -SID $SID -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-LocalUser -Name $Using:Name -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-LocalUser -SID $Using:SID -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-LocalUser -Name $Using:Name -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-LocalUser -SID $Using:SID -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
    }          
    if($SRXEnv) {
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $SRXEnv.ResultMessage = "User account: $($Name) removed"
        }
        else {
            $SRXEnv.ResultMessage = "User account: $($SID) removed"
        }
    }
    else{
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            Write-Output "User account: $($Name) removed"
        }
        else {
            Write-Output "User account: $($SID) removed"
        }
    }
}
catch{
    throw
}
finally{
}