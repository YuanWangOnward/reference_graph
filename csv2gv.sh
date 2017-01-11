#! /bin/bash
# convert csv file to gv to draw dot diagram 
# $1: the input .csv file
# $2: the output .gv file

#parentDir="$(dirname "$(dirname "$(readlink "$0")")")"
#echo $paraentDir


colorNode="#855D5D"
colorLabelFont="#FFFFFF"
#colorLabel="#855D5D"
colorLabel="#9B2D1F"
colorContentFont="#000000"
#colorContent="#E6E6E6"
colorContent="#EFE7E7"
#colorLabelEmphasized="#D34817"
colorLabelEmphasized="#9B2D1F"
colorContentEmphasized="#EFE7E7"

colorLabelReview="#A28E6A"
colorContentReview="#F0EEEB"
# 918485
# 9B2D1F
# D4D0D0
#colorContent="#EFE7E7"

lengthPerline=40	#in a node, when string has more charactors than it, cut it



function createANode {
	# create a node in gv file
	# $1: reference ID
	# $2: reference label
	# $3: reference title
	# $4: reference note
	
	# $5: type
	# $6: rank
	
	tmp=$(echo "$(cat rs/nodeTemplate)"|\
	sed "s/colorNode/$colorNode/g"|\
	sed "s/colorLabelFont/$colorLabelFont/g"|\
	sed "s/colorLabel/$colorLabel/g"|\
	sed "s/colorContentFont/$colorContentFont/g"|\
	sed "s/colorContent/$colorContent/g"|\
	\
	sed "s/nodeID/$1/g"|\
	sed "s/referenceLabel/$2/g"|\
	sed "s|referenceTitle|$3|g"|\
sed "s|referenceNote|$4|g")
	
	
	# if [[ "$5" == 'review' ]]; then
	# tmp=$(echo $tmp | sed "s/$colorLabel/$colorLabelReview/g")
	# tmp=$(echo $tmp | sed "s/$colorContent/$colorContentReview/g")
	# #echo 'review_found'
	# fi
	
	if [[ "$6" == 'high' ]]; then
		tmp=$(echo $tmp | sed "s/$colorLabel/$colorLabelEmphasized/g")
		tmp=$(echo $tmp | sed "s/$colorContent/$colorContentEmphasized/g")
		#echo 'high_rank_found'
	fi
	
	echo $tmp
}

