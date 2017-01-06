<# 
.NOTES
  Version:        0.1 beta
  Author:         Bryan Hernandez
  Creation Date:  Dec 28th, 2016.
#>

cls

#-------------------LOGIN VERIFICATION---------------------
function logIn{

    Try{
        Get-AzureRmContext -ErrorAction Continue
    }
    Catch [System.Management.Automation.PSInvalidOperationException]{
        Login-AzureRmAccount
    }

}


#----------------------SUBSCRIPTION------------------------
function chooseSubscription{

    #GETTING SUBSCRIPTION INFORMATION
    $AzureSubscriptions = Get-AzureRmSubscription -TenantId $AzureAccount.Context.Tenant
    $AzureSubscriptionsNames = $AzureSubscriptions.SubscriptionName

    $Title = 'Choose a Subscription'
    Write-Host ""
    Write-Host "================ $Title ================" -ForegroundColor Black -BackgroundColor White
    Write-Host ""

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


#------------------RESOURCE GROUP STUFF--------------------

#INITIAL PROMPT
function chooseResourceGroup{
    $global:azureLocation = "" #Resetting glob
 
    $Title = 'Choose existent Resource Group or create a new one?'
    Write-Host ""
    Write-Host "================ $Title ================" -ForegroundColor Black -BackgroundColor White
    
    Write-Host "1: create a new one." -ForegroundColor Green
    Write-Host "2: to choose existent." -ForegroundColor Green
    Write-Host ""


    $selection = Read-Host "Please make a selection and hit enter." 
    switch ($selection){
        '1'{
            Write-Host ""
            Write-Host '========== Info: Creating a new Resource Group. ==========' -ForegroundColor Black -BackgroundColor Yellow
            Write-Host ""
            createNewRG
        } 
        '2'{
            Write-Host "Retrieving available subscriptions. Please wait." -ForegroundColor Black -BackgroundColor Yellow
            chooseExistingRG
        }
    }
 
}

#CREATE A NEW RESOURCE GROUP
function createNewRG{

    $azureLocations = Get-AzureRmLocation | sort Location | Select Location

    Write-Host "Info : The following Azure locations/regions are available:" -ForegroundColor Cyan

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
    $global:resourceGroupName = Read-Host -Prompt "Please enter a name for the resource group."

    $Output = "Info : The resource group [" + $resourceGroupName + "] will be created on the [" + $azureLocation+ "] Location."
    Write-Host $Output -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Creating Resource Group, please wait." -ForegroundColor Black -BackgroundColor Yellow

    #ACTUAL CREATION LINE
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $azureLocation

    Write-Host "[$resourceGroupName] Resource Group Successfully Created" -ForegroundColor Yellow

}

#CHOOSE EXISTING RESOURCE GROUP
function chooseExistingRG{

    $azureResourceGroups = Get-AzureRmResourceGroup | sort ResourceGroupName | Select ResourceGroupName


    if ($azureResourceGroups.Length -lt 1) {
        $global:resourceGroupName = $azureResourceGroups.ResourceGroupName

        Write-Host ""
        $Output = "Info : The resource group [" + $resourceGroupName + "] is now the default resource group"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""

        Write-Host "[$resourceGroupName] Resource Group Successfully Selected" -ForegroundColor Yellow

    }
    else{

        Write-Host "Info : The following Azure resource groups are available, please choose a number and type Enter:" -ForegroundColor Cyan

        $j = $azureResourceGroups.Length
        #OUTPUT AVALAIBLE RESOURCE GROUPS
        $i=1
        foreach ($azzz in $azureResourceGroups ){
            write-host $i : $azureResourceGroups.Item($i - 1).ResourceGroupName # use dot-ResourceGroupName ".ResourceGroupName" cause it is a JSON object.
            $i++
        }

        #CHOICE PROMPT
        $SelectedNumber = 0
        while ($SelectedNumber -notin 1..$j ) {

            $SelectedNumber = Read-Host -Prompt "Type a number and hit Enter"

            if ($SelectedNumber -notin 1..$j ) {            
                Write-Host "Invalid choice, please select a number between "1 "and "$j -BackgroundColor Red -ForegroundColor Yellow 
                $i=1
            
                foreach ($azzz in $azureResourceGroups ){
                    write-host $i : $azureResourceGroups[$i - 1].ResourceGroupName # use dot-ResourceGroupName ".ResourceGroupName" cause it is a JSON object.
                    $i++
                }
            }
        }

        #RESOURCE GROUP NAME AND CREATION

        $global:resourceGroupName = $azureResourceGroups.Item($SelectedNumber - 1).ResourceGroupName

        Write-Host ""
        $Output = "Info : The resource group [" + $resourceGroupName + "] is now the default resource group"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""

        Write-Host "[$resourceGroupName] Resource Group Successfully Selected" -ForegroundColor Yellow

    }

}


#------------------STORAGE ACCOUNT STUFF-------------------

#INITIAL PROMPT
function chooseStorageAccount{
    
    $Title = 'Choose existent Storage Account or create a new one?'
    Write-Host ""
    Write-Host "================ $Title ================" -ForegroundColor Black -BackgroundColor White
    
    Write-Host "1: create a new one." -ForegroundColor Green
    Write-Host "2: to choose existent." -ForegroundColor Green
    Write-Host ""


    $selection = Read-Host "Please make a selection and hit enter." 
    switch ($selection){

        '1'{
            Write-Host ""
            Write-Host '========== Info: Creating a new Storage Account. ==========' -ForegroundColor Black -BackgroundColor Yellow
            Write-Host ""
            createNewSA
        } 
        '2'{
            Write-Host "Retrieving avalaible Storage Accounts. Please wait." -ForegroundColor Black -BackgroundColor Yellow
            chooseExistingSA
        }
    }
 
}

#SKU NAME CHOOSING
function chooseSkuName{

    Write-Host ""
    Write-Host "Please choose a Sku" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The following Sku's are available:" -ForegroundColor Cyan
    Write-Host "1: Standard_LRS" -ForegroundColor Green
    Write-Host "2: Standard_GRS" -ForegroundColor Green
    Write-Host "3: Standard_RAGRS" -ForegroundColor Green
    Write-Host "4: Standard_ZRS" -ForegroundColor Green
    Write-Host "5: Premium_LRS" -ForegroundColor Green
    $selection = Read-Host "Please type a number and hit Enter " 

    switch($selection){
    
        '1'{
            $global:skuName = "Standard_LRS"
            Write-Host "[Standard_LRS] Selected." -ForegroundColor Cyan
        }
        '2'{
            $global:skuName = "Standard_GRS"
            Write-Host "[Standard_GRS] Selected." -ForegroundColor Cyan
        }
        '3'{
            $global:skuName = "Standard_RAGRS"
            Write-Host "[Standard_RAGRS] Selected." -ForegroundColor Cyan
        }
        '4'{
            $global:skuName = "Standard_ZRS"
            Write-Host "[Standard_ZRS] Selected." -ForegroundColor Cyan
        }
        '5'{
            $global:skuName = "Premium_LRS"
            Write-Host "[Premium_LRS] Selected." -ForegroundColor Cyan
        }
    
    }
    #TO-DO: Handle when $selected isnt in range.

}

#STORAGE KIND CHOOSING
function chooseStorageKind{
    
    Write-Host ""
    Write-Host "Please choose a Storage Kind" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "The following Storage kinds are available:" -ForegroundColor Cyan
    Write-Host "1: Storage" -ForegroundColor Green
    Write-Host "2: BlobStorage" -ForegroundColor Green
    $selection = Read-Host "Please type a number and hit Enter: " 

    switch($selection){
    
        '1'{
            $global:storageKind = "Storage"
            Write-Host "[Storage] Selected." -ForegroundColor Cyan
        }
        '2'{ 
            $global:storageKind = "BlobStorage" 
            Write-Host "[BlobStorage] Selected." -ForegroundColor Cyan
        }
    }
    

}

#CREATE NEW STORAGE ACCOUNT
function createNewSA{

    Write-Host "Info: Creating a new Storage Account in the current [$resourceGroupName] resource Group" -ForegroundColor Cyan
    Write-Host ""
    $global:storageAccountName = Read-Host "Please enter a name for the new Storage Account **Must be all lower case**: " 
    #CHECK IF NAME IS AVAILABLE
    try{
        Get-AzureRmStorageAccountNameAvailability $storageAccountName
    }
    catch{
        Write-Host "The storage account name provided is already in use, please try again with a different name." -ForegroundColor Black -BackgroundColor Yellow
        createNewSA
    }
    #CHOOSE OTHER CONFIGURATION REQUIREMENTS
    chooseSkuName
    chooseStorageKind
    
    #ASIGN LOCATION DEPENDING ON THE CURRENT WORKING RESOURCE GROUP (made just in case the user chooses to use an existing RG)
    $locationData = Get-AzureRmResourceGroup -Name $resourceGroupName | Sort Location | Select Location
    $storageAccountLocation = $locationData.Location
    
    
    Write-Host "Info: Creating the new [$storageAccountName] Storage Account." -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "Sku: [$skuName]" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "Storage Kind: [$storageKind]" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "Location: [$storageAccountLocation]" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host ""
    Write-Host "Please wait." -ForegroundColor Black -BackgroundColor Yellow

    #ACTUAL CREATION OF THE STORAGE ACCOUNT
    $global:storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName -SkuName $skuName -Kind $storageKind -Location $storageAccountLocation

    Write-Host "Storage Account Successfully created." -ForegroundColor Black -BackgroundColor Yellow

}

#SELECT EXISTING STORAGE ACCOUNT
function chooseExistingSA{

    $azureStorageAccounts = Get-AzureRmStorageAccount| sort StorageAccountName | Select StorageAccountName


    if ($azureStorageAccounts.Length -lt 1) {
        $global:storageAccountName = $azureStorageAccounts.StorageAccountName

        Write-Host ""
        $Output = "Info : The Storage Account [" + $storageAccountName + "] is now the default Storage Account"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""

        Write-Host "[$storageAccountName] Storage Account Successfully Selected" -ForegroundColor Yellow

    }
    else{

        Write-Host "Info : The following Azure storage accounts are available:" -ForegroundColor Cyan

        $j = $azureStorageAccounts.Length
        #OUTPUT AVALAIBLE RESOURCE GROUPS
        $i=1
        foreach ($azzz in $azureStorageAccounts ){
            write-host $i : $azureStorageAccounts.Item($i - 1).StorageAccountName # use dot-StorageAccountName  cause it is a JSON object.
            $i++
        }

        #CHOICE PROMPT
        $SelectedNumber = 0
        while ($SelectedNumber -notin 1..$j ) {

            Write-Host ""
            $SelectedNumber = Read-Host -Prompt "Type a number and hit Enter"

            if ($SelectedNumber -notin 1..$j ) {            
                Write-Host "Invalid choice, please select a number between "1 "and "$j -BackgroundColor Red -ForegroundColor Yellow 
                $i=1
            
                foreach ($azzz in $azureStorageAccounts ){
                    write-host $i : $azureStorageAccounts[$i - 1].StorageAccountName
                    $i++
                }
            }
        }

        #RESOURCE GROUP NAME AND CREATION

        $global:storageAccountName = $azureStorageAccounts.Item($SelectedNumber - 1).StorageAccountName

        Write-Host ""
        $Output = "Info : The Storage Account [" + $storageAccountName + "] is now the default Storage Account"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""

        $global:storageAccount = Get-AzureRmStorageAccount -name $storageAccountName -ResourceGroupName $resourceGroupName

        Write-Host "[$storageAccountName] Storage Account Successfully Selected" -ForegroundColor Yellow

    }

}
    

#------------------VIRTUAL NETWORK STUFF-------------------

#INITIAL PROMPT
function chooseVirtualNetwork{

    $Title = 'Choose existent Virtual Network or create a new one?'
    Write-Host ""
    Write-Host "================ $Title ================" -ForegroundColor Black -BackgroundColor White
    
    Write-Host "1: create a new one." -ForegroundColor Green
    Write-Host "2: to choose existent." -ForegroundColor Green
    Write-Host ""

    $selection = Read-Host "Please make a selection and hit enter." 
    switch ($selection){

        '1'{
            Write-Host ""
            Write-Host '========== Info: Creating a new Virtual Network. ==========' -ForegroundColor Black -BackgroundColor Yellow
            Write-Host ""
            createNewVN
        } 
        '2'{
            Write-Host "Retrieving avalaible Virtual Networks. Please wait." -ForegroundColor Black -BackgroundColor Yellow
            chooseExistingVN
        }
    }

}

#CREATE NEW VIRTUAL NETWORK
function createNewVN{

    Write-Host "Info: Creating a new Virtual Network in the current [$resourceGroupName] resource Group" -ForegroundColor Cyan
    Write-Host ""
    $global:virtualNetworkName = Read-Host "Please enter a name for the new Virtual Network "
    Write-Host ""
    $virtualNetworkAddress = Read-Host "Please enter an Adress Prefix for the [$virtualNetworkName] Virtual Network. (Example: 10.0.0.0/16) "
    Write-Host ""
    $global:subnetName = Read-Host "Please enter a name for the Virtual Network Subnet "
    Write-Host ""
    $subnetAddress = Read-Host "Please enter an Address Prefix for the [$subnetName] subnet. (Example: 10.0.0.0/24)"

    #ASIGN LOCATION DEPENDING ON THE CURRENT WORKING RESOURCE GROUP (made just in case the user chooses to use an existing RG)
    $locationData = Get-AzureRmResourceGroup -Name $resourceGroupName | Sort Location | Select Location
    $virtualNetworkLocation = $locationData.Location

    Write-Host ""
    Write-Host "Creating the [$virtualNetworkName] Virtual Network on the [$resourceGroupName] Resource Group. Please wait." -ForegroundColor Yellow

    $subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix $subnetAddress
    $global:virtualNetwork = New-AzureRmVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroupName `
     -Location $virtualNetworkLocation -AddressPrefix $virtualNetworkAddress -Subnet $subnet

     Write-Host ""
     Write-Host "The [$virtualNetworkName] Virtual Network was successfully created." -ForegroundColor Black -BackgroundColor Yellow

}

#CHOOSING EXISTENT VIRTUAL NETWORK
function chooseExistingVN{

    $azureVirtualNetworks = Get-AzureRmVirtualNetwork | Sort Name | Select Name


    if ($azureVirtualNetworks.Length -lt 1) {
        $global:virtualNetworkName = $azureVirtualNetworks.Name

        Write-Host ""
        $Output = "Info : The Virtual Network [" + $virtualNetworkName + "] is now the default Virtual Network"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""
        Write-Host "[$virtualNetworkName] Virtual Network Successfully Selected" -ForegroundColor Yellow

    }
    else{

        Write-Host "Info : The following Azure virtual networks are available:" -ForegroundColor Cyan

        $j = $azureVirtualNetworks.Length
        #OUTPUT AVALAIBLE RESOURCE GROUPS
        $i=1
        foreach ($azzz in $azureVirtualNetworks ){
            write-host $i : $azureVirtualNetworks.Item($i - 1).Name
            $i++
        }

        #CHOICE PROMPT
        $SelectedNumber = 0
        while ($SelectedNumber -notin 1..$j ) {

            Write-Host ""
            $SelectedNumber = Read-Host -Prompt "Type a number and hit Enter"

            if ($SelectedNumber -notin 1..$j ) {            
                Write-Host "Invalid choice, please select a number between "1 "and "$j -BackgroundColor Red -ForegroundColor Yellow 
                $i=1
            
                foreach ($azzz in $azureVirtualNetworks ){
                    write-host $i : $azureVirtualNetworks[$i - 1].Name
                    $i++
                }
            }
        }

        #RESOURCE GROUP NAME AND CREATION

        $global:virtualNetworkName = $azureVirtualNetworks.Item($SelectedNumber - 1).Name

        Write-Host ""
        $Output = "Info : The Virtual Network [" + $virtualNetworkName + "] is now the default Virtual Network"
        Write-Host $Output -ForegroundColor Cyan
        Write-Host ""

        $global:virtualNetwork = Get-AzureRmVirtualNetwork -name $virtualNetworkName -ResourceGroupName $resourceGroupName

        Write-Host "[$virtualNetworkName] Virtual Network Successfully Selected" -ForegroundColor Yellow
    }

}

#--------------VIRTUAL MACHINES CREATION-------------------

function VMCreation{
    
    $global:nameOfVM = Read-Host "Please enter a name for the VM(s)"
    $global:numberOfVM = Read-Host "Please enter how many Virtual Machines you want to create and hit enter"
    $global:interfaceName = Read-Host "Please enter a name for the network interface of the new VM(s)"
    $dummyPrompt = Read-Host "Please enter the credentials for the actual VM(s) login. HIT ENTER TO CONTINUE"
    $global:VmCredentials = Get-Credential -Message "Please enter the login credentials for the VM(s)"

    ################    [BURNED]. GIVE OPTION TO CHANGE THIS IN FUTURE VERSIONS#############################
    $VMSize = "Standard_A0"

    #ASIGN LOCATION DEPENDING ON THE CURRENT WORKING RESOURCE GROUP (made just in case the user chooses to use an existing RG)
    $locationData = Get-AzureRmResourceGroup -Name $resourceGroupName | Sort Location | Select Location
    $VMLocation = $locationData.Location

    Write-Host ""
    Write-Host "CREATING [$numberOfVM] Virtual Machine(s), PLEASE WAIT WHILE THE SCRIPT CREATES THE MACHINES..." -ForegroundColor Black -BackgroundColor Yellow


    $i = 1;

    Do { 
        Write-Host "CREATING THE [ $i ] VIRTUAL MACHINE" -ForegroundColor Black -BackgroundColor Yellow 
        $vmName=$nameOfVM+$i
        $vmconfig=New-AzureRmVMConfig -VMName $vmName -VMSize $VMSize

        $vm=Set-AzureRmVMOperatingSystem -VM $vmconfig -Windows -ComputerName $vmName -Credential $VmCredentials -ProvisionVMAgent -EnableAutoUpdate

        $VMVnet = Get-AzureRmVirtualNetwork -name $virtualNetworkName -ResourceGroupName $resourceGroupName

        $OSDiskName = $vmName + "osDisk"
        # Storage
        $VMStorageAccount = Get-AzureRmStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroupName
        ## Setup local VM object

        #############   [BURNED] TO-DO: GIVE THE USER THE ABILITY TO CHOOSE THE OS IN FUTURE VERSIONS###############################
        $vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version "latest"
        
        
        $PIp = New-AzureRmPublicIpAddress -Name $InterfaceName$i -ResourceGroupName $resourceGroupName -Location $VMLocation -AllocationMethod Dynamic
        $Interface = New-AzureRmNetworkInterface -Name $interfaceName$i -ResourceGroupName $resourceGroupName -Location $VMLocation -SubnetId $virtualNetwork.Subnets[0].Id -PublicIpAddressId $PIp.Id
        $VirtualMachine = Add-AzureRmVMNetworkInterface -VM $vm -Id $Interface.Id
        $OSDiskUri = $VMStorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
        $VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption FromImage

        ## Create the VM in Azure
        New-AzureRmVM -ResourceGroupName $resourceGroupName -Location $VMLocation -VM $VirtualMachine
        $i +=1
    } 
    Until ($i -gt $NumberOfVM) 

}




#RUNNABLE.
function main{

    logIn
    chooseSubscription
    chooseResourceGroup
    chooseStorageAccount
    chooseVirtualNetwork
    VMCreation

}

main