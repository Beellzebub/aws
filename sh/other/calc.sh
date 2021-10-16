#!/bin/bash

while true ; do
  read -r arg1 operand arg2
  if [[ $arg1 == "exit" ]] ; then
    echo "bye"
    break
  elif [[ ! "$arg1" =~ ^[0-9]+$ && ! "$arg2" =~ [0-9]+$ ]] ; then
    echo "error"
    break
  else
    case $operand in
    "+") echo "$((arg1 + arg2))" ;;
    "-") echo "$((arg1 - arg2))" ;;
    "*") echo "$((arg1 * arg2))" ;;
    "/") echo "$((arg1 / arg2))" ;;
    "%") echo "$((arg1 % arg2))" ;;
    "**") echo "$((arg1 ** arg2))" ;;
    *) echo "error" ; break ;;
    esac
  fi
done
