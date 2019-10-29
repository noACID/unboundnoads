#!/bin/bash

#set -x

whitelist=$(cat whitelist.txt | sed -e 's/#.*$//' -e '/^\s*$/d' |tr "\n" "|")
#whitelist=$(cat whitelist.txt | sed -e '/ *#/d; /^ *$/d' |tr "\n" "|")

#echo $whitelist
#exit 0

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

#### domains ####
 for source in `cat lst/domains.lst`; do
     echo $source;
     curl --silent $source >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done

 echo -e "\nFiltering non-url content..."
 cat ads.txt | grep -v -E 'Malvertising list by Disconnect|^$|^#' > domains_parsed.txt
 rm ads.txt

#### hackertarget ####
 for source in `cat lst/hackertarget.lst`; do
     echo $source;
     curl --silent $source >> ads.txt
     echo -e "\t`wc -l ads.txt | cut -d " " -f 1` lines downloaded"
 done

 echo -e "\nFiltering non-url content..."
 cat ads.txt | cut -d "," -f 1  > hackertarget_parsed.txt
 rm ads.txt


#### mylists ####
     echo -e "\t`wc -l lst/mylist.txt | cut -d " " -f 1` lines downloaded"

 echo -e "\nFiltering non-url content... MyLists"
 cat lst/mylist.txt | grep -v 'Malvertising list by Disconnect|^$' > mylists_parsed.txt

#### mywarez ####
     echo -e "\t`wc -l lst/mywarez.txt | cut -d " " -f 1` lines downloaded"

 echo -e "\nFiltering non-url content... MyWarez\n\n"
 cat lst/mywarez.txt | grep -v 'Malvertising list by Disconnect|^$' > mywarez_parsed.txt



cat ads_parsed.txt >> balcklist_unsort.txt
cat hosts_parsed.txt >> balcklist_unsort.txt
cat domains_parsed.txt >>  balcklist_unsort.txt
cat hackertarget_parsed.txt >>  balcklist_unsort.txt
cat mylists_parsed.txt >>  balcklist_unsort.txt
cat mywarez_parsed.txt >> balcklist_unsort.txt
rm ads_parsed.txt hosts_parsed.txt domains_parsed.txt hackertarget_parsed.txt mylists_parsed.txt mywarez_parsed.txt

echo -e "\t`wc -l balcklist_unsort.txt | cut -d " " -f 1` lines after parsing"

echo -e "\nRemoving duplicates..."
sort -u balcklist_unsort.txt > ads_unique.txt
rm balcklist_unsort.txt
echo -e "\t`wc -l ads_unique.txt | cut -d " " -f 1` lines after deduping"


cat ads_unique.txt >> blacklist.txt
sort -u blacklist.txt > blacklist.txt2
rm blacklist.txt
cat blacklist.txt2 |grep -v -E '^$|localhost|^0.0.0.0' |grep -v -E "$whitelist" > blacklist.txt
rm ads_unique.txt blacklist.txt2


cat blacklist.txt |awk '{print "server:\nlocal-data: \""$1" A 0.0.0.0\""}' > ads_hole.conf

rm blacklist.txt
