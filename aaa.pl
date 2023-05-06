#!/usr/bin/perl

use strict;
use warnings;

# Open file for reading
open my $input_file, '<', 'topol.top' or die "Could not open file: $!";

# Open temporary file for writing
open my $temp_file, '>', 'temp.top' or die "Could not create temporary file: $!";

# Loop through each line of input file
my $has_added_content = 0;
while (my $line = <$input_file>) {
    if ($line =~ /^\s*#\s*endif/ && !$has_added_content) {
        $has_added_content = 1;
        print $temp_file $line;
        print $temp_file "\n; Include edy topology\n#include \"./ligand.itp\"\n\n; Include edy restraint file\n#ifdef POSRES_LIG\n#include \"./ligand_posre.itp\"\n#endif\n";
    }
    elsif ($line =~ /^\s*#\s*include/) {
        print $temp_file $line;
    }
    else {
        print $temp_file $line;
    }
}

print $temp_file "EDY\t1\n";
# Close files
close $input_file;
close $temp_file;

# Rename temporary file to original file
rename 'topol.top', 'topol_origin.top' or die "Could not rename temporary file: $!";

rename 'temp.top', 'topol.top' or die "Could not rename temporary file: $!";
