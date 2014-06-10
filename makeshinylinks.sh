#!/bin/bash
# This is a startup script that searches user-installed shiny applications
# and add these as links to the shiny startup directory
# When you have added a Shiny applications, a reboot is needed
# so that it is added to the Shiny application list.

for i in $( find "/vagrant/shiny-server/R" -name "server.R" ); do
  dn=$(dirname $i)
  array=(${dn//\// })
  for ((i=${#array[@]}-1; i>=0; i--)); do
    if [ ${array[$i]} != "shiny" ]; then
      break
    fi
  done
  target="/vagrant/shiny-server/""${array[$i]}""_Shiny"
  if [ ! -L $target ]; then
    eval "ln -s " "$dn " $target
  fi
done
