open(FILE,"<ireport.txt");
open(OUT,">item.txt");
open(CSV,">item.csv");

while ($line = <FILE>) {
  $line =~ /(\d+).*\[DIFF (\d)\] -- (\d+) - A:(\d+) P:(\d+) W:(\d+) U:(\d+) AR:(\d+)/;
  print "Level $1 (D$2) -- $3\n";
  push @{ $count[$2][$1] }, $3;
  push @{ $ammo[$2][$1] }, $4;
  push @{ $power[$2][$1] }, $5;
  push @{ $weapon[$2][$1] }, $6;
  push @{ $use[$2][$1] }, $7;
  push @{ $armor[$2][$1] }, $8;
}

for $dlevel (1..5) {
  if (not defined ($count[$dlevel][1])) { next; }
  print OUT "\nDanger Level $dlevel\n--------------\n";
      
  for $level (1..24) {
    if (not defined ($count[$dlevel][$level])) { next; }
    
    $total = 0;
    $row = $count[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $avg = int($total / scalar @$row);
    print OUT "Items L$level = $avg ";
    
    $total = 0;
    $row = $ammo[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $av = int($total / scalar @$row);
    print OUT "(ammo - $av) ";
    
    $total = 0;
    $row = $power[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $av = int($total / scalar @$row);
    print OUT "(power - $av) ";

    $total = 0;
    $row = $weapon[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $av = int($total / scalar @$row);
    print OUT "(weapon - $av) ";

    $total = 0;
    $row = $use[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $av = int($total / scalar @$row);
    print OUT "(use - $av) ";

    $total = 0;
    $row = $armor[$dlevel][$level];
    foreach $item (@$row) {
      $total += $item;
    }
    $av = int($total / scalar @$row);
    print OUT "(armor - $av) ";
    
    print OUT "\n";
    print CSV "$avg,";
  }
  print CSV "\n";
}

close(FILE);
close(OUT);
close(CSV);
