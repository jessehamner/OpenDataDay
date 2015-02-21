#!/usr/bin/perl
use warnings;
use strict;

my $filename="frackvoteraw.txt";
my $output="frackvotetabsep.txt";

my $columns="Precinct\tRegisteredVoters\tAbsenteeFOR\tEarlyFOR\tElectionFOR\tChoiceTotalFOR\tAbsenteeAGAINST\tEarlyAGAINST\tElectionAGAINST\tChoiceTotalAGAINST\tTotalVOTES";

open (FILE, "$filename") or die "Could not open input file! $!\n";
open (OUTPUT, ">$output") or die "Could not open output file! $!\n";
print OUTPUT "$columns\n";        # Add better column names to the output document
while (<FILE>) {                  # Cycle through each line of FILE
    chomp;                        # remove line endings...
    s/\015\012|\015|\012/\n/gi;   # ...but line endings are a pain.
    next if(/^Totals:/);          # Don't need the 'Totals' ROW
    next if(/^City/);             # Skip the "City of Denton" line too
    next if(/^Precinct/);         # I have better column titles, above
    next if(/^\s*$/);             # Skip "all spaces or empty" lines
    if ((/against/i) && (/for/i)) # Make the "FOR" and "AGAINST" 
                                  # columns a bit more sane:
    {
#        print OUTPUT "\t\tFor\t\t\t\tAgainst\t\t\t\tALLVOTES\n"
        next
    }
    else
    {
        s/\s{2,}/\t/gi; s/\t$//;  # Replace 2 or more spaces with a tab 
        print OUTPUT "$_\n"       # print the cleaned line to OUTPUT
    }
}
close OUTPUT;
close FILE;

# End of File
