#!/usr/bin/env perl

use strict;
use warnings;

my $a = 0;
my $b = 1;
my $fn;

while ($a < 1000) {
    print "$a ";
    $fn = $a + $b;
    $a = $b;
    $b = $fn;
}
