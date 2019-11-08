clear

Import-Module ActiveDirectory
Import-Module 'Microsoft.PowerShell.Security'

#importation du fichier CSV
$utilisateurs = Import-Csv -Delimiter ";" -Path ".\utilisateurs.csv" 

#Création des OU + les groupes s'il n'y pas d'erreur
try{
    New-ADOrganizationalUnit -Name "Employes" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Direction" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Graphisme" -Path "OU=Employes,DC=IMLC,DC=CH" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Publicite" -Path "OU=Employes,DC=IMLC,DC=CH" -ProtectedFromAccidentalDeletion $False
    New-ADOrganizationalUnit -Name "Informatique" -Path "OU=Employes,DC=IMLC,DC=CH" -ProtectedFromAccidentalDeletion $False
    NEW-ADGroup –name “dl_Direction” –groupscope DomainLocal –path "OU=Direction,DC=IMLC,DC=CH"
    NEW-ADGroup –name “dl_Graph” –groupscope DomainLocal –path “OU=Graphisme,OU=Employes,DC=IMLC,DC=CH”
    NEW-ADGroup –name “dl_Pub” –groupscope DomainLocal –path “OU=Publicite,OU=Employes,DC=IMLC,DC=CH”
    NEW-ADGroup –name “dl_Info” –groupscope DomainLocal –path “OU=Informatique,OU=Employes,DC=IMLC,DC=CH”
}
catch{
    echo "Erreur dans la création des OU et des groupes"
}

#Création des utilisateur depuis le fichier CSV
foreach ($user in $utilisateurs){
    
    $name = $user.firstName + " " + $user.lastName
    $fname = $user.firstName
    $lname = $user.lastName
    $login = $user.firstName + "." + $user.lastName
    $Uoffice = $user.office
    $Upassword = $user.password
    $group = $user.group
    

	#en fonction de ce qui se trouve dans le fichier csv on met l'utilisateur dans la bonne OU
    switch($user.office){
        "Graphisme" {$office = "OU=Graphisme,OU=Employes,DC=IMLC,DC=CH"}
        "Publicite" {$office = "OU=Publicite,OU=Employes,DC=IMLC,DC=CH"}
        "Informatique" {$office = "OU=Informatique,OU=Employés,DC=IMLC,DC=CH"}
        "Direction" {$office = "OU=Direction,DC=IMLC,DC=CH"}
        default {$office = $null}    
    }
    
    #création de chaque utilisateur dans le bon groupe avec un dossier personnel
     try {
            $path = "\\sc-srv01\Utilisateurs$\$login"

            New-ADUser -Name $name -SamAccountName $login -UserPrincipalName $login -DisplayName $name -GivenName $fname -Surname $lname -AccountPassword (ConvertTo-SecureString $Upassword -AsPlainText -Force) -Path $office -Enabled $true -homedrive "P" -homedirectory $path -ChangePasswordAtLogon $true;
            Add-ADGroupMember -Identity $group -Members $login


#création du dossier personnel avec tout les droits nécessaire
            if (-not (Test-Path $path)) { 
                $acl = (md $path).GetAccessControl()
                $perm = ($login + "@imlc.ch"),"FullControl","ContainerInherit,ObjectInherit","None","Allow"
                $accessRule = new-object System.Security.AccessControl.FileSystemAccessRule $perm
	            $acl.SetAccessRule($accessRule)
	            $acl | Set-Acl -Path $Path
            }


            echo "Utilisateur ajouté : $name"
          
           
        } catch{
           echo "utilisateur non ajouté : $name"
       }   

   }