function autowrap {
	# split long string into lines with given length
	# $1: input string
	# $2: length constraint
	
	temp="$(echo $1 | sed -e 's/\/EOS\//\ <BR\/> /g')"
	#temp="$(echo $temp | sed -e 's/\/EOS\//\ <BR\/> /g')"
	#temp=$1
	targetString=''
	tempString=''
	countCharactor=0
	for word in ${temp[@]}; do
		#echo $word
		
		if [ "$word" == '<BR/>' ]; then
			#echo "is BR"
			targetString="$targetString$tempString"
			#targetString+="${#tempString}"
			#targetString+="added by BR"
			targetString+="<BR/>"
			tempString=''
			countCharactor=0	
			#echo $targetString
			# if [[ ${targetString:5}!="<BR/>" ]]; then
				# targetString="$targetString$word"
			# fi	
		else
			#echo "not BR"
			tempString="$tempString $word"
			countCharactor=$(( $countCharactor+ $(( ${#word}+1  )) ))
			#echo $targetString
			#targetString="$targetString $word"
		fi
		if (( $countCharactor > $2 )); then
			#echo "larger than length limit"
			targetString="$targetString$tempString"
			# if [[ ${targetString:5}!="<BR/>" ]]; then
				# targetString="$targetString$word"
			# fi	
			#targetString+="${#tempString}"
			#targetString+="added by limit"
			targetString+="<BR/>"
			tempString=''
			countCharactor=0
			#echo $targetString
		fi
	done
	targetString="$targetString$tempString"
	#targetString+="added by end"
	targetString+="<BR/>"
	tempString=''
	countCharactor=0
	
	
	#echo "$targetString"
	echo `echo "$targetString" |sed -e 's/^[ \t]*//' | sed  -e 's/<BR\/> /<BR\/>/g'\
	| sed  -e 's/<BR\/><BR\/>/<BR\/>/g' | sed  -e 's/ <BR\/>/<BR\/>/g' `
}

function organizeTag {
	#	organized tags, e.g. subgraph, rank, type
	# remove possible blanks in front and at end
	# replace blank in middle with '_'
	# $1: input string
	tmp="$1"
	tmp=${tmp:4:$((${#tmp}-9))}
	tmp=$( echo $tmp| sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//'| tr '[ \t]' '_' )
	echo $tmp
}

function seperateTag {
	# seperate tags
	# tags are seperated by |
	# $1: input string, may contain multiple tags
	# echo "$1"
	tmp="$1"
	tmp=${tmp:4:$((${#tmp}-9))}
	
	IFS='|' read -ra tags <<< "$tmp"
	for i in "${tags[@]}"; do
		tmp2="$i"
		tmp2=$( echo $tmp2| sed -e 's/^[ \t]*//' | sed -e 's/[ \t]*$//'| tr '[ \t]' '_' )
		echo $tmp2
	done
}


#-------------------------------------------------------------------------------
# preparation, read in data into arraies
# scan published year and note first 
# to get rank and parse the note into subgroup, type, rank


declare -a IDArray
declare -a yearArray
declare -a subgroupArray
declare -a typeArray
declare -a rankArray
declare -a noteArray
declare -a edgeLabelArray

count=-1
while IFS=$'\t' read  ID label title note; do
	count=$((count+1))
	IDArray[$count]="$ID"
	yearArray[$count]=${label: -4}
	tmpNote=$( echo "$note" | sed -e 's/\/EOS\/\/EOS\//\/EOS\//g'  )
	
	# parse note
	# subgraph
	tmp=$(echo $tmpNote|grep -o '<SG>.*</SG>' )
	if [ ! -z "$tmp" ]; then subgroupArray[$count]=$(seperateTag "$tmp"); fi
	# type
	tmp=$(echo $tmpNote|grep -o '<TY>.*</TY>' )
	if [ ! -z "$tmp" ]; then typeArray[$count]=$(organizeTag "$tmp"); fi
	# rank
	tmp=$(echo $tmpNote|grep -o '<RA>.*</RA>' )
	if [ ! -z "$tmp" ]; then rankArray[$count]=$(organizeTag "$tmp"); fi
	# note
	tmp=$(echo $tmpNote|grep -o '<NO>.*</NO>' )
	tmp=${tmp:4:$((${#tmp}-9))}
	#echo $tmp
	tmp=$( echo $tmp| sed -e 's/^\/EOS\///' )
	tmp=$( echo $tmp| sed -e 's/\/EOS\/*$//' )
	#echo $tmp
	if [ ! -z "$tmp" ]; then noteArray[$count]=$tmp; fi
	done < "$1"
	
	#echo ${IDArray[@]}
	#echo ${#subgroupArray[@]}
	#printf '%s/n' "${subgroupArray[@]}"
	#echo ${subgroupArray[@]}
	#echo ${#noteArray[@]}
	
	# after read in all the nodes, arrange them according to published year	
	yearSortedUnique=$(echo "${yearArray[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' ')
	yearSortedUnique=($yearSortedUnique)
	
	#-------------------------------------------------------------------------------
	# start writing .gv file
	
	# clear target file and write the head of the .gv file
	>"$2"
	printf  '%s\n' 'digraph G {'>>"$2"
	printf  '%s\n' '    edge [comment="Wildcard node added automatic in EG."];'>>"$2"
	printf  '%s\n' '    node [comment="Wildcard node added automatic in EG.",'>>"$2"
	printf  '%s\n' '          fontname="sans-serif"];'>>"$2"
	#printf  '%s\n' '          rankdir=LR;'>>"$2"
	#printf  '%s\n' '          labelfloat=true;'>>"$2"
	#printf  '%s\n' '          ratio=0.5625;'>>"$2"
	#printf  '%s\n' '          ratio=0.4;'>>"$2"
	#printf  '%s\n' '          size="30,300";'>>"$2"
	#printf  '%s\n' '          fixedsize=true;'>>"$2"
	printf  '%s\n' '          splines=ortho;'>>"$2"
	printf  '%s\n' '          ranksep=0.5;'>>"$2"
	
	# write timeline
	end=$(( ${#yearSortedUnique[*]} - 1 ))
	last=${yearSortedUnique[$end]}
	printf  '%s\n' '    { '>>"$2"
	printf  '%s\n' '        node [shape=plaintext fontsize=28];'>>"$2"
	
	
	for yearCurrent in ${yearSortedUnique[@]};
	do
		if [[ $yearCurrent == $last ]];
		then
			printf  '%s\n' "        $yearCurrent">>"$2"
		else
			printf  '%s\n' "        $yearCurrent -> ">>"$2"
		fi	
	done
	printf  '%s\n' '    } '>>"$2"
	
	
	# load in relationship (edge) information
	# only read in the ones that appears in current graph
	#IDSortedUnique=$(printf "%s\n" "${IDArray[@]}" | sort -u)
	#printf "%s\n" "${IDSortedUnique[@]}"
	#echo ${#IDSortedUnique[@]}
	#echo ${IDSortedUnique[@]} 
	#echo ${IDArray[@]}
	
	
	
	count=-1;
	while IFS=$' ' read  nodeSource nodeSink edgeLabel; do	
		# clean up charactors that add by software automaticall, which cause troubles
		#tmpSource=`echo $nodeSource | sed 's/[^0-9a-zA-Z_]*//g' `
		#tmpSink=`echo "$nodeSink" | sed 's/[^0-9a-zA-Z_]*//g' `
		tmp=`echo "$edgeLabel" | sed 's/[^0-9a-zA-Z_]*//g' `			
		# if [[ ${IDArray[@]} == *"$nodeSink"* ]] && [[ ${IDArray[@]} == *"$tmpSource"* ]]; then
		 if [[ ${IDArray[@]} == *"$nodeSink"* ]] && [[ ${IDArray[@]} == *"$nodeSource"* ]]; then
			case "$tmp" in
			Leads_to)
				printf  '%s\n' "    $nodeSource -> $nodeSink [ weight=4, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			Evaluated_in)
				printf  '%s\n' "    $nodeSource -> $nodeSink [ style=dotted, weight=2, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			Link)
				printf  '%s\n' "    $nodeSource -> $nodeSink [ dir=none, style=dotted, weight=2, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			Invis)
				printf  '%s\n' "    $nodeSource -> $nodeSink [ style=invis, weight=0.5]; ">>"$2"
				;;
			*)
				echo "$edgeLabel"
				echo "edge type not found"
				;;
			esac
			count="(( $count + 1 ))"
			edgeLabelArray[$count]="$tmp"
		else
			:
			 #echo "$nodeSource -> $nodeSink is skipped"
			 #echo "${IDSortedUnique[@]}"
		fi
		done < './rs/relationship'
		edgeLabelArraySortedUnique=($(printf "%s\n" "${edgeLabelArray[@]}" | sort -u))
		
		#if [ 1 -eq 0 ]; then
		printf  '%s\n' "    subgraph cluster_legend { ">>"$2"
		printf  '%s\n' "        node [shape=plaintext]">>"$2"
		printf  '%s\n' "        label=legend;">>"$2"

		for edgeLabel in ${edgeLabelArraySortedUnique[@]}; do
			case "$edgeLabel" in
			Leads_to)
				nodeSource=`cat /dev/urandom | env LC_CTYPE=C tr -cd '0-9' | head -c 8`
				printf  '%s\n' "		$nodeSource [style=invis] ">>"$2"
				printf  '%s\n' "	    "$nodeSource" -> "Leads_to" [ weight=4, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			Evaluated_in)
				nodeSource=`cat /dev/urandom | env LC_CTYPE=C tr -cd '0-9' | head -c 8`
				printf  '%s\n' "    	$nodeSource [style=invis] ">>"$2"
				printf  '%s\n' "    	"$nodeSource" -> "Evaluated_in" [ style=dotted, weight=2, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			Link)
				nodeSource=`cat /dev/urandom | env LC_CTYPE=C tr -cd '0-9' | head -c 8`
				printf  '%s\n' "    	$nodeSource [style=invis] ">>"$2"
				printf  '%s\n' "    	"$nodeSource" -> "Linked" [ dir=none, style=dotted, weight=2, penwidth=3, color=\"$colorNode\"]; ">>"$2"
				;;
			*)
				:;;
			esac	
			
			#printf  '%s\n' "    node [style=bold] ">>"$2"
			#printf  '%s\n' "    a -> b ; ">>"$2"
		
		done 
		printf  '%s\n' '    }'>>"$2"
	#fi
		
		
		
		
		# add nodes
		count=-1
		while IFS=$'\t' read  ID label title note; do
			count=$((count+1))
			IDArray[$count]="$ID"
			yearArray[$count]=${label: -4}
			
			
			titleAutowrapped=`autowrap "$title" "$lengthPerline"`
			noteAutowrapped=`autowrap "${noteArray[$count]}" "$lengthPerline"`
			#echo ${noteArray[$count]}
			#echo $noteAutowrapped
			#echo ${noteArray[$count]}
			
			#echo "$noteAutowrapped"
			if [[ -z "$noteAutowrapped" ]]; then
				#echo "noteAutowrapped is recognized as empty"
				noteAutowrapped=' '
			fi
			
			printf  '%s\n' ''>>"$2"
			#echo ${typeArray[$count]}
			createANode "$ID" "$label" "$titleAutowrapped" \
			"$noteAutowrapped" "${typeArray[$count]}" "${rankArray[$count]}" >>"$2"
			done < "$1"
			
			
			# arrange nodes according to published year	
			## for i in `seq 0 "$count"`;
			for yearCurrent in ${yearSortedUnique[@]};
			do
				:
				printf  '%s\n' ''>>"$2"
				printf  '%s\n' '    { rank = same;'>>"$2"
				printf  '%s\n' "        $yearCurrent;">>"$2"
				for i in "${!yearArray[@]}"; do
					if [[ "${yearArray[$i]}" = "$yearCurrent" ]]; 
					then
						printf  '%s\n' "        ${IDArray[$i]};">>"$2"
					fi
				done
				printf  '%s\n' '    }'>>"$2"
				
				# echo $yearCurrent
				#echo ${IDArray[$i]}
				#echo ${yearArray[$i]}
				
			done
			
			# arrange nodes into subgraph 	
			subgroupSortedUnique=($(printf "%s\n" "${subgroupArray[@]}" | sort -u))
			# echo ${#subgroupArray[@]}
			# echo ${subgroupArray[@]}
			# echo ${#subgroupSortedUnique[@]}
			# echo ${subgroupSortedUnique[@]}
			for subgraphCurrent in ${subgroupSortedUnique[@]};
			do
				
				#echo "$subgraphCurrent"
				# printf  '%s\n' ''>>"$2"
				printf  '%s\n' "    subgraph $subgraphCurrent { ">>"$2"
				printf  '%s\n' "        node [style=invis]">>"$2"
				printf  '%s\n' "        edge [style=invis]">>"$2"
				
				for i in "${!subgroupArray[@]}"; do
					if [[ "${subgroupArray[$i]}" == *"$subgraphCurrent"* ]]; 
					then
						:
						#printf  '%s\n' "        invis_$subgraphCurrent -> ${IDArray[$i]} [weight=1];">>"$2"
						#printf  '%s\n' "        ${IDArray[$i]};">>"$2"
					fi
				done
				printf  '%s\n' '    }'>>"$2"
				
				# echo $yearCurrent
				#echo ${IDArray[$i]}
				#echo ${yearArray[$i]}
				
			done
			
			
			
			# write the end of the .gv file
			printf  '%s\n' '}'>>"$2"