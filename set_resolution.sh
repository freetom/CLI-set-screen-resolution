if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root!"
  exit 1
fi
if [ "$#" -ne 4 ]; then
  echo "Usage: $0 <width> <height> <refresh rate in HZ> <screen>"
  echo "You can get the available screens running 'xrandr'"
  echo "Examples are: VGA1, Virtual1 (on VMWare), etc.."
  exit 1
fi

width=$1
height=$2
rate=$3
screen=$4

# Generate a random tag per each generated resolution, this way we won't have duplicates in screen configurations
random_tag=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | head -n 1)
# Extract the string we need for the monitor configuration
mode=$(gtf $width $height $rate | grep Modeline | awk '{for (i=2; i<NF;i++) printf $i " "; printf $NF}')
# Extract mode name, that is the first string
name=$(echo $mode | cut -d ' ' -f1 | tr -d '"')
# Remove name from mode
mode=$(echo $mode | awk '{for (i=2; i<NF;i++) printf $i " "; printf $NF}')
# Generate new name = original name + '_' + random_tag
name=$(echo "$name $random_tag" | tr ' ' '_')
# Update mode string accordingly
mode=$(echo "$name $mode")


xrandr --newmode $mode
xrandr --addmode $screen $name
xrandr --output $screen --mode $name
