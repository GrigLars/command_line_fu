# Command Line Fu
These are just notes for command line stuff I have learned over the years: shortcuts and so on

#### Netstat 

    netstat -peanut
    
    ubuntu@vpn-strongswan:~$ netstat -peanut
    (Not all processes could be identified, non-owned process info
    will not be shown, you would have to be root to see it all.)
    Active Internet connections (servers and established)
    Proto Recv-Q Send-Q Local Address           Foreign Address         State       User       Inode       PID/Program name
    tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      0          15747       -               
    tcp        0      0 10.42.5.36:22           10.3.7.69:3151          ESTABLISHED 0          20138       -               
    tcp        0      0 10.42.5.36:22           10.3.7.69:36800         ESTABLISHED 0          24746       -               
    tcp        0    376 10.42.5.36:22           10.3.7.69:52220         ESTABLISHED 0          20293       -               
    tcp        0      0 10.42.5.36:22           10.3.7.69:62004         ESTABLISHED 0          23877       -               
    tcp        0      0 10.42.5.36:22           10.3.7.69:41994         ESTABLISHED 0          24438       -               
    tcp6       0      0 :::22                   :::*                    LISTEN      0          15760       -               
    udp        0      0 0.0.0.0:68              0.0.0.0:*                           0          14371       -               


#### Start a process on a different tty:
This was handy with the Raspberry pi when I ssh'd in and had to display an output on the attached screen

    setsid sh -c 'exec command <> /dev/tty2 >&0 2>&1'

#### Windows instead of snipping tool shortcut

    Win + shift + s
 
#### Show what inputs are attached and to disable touchpad on Levono laptops with Ubuntu

    xinput list

You will get output like:

    Virtual core pointer                      id=2    [master pointer  (3)]
    Virtual core XTEST pointer                id=4    [slave  pointer  (2)]
    SynPS/2 Synaptics TouchPad                id=12   [slave  pointer  (2)]
    Virtual core keyboard                     id=3    [master keyboard (2)]
    Virtual core XTEST keyboard               id=5    [slave  keyboard (3)]
    Power Button                              id=6    [slave  keyboard (3)]
    Video Bus                                 id=7    [slave  keyboard (3)]
    Power Button                              id=8    [slave  keyboard (3)]
    Sleep Button                              id=9    [slave  keyboard (3)]
    Laptop_Integrated_Webcam_1.3M             id=10   [slave  keyboard (3)]
    AT Translated Set 2 keyboard              id=11   [slave  keyboard (3)]
    Dell WMI hotkeys                          id=13   [slave  keyboard (3)]

Then type:

    xinput set-prop 12 "Device Enabled" 0

