# This is the URI for the folder one level above the credentials we need.
$MetadataUri = `
    "http://169.254.169.254/latest/meta-data/iam/security-credentials"

# We need to get the contents of the folder to know the name of the subfolder.
# Technically there could be multiple but I haven't seen that happen. We will
# just use the first one.
$CredentialsList = ( `
    Invoke-WebRequest -uri $MetadataUri `
).Content.Split()

# Get the credentials and turn the JSON text into an object.
$CredentialsObject = (Invoke-WebRequest `
    -uri "$MetadataUri/$($CredentialsList[0])" `
).Content | ConvertFrom-Json

# Create/update a profile using the temporary access key and secret key
# we retrieved from the metadata.
Set-AWSCredential `
    -StoreAs InstanceProfile `
    -AccessKey $CredentialsObject.AccessKeyId `
    -SecretKey $CredentialsObject.SecretAccessKey `
    -SessionToken $CredentialsObject.Token 

# Create/update the assume role profile.
Set-AWSCredential `
    -StoreAs default `
    -RoleArn $YourRoleArnHere `
    -SourceProfile InstanceProfile
