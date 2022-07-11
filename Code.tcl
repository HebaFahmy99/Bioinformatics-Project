global sel

proc load {} {
	global flagAlign	
	global flagLoad 
	puts "Enter file name:";
	gets stdin name
	puts "Enter file path:";
	gets stdin path
	set x [file isdirectory $path//$name]

	if {$x == 1} {
		cd $path//$name
		foreach dir [glob -type f *.pdb] {
		puts "$dir"}
		puts "Enter file name:"
		gets stdin x
		mol new $path//$name//$x
	} else {
		set y [file exists $path//$name]
		set z [file readable $path//$name]
		if {$y == 1} {
			if {$z == 1} {
			set flagAlign [mol new $path//$name ]
			set flagLoad 1
			} else {
				puts "File is not readable"
		}
		} else {
			puts "$path//$name not found."
		}
	} 
		puts "File is loaded"
}

set flagLoad 0

proc drawbox {sel} {
  set c [lsort -real [$sel get x]]
  set min_x [lindex $c 0]
  set max_x [lindex [lsort -real -decreasing $c] 0]

  set c [lsort -real [$sel get y]]
  set min_y [lindex $c 0]
  set max_y [lindex [lsort -real -decreasing $c] 0]

  set c [lsort -real [$sel get z]]
  set min_z [lindex $c 0]
  set max_z [lindex [lsort -real -decreasing $c] 0]

  draw materials off
  draw color green
  draw line "$min_x $min_y $min_z" "$max_x $min_y $min_z"
  draw line "$min_x $min_y $min_z" "$min_x $max_y $min_z"
  draw line "$min_x $min_y $min_z" "$min_x $min_y $max_z"

  draw line "$max_x $min_y $min_z" "$max_x $max_y $min_z"
  draw line "$max_x $min_y $min_z" "$max_x $min_y $max_z"

  draw line "$min_x $max_y $min_z" "$max_x $max_y $min_z"
  draw line "$min_x $max_y $min_z" "$min_x $max_y $max_z"

  draw line "$min_x $min_y $max_z" "$max_x $min_y $max_z"
  draw line "$min_x $min_y $max_z" "$min_x $max_y $max_z"

  draw line "$max_x $max_y $max_z" "$max_x $max_y $min_z"
  draw line "$max_x $max_y $max_z" "$min_x $max_y $max_z"
  draw line "$max_x $max_y $max_z" "$max_x $min_y $max_z"
}


proc selectresidue {} {
	global flagLoad
	global sel
	if {$flagLoad == 1} {
		puts "Select residue by (1)name or (2)ID "
		gets stdin choice

		if {$choice == 1} {
			puts "Enter Residue name:";
			gets stdin residuename

			set sel [uplevel "#0" [list atomselect top "protein and $residuename"]]
			$sel get {x y z}

			drawbox $sel
		
		
		} elseif {$choice == 2} {
			puts "Enter range start:";
			gets stdin residstart
			puts "Enter range end:";
			gets stdin residend

			set sel [ uplevel "#0" [list atomselect top "resid $residstart to $residend"]]

			$sel get {x y z}
			drawbox $sel

		} 
		} else {  
		puts "NO FILE LOADED"}  
		return $sel
}




proc saveselection {} {
	global sel 
	puts "Enter Path:"
	gets stdin path
	puts "Enter name of folder:"
	gets stdin foldername
	set x [file isdirectory $path//$foldername]

	set y [file writable $path//$foldername]

	if {$x == 1 } {
		if {$y == 1} {
			cd $path//$foldername
			puts "Enter name to the file:"
			gets stdin filename
			
			$sel writepdb $path//$foldername//$filename


		} else {puts "You don't currently have permission to access this folder" }}  else { puts "Path is not found" }

}


proc analyze {} {
	set all [atomselect top "all"]
	 #number of atoms
	set sumOfatoms [$all num]

	set numOfResidues [llength [lsort -unique [$all get residue]]]

	
	set var1 [format "%-1s %7d " "Number of atoms:" "$sumOfatoms"]
	set var2 [format "%-1s %4d " "Number of residues:" "$numOfResidues"]
	puts $var1
	puts $var2
	

}

proc processresidue {} {
	set sel [atomselect top "all"] ;

	foreach res_pair [lsort -unique [$sel get {resname}]] { 
		lassign $res_pair resname  	
		set c [atomselect top "resname $res_pair"]	
		set x [$c num]
		for {set b 0} { $b <= $x} {incr b 10} {
		$c set beta $b
		incr {$x} 1	
		}
		incr ($resname) 1
		set p [format "%-1s %10d " "$res_pair" "[$c num]"]
		puts $p

}
}

proc align {} {
	global flagAlign
	mol delete top
	load
	set sel_0 [atomselect $flagAlign all]	 
	load
	set sel_1 [atomselect $flagAlign all] 
	set fit [measure fit $sel_0 $sel_1]	 

	$sel_0 move $fit
	puts "Alignment is done!"
}

while {1} {
	set flag 1
	puts "Hello User, Choose your action with number from 1 to 6";
	puts "1. Load File";
	puts "2. Select a residue";
	puts "3. Save Selection";
	puts "4. Analyze";
	puts "5. Process Residues";
	puts "6. Align Molecules";
	puts "7. EXIT";
	
	gets stdin var
	puts "you entered $var";
	
	switch $var {
	1 {
		load
	  }
	2 {
		selectresidue
	  }
	3 {
		saveselection
	  }
	4 { 
		analyze
	  }
	5 {
	    processresidue
	  }
	6 { 
		  
		align 
	  }
	7 {
		global flag
		set flag 0
		puts "EXITING"
		break
	  }
	default {
		puts "INVALID OPTION"
	}

}}
 
 
#F://3-FCAI-CU-SECOND//Bioinformatics//Assignment_20198096_20198073_20198030.tcl