#!/bin/bash

whitelist=$(cat whitelist.txt |tr "\n" "|")


#### ADB Block ####
 for source in `cat lst/adblock.lst`; do
     echo $source;
     curl --silent $source >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done

 echo -e "\nFiltering non-url content..."
 perl easylist.pl ads.txt > ads_parsed.txt
 rm ads.txt

#### hosts ####
 for source in `cat lst/hosts.lst`; do
     echo $source;
     curl --silent $source |sed 's/\r/\n/g' >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done
 echo -e "\nFiltering non-url content..."
 cat ads.txt |grep -v -E '^#|^$' |grep -E '0.0.0.0|127.0.0.1' |awk '{print $2}'  > hosts_parsed.txt
 rm ads.txt

#### lists ####
 for source in `cat lst/lists.lst`; do
     echo $source;
     curl --silent $source >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done

 echo -e "\nFiltering non-url content..."
 cat ads.txt | grep -v 'Malvertising list by Disconnect|^$' > lists_parsed.txt
 rm ads.txt

#### lists ####
 for source in `cat lst/google.lst`; do
     echo $source;
     curl --silent $source >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done

 echo -e "\nFiltering non-url content..."
 cat ads.txt | cut -d "," -f 1  > google_parsed.txt
 rm ads.txt


cat ads_parsed.txt >> balcklist_unsort.txt
cat hosts_parsed.txt >> balcklist_unsort.txt
cat lists_parsed.txt >>  balcklist_unsort.txt
cat google_parsed.txt >>  balcklist_unsort.txt
rm ads_parsed.txt hosts_parsed.txt lists_parsed.txt google_parsed.txt

echo -e "\t`wc -l balcklist_unsort.txt | cut -d " " -f 1` lines after parsing"

echo -e "\nRemoving duplicates..."
sort -u balcklist_unsort.txt > ads_unique.txt
rm balcklist_unsort.txt
echo -e "\t`wc -l ads_unique.txt | cut -d " " -f 1` lines after deduping"


cat ads_unique.txt >> blacklist.txt
sort -u blacklist.txt > blacklist.txt2
rm blacklist.txt
cat blacklist.txt2 |grep -v -E '^$|localhost' |grep -v -E "$whitelist" > blacklist.txt
rm ads_unique.txt blacklist.txt2


cat blacklist.txt |awk '{print "server:\nlocal-data: \""$1" A 0.0.0.0\""}' > ads_hole.conf

rm blacklist.txt
