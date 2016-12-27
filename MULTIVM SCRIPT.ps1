cls

#LOGIN VERIFICATION
function logIn{

    Try{
        Get-AzureRmContext -ErrorAction Continue
    }
    Catch [System.Management.Automation.PSInvalidOperationException]{
        Login-AzureRmAccount
    }

}

#SUBSCRIPTION
function chooseSubscription{

    #GETTING SUBSCRIPTION INFORMATION
    $AzureSubscriptions = Get-AzureRmSubscription -TenantId $AzureAccount.Context.Tenant
    $AzureSubscriptionsNames = $AzureSubscriptions.SubscriptionName

    #IF THERE'S ONLY ONE SUBSCRIPTION
    if ($AzureSubscriptionsNames.GetType().FullName -eq 'System.String' ) {

        Select-AzureRmSubscription -TenantId $AzureAccount.Context.Tenant -SubscriptionName $AzureSubscriptionsNames
        write-host "Info : The only available Azure subscription [" $AzureSubscriptionsNames "] was selected, this subscription will be used for this session " -ForegroundColor Cyan
    }

    #IF THERE'S MORE THAN ONE
    else 
    {
        Write-Host "Info : The following Azure subscriptions are available, please choose a number and type Enter:" -ForegroundColor Cyan

        $j = $AzureSubscriptionsNames.Length
        #OUTPUT AVALAIBLE SUBS
        $i=1
        foreach ($AzureSubscriptionsName in $AzureSubscriptionsNames )
        {
            write-host $i : $AzureSubscriptionsName
            $i++
        }

        #CHOICE PROMPT
        $SelectedNumber = 0
        while ($SelectedNumber -notin 1..$j ) {

            $SelectedNumber = Read-Host -Prompt "Type a number and hit Enter"
            if ($SelectedNumber -notin 1..$j ) 
            {
                Write-Host "Invalid choice, please select a number between "1 "and "$j -BackgroundColor Red -ForegroundColor Yellow 
                $i=1
                foreach ($AzureSubscriptionsName in $AzureSubscriptionsNames )
                {
                    write-host $i : $AzureSubscriptionsName
                    $i++
                }
            }

        }

        #SUB SELECTION AND SETTING TO DEFAULT

        Select-AzureRmSubscription -TenantId $AzureAccount.Context.Tenant -SubscriptionName $AzureSubscriptionsNames.Item($SelectedNumber - 1) | Out-Null
        $Output = "Info : The Azure subscription [" + $AzureSubscriptionsNames.Item($SelectedNumber - 1) + "] was selected, this subscription will be used for this session "
        write-host $Output -ForegroundColor Cyan    
    }
    Write-host ""

}


#----------------RESOURCE GROUP STUFF----------------------
#INITIAL PROMPT
function chooseResourceGroup{
 
    $Title = 'Choose existant Resource Group or create a new one?'
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: create a new one." -ForegroundColor Cyan
    Write-Host "2: to choose existant." -ForegroundColor Cyan
    Write-Host ""


    $selection = Read-Host "Please make a selection and hit enter." 
    switch ($selection){
        '1'{
            'Creating a new Resource Group.'
            createNewRG
        } 
        '2'{
            'Retrieving subscriptions. Please wait.'
            ##TO-DO chooseExistingRG
        }
    }
 
}

#CREATE A NEW RESOURCE GROUP
function createNewRG{

    $azureLocations = Get-AzureRmLocation | sort Location | Select Location

    Write-Host "Info : The following Azure subscriptions are available, please choose a number and type Enter:" -ForegroundColor Cyan

    $j = $azureLocations.Length
    #OUTPUT AVALAIBLE LOCATIONS
    $i=1
    foreach ($azzz in $azureLocations ){
        write-host $i : $azureLocations.Item($i - 1).Location # use dot-Location ".Location" cause it is a JSON object.
        $i++
    }

    #CHOICE PROMPT
    $SelectedNumber = 0
    while ($SelectedNumber -notin 1..$j ) {

        $SelectedNumber = Read-Host -Prompt "Type a number and hit Enter"

        if ($SelectedNumber -notin 1..$j ) {            
            Write-Host "Invalid choice, please select a number between "1 "and "$j -BackgroundColor Red -ForegroundColor Yellow 
            $i=1
            
            foreach ($azzz in $azureLocations ){
                write-host $i : $azureLocations[$i - 1].Location # use dot-Location ".Location" cause it is a JSON object.
                $i++
            }
        }
    }

    #RESOURCE GROUP NAME AND CREATION

    $global:azureLocation = $azureLocations.Item($SelectedNumber - 1).Location

    Write-Host ""
    $global:resourceGroupName = Read-Host -Prompt "Please enter a name for the resource group. **The name must be all lowercase.**"

    $Output = "Info : The resource group [" + $resourceGroupName + "] will be created on the [" + $azureLocation+ "] Location."
    Write-Host $Output -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Creating Resource Group, please wait." -ForegroundColor Black -BackgroundColor Yellow

    #ACTUAL CREATION LINE
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $azureLocation

    Write-Host "[" + $resourceGroupName + "] Resource Group Successfully Created"

}






#RUNNABLE.
function main{

    logIn
    chooseSubscription
    chooseResourceGroup

}

main