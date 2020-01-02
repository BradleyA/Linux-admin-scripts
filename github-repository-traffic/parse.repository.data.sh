#!/bin/bash
# 	github-repository/parse.repository.data.sh  2.100.373  2019-08-29T22:21:11.667309-05:00 (CDT)  https://github.com/BradleyA/Linux-admin  uadmin  two-rpi3b.cptx86.com 2.99  
# 	   github-repository/parse.repository.data.sh  comment rm so tmp file can be viewed 
# 	github-repository/parse.repository.data.sh  2.98.370  2019-08-08T23:47:37.538761-05:00 (CDT)  https://github.com/BradleyA/Linux-admin  uadmin  two-rpi3b.cptx86.com 2.97  
# 	   github-repository/parse.repository.data.sh design complete, ready to create test cases 
###
#               push files to images/clone.table.md images/view.table.md to github owner/repository/images/(clones,views, NOT popular.referrers.list, popular.paths.list)
#               link *.table.md to README.md badges
#        .... NOTE to self ..... need data first and doa'nt want to waste time creating test data come back in a month or so
#
#	column -t -s' ' filename
#	soffice --convert-to png ./clones
#	display ./clones.png
#
#       <img alt="Steam Views" src="https://img.shields.io/steam/views/100">
#
#       cd ~/github/BradleyA/automate/:repo
#       git pull
#       git commit -m '$DATE: automation the update of README table' README.md
#       git push README.md
#
#####	How to test on two
#	cd /usr/local/data/github
#	./parse.repository.data.sh BradleyA/dmonitor/BradleyA.dmonitor.2019-07-29
###
### production standard 3.0 shellcheck
### production standard 5.1.160 Copyright
#	Copyright (c) 2019 Bradley Allen
#	MIT License is in the online DOCUMENTATION, DOCUMENTATION URL defined below.
###
###     parse.repository.data.sh
#
DATA_GITHUB_DIR="/usr/local/data/github/"

#       Order of precedence: CLI argument, environment variable
if [ $# -ge  1 ]  ; then FILE_ORG_NAME=${1} ; elif [ "${FILE_ORG_NAME}" == "" ] ; then
        echo -e "\n\t<OWNER>.<REPO> is required to make this work.  Either as the first argument on the command line or defined as FILE_ORG_NAME environment variable << BUT I HAVE NOT coded that yet >>>.  Try again."
        exit 1
fi

#	Parse relevant data out of ${FILE_ORG_NAME}
grep -e clones -e timestamp -e count -e uniques -e views -e /popular/paths -e path -e title -e /popular/referrers -e '\]' -e '\['  ${FILE_ORG_NAME} | sed -e 's/"//g' -e 's/,//g' -e 's/T.*Z//' -e 's/[ \t]*//g' > ${FILE_ORG_NAME}.no-headers

#	Parse clones data from ${FILE_ORG_NAME}.no-headers
cat  ${FILE_ORG_NAME}.no-headers | sed -e '1,/views>>>/!d' -e '1,/clones:\[/d' -e '/^\]/,$d'  > ${FILE_ORG_NAME}.tmp
#	Loop through ${FILE_ORG_NAME}.tmp and create clone.data.$timestamp files
while read line; do
	FIRST_WORD=$(echo ${line} | cut -d: -f 1)
	if [ "${FIRST_WORD}" == "timestamp" ] ;  then
		SECOND_WORD=$(echo ${line} | cut -d: -f 2)
		CLONE_FILE_NAME="clone.data.${SECOND_WORD}"
                tmp=$(echo ${line} | cut -d: -f 2 | cut -d\- -f 2-3)
                echo "| ${tmp}" > ${CLONE_FILE_NAME}
                echo "|:---:" >> ${CLONE_FILE_NAME}
	else
                AMOUNT=$(echo ${line} | cut -d: -f 2)
                echo "| ${AMOUNT}" >> ${CLONE_FILE_NAME}
	fi
done < ${FILE_ORG_NAME}.tmp
#	rm  ${FILE_ORG_NAME}.tmp
CLONE_TOTAL=0
#	Do clone.data.* files exists and size greater than zero
# >>>	need to test this create an empty file in a repository that has many data file ????
if ls clone.data.* 1>/dev/null 2>&1 ; then
#	Total third line of clone.data.* files
	CLONE_TOTAL=$(awk 'FNR == 3 {total+=$2} END {print total}'  clone.data.*)
	echo ${CLONE_TOTAL}  > clone.total
	paste -d ' ' ../../clone.heading clone.data.* | column -t -s' ' > clone.table.md
	sed -i '1 i\#### Git clones' clone.table.md
fi
echo -e "\nTotal clones: ${CLONE_TOTAL}\n###### Updated: $(date +%Y-%m-%d)"  >> clone.table.md

#	Parse vistors (views) data from ${FILE_ORG_NAME}.no-headers
cat  ${FILE_ORG_NAME}.no-headers | sed -e '1,/\/popular\/paths>>>/!d' -e '1,/views:\[/d' -e '/^\]/,$d'  > ${FILE_ORG_NAME}.tmp 
#	Loop through ${FILE_ORG_NAME}.tmp and create clone.data.$timestamp files
while read line; do
	FIRST_WORD=$(echo ${line} | cut -d: -f 1)
	if [ "${FIRST_WORD}" == "timestamp" ] ;  then
		SECOND_WORD=$(echo ${line} | cut -d: -f 2)
		VIEW_FILE_NAME="view.data.${SECOND_WORD}"
                tmp=$(echo ${line} | cut -d: -f 2 | cut -d\- -f 2-3)
                echo "| ${tmp}" > ${VIEW_FILE_NAME}
                echo "|:---:" >> ${VIEW_FILE_NAME}
	else
                AMOUNT=$(echo ${line} | cut -d: -f 2)
                echo "| ${AMOUNT}" >> ${VIEW_FILE_NAME}
	fi
done < ${FILE_ORG_NAME}.tmp
#	rm  ${FILE_ORG_NAME}.tmp
VIEW_TOTAL=0
#	Do view.data.* files exists and size greater than zero
# >>>   need to test this create an empty file in a repository that has many data file ????
if ls view.data.* 1>/dev/null 2>&1 ; then
#       Total third line of view.data.* files
	VIEW_TOTAL=$(awk 'FNR == 3 {total+=$2} END {print total}'  view.data.*)
	echo ${VIEW_TOTAL}  > view.total
	paste -d ' ' ../../view.heading view.data.* | column -t -s' ' > view.table.md
	sed -i '1 i\#### Visitors' view.table.md
fi
echo -e "\nTotal views: ${VIEW_TOTAL}\n###### Updated: $(date +%Y-%m-%d)"  >> view.table.md

#	rm  ${FILE_ORG_NAME}.no-headers

###