open(FILE,"<report.txt");
open(OUT,">danger.txt");
open(CSV,">danger.csv");

while ($line = <FILE>) {
  $line =~ /(\d+).*\[DIFF (\d)\] -- (\d+)/;
  print "Level $1 (D$2) -- $3\n";
  push @{ $diff[$2][$1] }, $3;
}

for $dlevel (1..5) {
  if (not defined ($diff[$dlevel][1])) { next; }
  print OUT "\nDanger Level $dlevel\n--------------\n";
      
  for $level (1..24) {
    if (not defined ($diff[$dlevel][$level])) { next; }
    
    $total = 0;
    $row = $diff[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $avg = int($total / scalar @$row);
    print OUT "Average L$level = $avg\n";
    print CSV "$avg,";
  }
  print CSV "\n";
}

close(FILE);
close(OUT);
close(CSV);
