#!/run/current-system/sw/bin/awk -f

# ./awk -v myVar="myVal" <file>

# get vars passed to this script, set FS to C (split on C) & add it back at the end by setting OFS to C as well
BEGIN {
	angleDeg=angleDeg
	angleRad=angleDeg % 360 * (3.141592 / 180)
	centerx=centerx
	centery=centery
	FS = "[C]"
	OFS = "C"
}

/<path id="(Vector|Vector_[0-9])" d=/ {
	v=1 # found a Vector tag!
}

!v {
	# no Vector tag found -> just print
	print
}

v {
	# Vector tag found -> chaos ensues
	# we need to rotate the M (moveto) & C (cubic bezier curve) SVG commands around the center of the circle
	# see https://www.w3.org/TR/SVG/paths.html#PathDataCubicBezierCommands

	# $1, $2, etc. contain the segments divided by 'C' making up the current line (FS is C, see BEGIN)

	# $1 contains the segment with the moveto command, get everything after the M:
	mcommand = substr($1, match($1, /M/))
	split(mcommand, mvals, " |M") # split on spaces & M, number values will be at indexes 2 & 3
	# rotate the moveto point around the centerpoint of the circle
	mnewvals = ""
	mnewvals = mnewvals " " (mvals[2] - centerx) * cos(angleRad) - (mvals[3] - centery) * sin(angleRad) + centerx
	mnewvals = mnewvals " " (mvals[3] - centery) * cos(angleRad) + (mvals[2] - centerx) * sin(angleRad) + centery
	# replace the 2 numbers
	sub(/([0-9]+(\.[0-9]+)? )+([0-9]+(\.[0-9]+)?)/, mnewvals, $1)


	# iterate on all of the segments starting from the second one (the first C command)
    for(i=2; i<=NF; i++) {
		if (i>9) {
			break # we don't have more than 8 C commands & we start at index 2
		}

		split($i, cvals, " |Z"); # split list of numbers on spaces, make sure to not include the trailing Z SVG command

		# rotate all of the points of the C command around the center
		newvals = ""
		newvals = newvals " " (cvals[1] - centerx) * cos(angleRad) - (cvals[2] - centery) * sin(angleRad) + centerx
		newvals = newvals " " (cvals[2] - centery) * cos(angleRad) + (cvals[1] - centerx) * sin(angleRad) + centery
		newvals = newvals " " (cvals[3] - centerx) * cos(angleRad) - (cvals[4] - centery) * sin(angleRad) + centerx
		newvals = newvals " " (cvals[4] - centery) * cos(angleRad) + (cvals[3] - centerx) * sin(angleRad) + centery
		newvals = newvals " " (cvals[5] - centerx) * cos(angleRad) - (cvals[6] - centery) * sin(angleRad) + centerx
		newvals = newvals " " (cvals[6] - centery) * cos(angleRad) + (cvals[5] - centerx) * sin(angleRad) + centery

		# replace the numbers in the current segment with the newly calculated ones
		sub(/([0-9]+(\.[0-9]+)? )+([0-9]+(\.[0-9]+)?)/, newvals, $i)
    }
	# print the line with rotated points
	print $0
	v=0
}
