#delete all temp/old files.
try{
    Remove-Item -Path ".\temp*.txt",".\ResourceIDs.txt",".\output.csv",".\tagdump.txt",".\output.txt" -Force -ErrorAction SilentlyContinue
}
catch{
    continue
}


#get a dump of all the tags in the account, then filter the output to show ony the application tag
#aws ec2 describe-tags | Select-String -Pattern "ResourceId" | Select-String -Pattern "i-" | Select-String -NotMatch "eni" | Out-String > temp.txt

#get dump of tags that matches the application tag value provided
$tag_val = Read-Host "Please enter a tag value"
aws ec2 describe-instances --filters Name=tag-value,Values=$tag_val | Select-String -Pattern "InstanceId" | Select-String -Pattern "i-" | Select-String -NotMatch "eni" | Out-String > temp.txt


Get-Content -Path ".\temp.txt" | ? {$_.trim() -ne "" } | set-content temp1.txt

foreach($line in Get-Content .\temp1.txt) {
    $line = $line.Split(":")[1]
    $line= $($($line -replace "`"") -replace ",") -replace " "

    if($line -ne $null){
        echo $line >> temp2.txt
        }
}

Get-Content -Path ".\temp2.txt" | Get-Unique > ResourceIDs.txt

#Export to csv
#New-Item .\output.csv -ItemType File -Force
#$outfile = ".\output.csv"
#$newcsv = {} | Select "InstanceID","KeyPair" | Export-Csv $outfile

#foreach($line in Get-Content -Path ".\ResourceIDs.txt"){
#    #dump the tags in a file one instance id at a time
#    $(aws ec2 describe-tags --filters "Name=resource-id,Values=$line" --output text | Out-String) > tagdump.txt
#    
#   #parse the tag value as key-pair and store it in a varable
#    $kv_pair=$null
#    foreach($tagline in Get-Content -Path .\tagdump.txt){
#        $key =  $(echo $tagline.Split()[1])
#        $value = $(echo $tagline.Split()[4])
#        $kv_pair = $kv_pair + $(echo $key":"$value "" | Out-String)
#    }
#
#    #append instance-id and its corresponding key-pairs to output.csv
#    $csv_file = Import-Csv $outfile
#    $csv_file.InstanceID = $line
#    $csv_file.KeyPair = $kv_pair
#    $csv_file | Export-CSV .\output.csv –Append  
#}


#Export to text
foreach($line in Get-Content -Path ".\ResourceIDs.txt"){
    #dump the tags in a file one instance id at a time
    $(aws ec2 describe-tags --filters "Name=resource-id,Values=$line" --output text | Out-String) > tagdump.txt
    
    $kv_pair = $null
    foreach($tagline in Get-Content -Path .\tagdump.txt){
        $key =  $(echo $tagline.Split()[1])
        $value = $(echo $tagline.Split()[4])
        $kv_pair = $kv_pair + $(echo $key":"$value "" | Out-String)
    }

    echo "******************$line*****************" >> output.txt
    echo "$kv_pair" >> output.txt
}