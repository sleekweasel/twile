#!/usr/bin/perl
#
# Tile windows that appear, preserve new location even if others disappear.
# Too bad if we run out of room (at least, in the first incarnation)

sub geometry {
  my $out = join(' ', @_);
  $out =~ /Window\s(?<id>\d+)\s+Position:\s+(?<x>\d+),(?<y>\d+).*Geometry:\s+(?<w>\d+)x(?<h>\d+)/sm;
  my %out = %+;
  \%out
}


$root = geometry(qx{ xdotool search --name '' getwindowgeometry });
$x=$root->{x};
$y=$root->{y};
$lowest = 0;

while (sleep 1) {
  @windowids = split("\n",qx( xdotool search --onlyvisible --name . ));
  for my $i ( 0..$#windowids ) {
    $j = $i + 1;
    if ($place{$windowids[$i]}) {
      next
    }
    my $win = geometry(qx{ xdotool search --onlyvisible --name . getwindowgeometry %$j });
    last unless $win->{id} == $windowids[$i]; # Oops, window order changed. Try again.
    if ( $x + $win->{w} > $root->{w} + $root->{x} ) {
      $y = $lowest;
      $x = $root->{x};
    }
    if ( $x != $win->{x} || $y != $win->{y} ) {
      qx{ xdotool search --onlyvisible --name . windowmove %$j $x $y };
    }
    $place{$windowids[$i]} = [$x, $y];
    $lowest = $y + $win->{h} if $lowest < $y + $win->{h};
    $x += $win->{w};
  }
}

