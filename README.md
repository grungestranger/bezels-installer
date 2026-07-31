## About bezels-installer

Bash script that writes an overlay option to the retroarch game configs.  
Bezelproject items should be used as the overlay.  
The script searches for the appropriate bezel for each rom you have.

The script can be run directly on the android console via Termux.

## Example

We place the file **run.sh** on the android console in the **/storage/sdcard0/bezels-installer-main** directory.

We have a directory with roms - **/storage/sdcard0/roms**  
(Here we have: nes, snes... and other game-system directories)

There is also a bezels directory (you should put the sets of bezels here): **/storage/sdcard0/bezels**  
(Here we have: bezelproject-NES-master, bezelproject-MasterSystem-master, bezelproject-GBA-master... and other directories)

There is also a RetroArch directory: **/storage/emulated/0/RetroArch**  
(Here we have: config, saves, states... and other directories)

Run the script via Termux:  
`bash /storage/sdcard0/bezels-installer-main/run.sh /storage/sdcard0/roms /storage/sdcard0/bezels /storage/emulated/0/RetroArch`

If you need to process only one system, you need to add its name using the following parameter. For example:  
`bash /storage/sdcard0/bezels-installer-main/run.sh /storage/sdcard0/roms /storage/sdcard0/bezels /storage/emulated/0/RetroArch nes`

_Created by grungestranger_
