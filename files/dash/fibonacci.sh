#!/bin/sh

a=0
b=1

while [ "$a" -lt 1000 ]; do
    printf "%d " "$a"
    fn=$((a + b))
    a=$b
    b=$fn
done
