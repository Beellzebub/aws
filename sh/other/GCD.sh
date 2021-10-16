#!/bin/bash

gcd () {
  if [[ $1 -eq $2 ]] ; then
    echo "GCD is $1"
    return
  fi
  if [[ $1 -gt $2 ]] ; then
    gcd "$(( $1-$2 ))" "$2"
  else
    gcd "$1" "$(( $2-$1 ))"
  fi
}
while true ; do
  read -r num1 num2
  if [[ -z $num1  || -z $num2 ]] ; then
    echo "bye"
    break
  fi
  gcd "$num1" "$num2"
done