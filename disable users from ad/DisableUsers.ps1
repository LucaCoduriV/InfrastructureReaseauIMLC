clear

Import-Module ActiveDirectory
Import-Module 'Microsoft.PowerShell.Security'

#importation du fichier CSV
$utilisateurs = Import-Csv -Delimiter ";" -Path ".\utilisateurs.csv" 

#désactiver les utilisateusr depuis le fichier CSV
foreach ($user in $utilisateurs){
    

    $login = $user.firstName + "." + $user.lastName
    
     try {
            disable-ADAccount -Identity $login
            echo "Utilisateur désactivé : $login"
        } catch{
            echo "utilisateur non désactivé : $login"
       }   

   }
