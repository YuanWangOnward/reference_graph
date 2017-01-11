#! /bin/bash
# convert ris file to csv to facilitate dot diagram drawing
# 

#echo "$1"
author='NoAuthor'
year='0000'
title='no title found'
referenceID=''
referenceLabel=''
note=''

flagAuthor=0
flagNoteLoading=0
#flagWriteReady=0

>"$2"
while IFS='' read -r line || [[ -n "$line" ]]; do
	
	if [ ! -z "$line" ]; then
		case ${line:0:2}  in
		T1)
			# a new paper comes, 
			# if a existing record has not been written, write it (in case no N2)
			if [[ "$title" != 'no title found' ]]; then
				# write a new record
				#referenceID=$(echo $author $year $title | cut -d' ' -f -5 |sed -e "s/\b\(.\)/\u\1/g"|sed 's/ //g')
				referenceID=$(echo $author $year $title | cut -d' ' -f -5 |sed 's/ //g' | sed 's/[^0-9a-zA-Z]*//g')
				referenceLabel=$(echo $author$year)
				
				
				printf  '%s\t' $referenceID>>"$2"
				printf  '%s\t' $referenceLabel>>"$2"
				printf  '%s ' $title>>"$2"
				printf  '%s\t ' '' >>"$2"
				printf  '%s ' $note>>"$2"
				printf  '%s\n ' '' >>"$2"
				
				# echo $referenceID
				# echo $referenceLabel
			fi
			
			
			#clear exisitng recording
			author='NoAuthor'
			year='0000'
			title='no title found'
			referenceID=''
			referenceLabel=''
			note=''
			flagAuthor=0
			flagNoteLoading=0
			#flagWriteReady=0
			
			# loading current reference
			#title=`echo "${line:6}"| tr A-Z a-z `
			title="${line:6}"
			#echo $title
			tmpTitle=($title)
			#echo $tmpTitle
			#echo ${#tmpTitle[@]}
			for i in `seq 0 ${#tmpTitle[@]} `; do
				# change to first letter capital
				#echo $i
				word=`echo ${tmpTitle[$i]:0:1} |tr a-z A-Z`
				#echo $word
				word+=${tmpTitle[$i]:1}
				tmpTitle[$i]=$word
				#echo $word
			done
			title=${tmpTitle[@]}
			
			
			# echo "reference title: ${line:6}"
			;;
		Y1)
			year="${line:6:4}"
			# echo "published year: ${line:6:4}"
			# echo $test
			;;
		A1)
			if [ "$flagAuthor" -eq "0" ]; then
				author="${line:6}"
				author=$(echo $author | cut -d' ' -f1 | sed "s/,//")
				flagAuthor=$(($flagAuthor+1));
			fi
			
			# echo "author: ${line:6}"
			;;
		N1)
			note="${line:6}"
			note=$(echo $note | sed 's/\&lt\;/\</g' | sed 's/\&gt\;/\>/g')
			flagNoteLoading=1
			;;
		N2)
			flagNoteLoading=0
			#flagWriteReady=0
			;;
		ER)
			flagNoteLoading=0
			#flagWriteReady=0
			;;
		*)
			if [ "$flagNoteLoading" == 1 ]; then
				# add EOS mark and concatenate note
				# cannot use \n
				note="$note/EOS/$line"
				note=$(echo $note | sed 's/\&lt\;/\</g' | sed 's/\&gt\;/\>/g')
			fi
		esac
		
		
	fi
	done < "$1"
	
	# if [ "$flagWriteReady" == 1 ]; then
	if [[ "$title" != 'no title found' ]]; then
		# write a new record
		#referenceID=$(echo $author $year $title | cut -d' ' -f -5 |sed -e "s/\b\(.\)/\u\1/g"|sed 's/ //g')
		referenceID=$(echo $author $year $title | cut -d' ' -f -5 |sed 's/ //g' | sed 's/[^0-9a-zA-Z]*//g')
		referenceLabel=$(echo $author$year)
		
		
		printf  '%s\t' $referenceID>>"$2"
		printf  '%s\t' $referenceLabel>>"$2"
		printf  '%s ' $title>>"$2"
		printf  '%s\t ' '' >>"$2"
		printf  '%s ' $note>>"$2"
		printf  '%s\n ' '' >>"$2"
		
		# echo $referenceID
		# echo $referenceLabel
		
		author='NoAuthor'
		year='0000'
		title='no title found'
		referenceID=''
		referenceLabel=''
		note=''
		flagAuthor=0
		flagNoteLoading=0
		#flagWriteReady=0
	fi
	
	
	function capitalizedTheFirstLetter {
		:
	}
	# # if a existing record has not been written, write it (in case no N2)
	# if [[ "$title" != 'no title found' ]]; then
	# # write a new record
	# referenceID=$(echo $author $year $title | cut -d' ' -f -5 |sed -e "s/\b\(.\)/\u\1/g"|sed 's/ //g')
	# referenceLabel=$(echo $author$year)
	# 
	# printf  '%s\t' $referenceID>>"$2"
	# printf  '%s\t' $referenceLabel>>"$2"
	# printf  '%s ' $title>>"$2"
	# printf  '%s\t ' '' >>"$2"
	# printf  '%s ' $note>>"$2"
	# printf  '%s\n ' '' >>"$2"
	# 
	# # echo $referenceID
	# # echo $referenceLabel
	# fi
	# 
	
