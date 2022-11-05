#!/bin/bash
DOMAIN=$1
DIRECTORY=${DOMAIN}_recon
echo "Creating Directory $DIRECTORY"
mkdir $DIRECTORY
nmap_scan()
{
	nmap $DOMAIN > $DIRECTORY/nmap
	echo "The results of your scan are stored in $DIRECTORY/nmap."
}
dirsearch_scan()
{
	dirsearch -u $DOMAIN -e php > $DIRECTORY/dirsearch
	echo"The results of your dirsearch are stored in $DIRECTORY/dirsearch."
}
crt_scan()
{
	curl "https://crt.sh/q=$DOMAIN&output=json" -o $DIRECTORY/crt
	echo "The results of cert parsing is stored in $DIRECTORY/crt"
}
case $2 in
  nmap-only)
    nmap_scan
    ;;
  dirsearch-only)
    dirsearch_scan
    ;;
  crt-only)
    crt_scan
    ;;
  *)
    nmap_scan
    dirsearch_scan
    crt_scan
    ;;
esac

echo  "Generating report for your scan..."
TODAY=$(date)
echo "This scan was created on $TODAY" > $DIRECTORY/report
echo "RESults for nmap: " >> $DIRECTORY/report
grep -E "^\s*\S+\s+\S+\s+\S+\s*$" $DIRECTORY/nmap >> $DIRECTORY/report
echo "results for  dirsearch:" >> $DIRECTORY/report
cat $DIRECTORY/dirsearch >> $DIRECTORY/report
echo "results for crt.sh:" >> $DIRECTORY/report
jq -r".[] | .name_value" $DIRECTORY/crt >> $DIRECTORY/report
