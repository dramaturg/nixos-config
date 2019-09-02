#!/usr/bin/env nix-shell
#! nix-shell --pure -i bash -p feh xorg.xrandr utillinux imagemagick which hostname

#######################################################################
# fancy background stuff

set -o allexport
set -o nounset

dir="$HOME/.wallpaper"
ctime=0
y=0

# to clean up subprocesses in case of sigint
# (for debugging etc)
function handle_sigint()
{
   for proc in $(jobs -p) ; do 
      kill $proc
   done
}
trap handle_sigint SIGINT

function set_background () {
   set -o errexit

   if [ -x $(which taskset) ] ; then
      convert="taskset -c 1 convert"
   else
      convert="convert"
   fi

   test -f "$1"

   # make a copy of the wallpaper for the lockscreen
   # i3lock -i /tmp/.wallpaper.png -t
   $convert "$1" \
       -resize "$(xrandr | awk '/*/{print $1; exit}')^" \
       -gravity center -crop "$(xrandr | awk '/*/{print $1; exit}')+0+0" \
       +repage /tmp/.wallpaper.png &

   if [ "$(hostname)" == "adminwks06" ] ; then
       $convert "$1" "$1" \
           +append -quality 85 /tmp/.wallpaper.png
       feh --bg-fill /tmp/.wallpaper.png
   else
       feh --bg-fill "$1"
   fi
}

# this monitors the display configuration for a change and triggers a reload
# of the background in case the active configuration changes
(
   displayconf=""
   #sleep 5 # wait for the trap to be set

   while [ 1 ] ; do
      if [ "$(xrandr -q | grep '*' | md5sum | cut -f 1 -d ' ')" != "$displayconf" ] ; then
         kill -s ALRM $BASHPID
         displayconf="$(xrandr -q | grep '*' | md5sum | cut -f 1 -d ' ')"
      fi
      sleep 10
   done
) &

while [ -d "$dir" ] ; do
   # update file list if directory has changed
   if [ $ctime != $(stat -c '%Z' $dir) ] ; then
       ctime=$(stat -c '%Z' $dir)
       range=`find -L  "$dir" -type f -iname \*.\* | wc -l`
       IFS='
'
       wallpapers=($(find -L "$dir" -type f -iname \*.\*))
       unset IFS
   fi

   let "number = $RANDOM % ($range-1)"

   # avoid displaying the same picture again
   if [ $number = $y ] ; then
       let "number = ($number + 1) % ($range-1)"
   fi
   y=$number

   set_background "${wallpapers[$number]}"
   trap "set_background \"${wallpapers[$number]}\"" SIGALRM

   # "If bash is waiting for a command to complete and receives a signal for
   #  which a trap has been set, the trap will not be executed until the command
   #  completes"
   for i in {1..30} ; do    # minutes
      for j in {1..6} ; do      # every 10 seconds
         sleep 10
      done
   done
done

