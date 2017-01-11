#! /bin/bash
# with the ris output by mendeley
# go through csv -> gv -> ps2 -> diagram

flagOutputType="png"

while getopts ":a:" opt; do
	case $opt in
    T)
    	if [ "$OPTARG" == "pdf" ];
    	then
    		echo "$0 creates pdf file"
    		flagOutputType="pdf"
    		elif [ "$OPTARG" == "png" ];
    		then
    			echo "$0 creates pdf file"
    			flagOutputType="png"
    	else
    		echo "Invalid option: -$OPTARG" >&2
    		exit 1
    	fi
    	# echo "-a was triggered, Parameter: $OPTARG" >&2
    	;;
    \?)
    	echo "Invalid option: -$OPTARG" >&2
    	exit 1
    	;;
    :)
    	echo "Option -$OPTARG requires an argument." >&2
    	exit 1
    	;;
    esac
done

# TEMP=$(getopt -o a:: -- "$@")
# eval set -- "$TEMP"
# while true ; do
	# case "$1" in
	# -T)
		# case "$2" in
			# # "pdf")
			# # echo "$0 creates pdf file";
			# # flagProcess="complex"; shift 2 ;;
			# # "png")
			# # echo "$0 creates png file";
			# # flagProcess="simple" ; shift 2 ;;
		# "") echo "Option p, no argument"; exit 1  ;;
		# *) echo "Option p, argument $2 not supported!"; exit 1 ;;
			# esac ;;
		# --) shift; break ;;
		# *) echo "Internal error!"; exit 1 ;;
		# esac
	# done

	# (($DIR/tmp?:mkdir $DIR/tmp))
	# parentDir="$(dirname "$0")"
	#DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	#echo $0
	#echo $DIR
	mkdir ./tmp

	if [ $flagOutputType == "png" ]
	then
		# echo "$0 creates png file"
		# sh "$DIR/ris2csv.sh" "$1" "$DIR/tmp/tmp.csv"
		# #echo "ris2csv done"
		# sh "$DIR/csv2gv.sh" "$DIR/tmp/tmp.csv" "$DIR/tmp/tmp.gv"
		# #echo "csv2gv done"
		# sleep 1
		# dot -Tpng "$DIR/tmp/tmp.gv" -o "$DIR/tmp/tmp.png"
		# #echo "dot done"
		# cp  "$DIR/tmp/tmp.png" "$2"
		# #echo "png done"
		# #sleep 1
		# open "$2"
		# # open "$DIR/tmp/tmp.png"

		echo "$0 creates png file"
		sh ./ris2csv.sh "$1" ./tmp/tmp.csv
		#echo "ris2csv done"
		sh ./csv2gv.sh ./tmp/tmp.csv ./tmp/tmp.gv
		#echo "csv2gv done"
		# sleep 1
		dot -Tpng ./tmp/tmp.gv -o ./tmp/tmp.png
		#echo "dot done"
		cp  ./tmp/tmp.png "$2"
		#echo "png done"
		#sleep 1
		open "$2"
		# open ./tmp/tmp.png"
	else
		# echo "$0 creates pdf file, it takes time"
		# sh "$DIR/ris2csv.sh" "$1" "$DIR/tmp/tmp.csv"
		# sh "$DIR/csv2gv.sh" "$DIR/tmp/tmp.csv" "$DIR/tmp/tmp.gv"
		# dot -Tps2 "$DIR/tmp/tmp.gv" -o "$DIR/tmp/tmp.ps2"
		# ps2pdf "$DIR/tmp/tmp.ps2" "$2"
		# open "$2"

		echo "$0 creates pdf file, it takes time"
		sh ./ris2csv.sh "$1" ./tmp/tmp.csv
		sh ./csv2gv.sh ./tmp/tmp.csv ./tmp/tmp.gv
		dot -Tps2 ./tmp/tmp.gv -o ./tmp/tmp.ps2
		ps2pdf ./tmp/tmp.ps2 "$2"
		open "$2"
	fi
