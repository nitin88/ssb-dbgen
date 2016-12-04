#!bin/bash
echo "Current directory:"+`pwd`
for fileName in part.tbl customer.tbl date.tbl supplier.tbl lineorder.tbl
do
	if [ -f $fileName ]
	then
		echo "File $fileName, removing | from end of line"
		tmpFileName="$fileName""tmp"
		sed 's/|$//' $fileName > $tmpFileName
		rm $fileName
		mv $tmpFileName $fileName
	else
		echo "File $fileName NOT found"
	fi
done
