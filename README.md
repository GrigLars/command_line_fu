# Command Line Fu
These are just notes for command line stuff I have learned over the years: shortcuts and so on.  Some are commands that I keep forgetting, or get messed up on the order.  They are in no real order except the most recent discoveries are often on top.  Unless otherwise stated, these are CLI from bash shells on Linux.  These might also help someone else.

#### Sort text file and remove duplicates in place

    sort -uo filename.list filename.list

#### Remove duplicates in a text file without sorting first

    awk '!x[$0]++' /etc/postfix/transport > /tmp/transport_dupes_removed

#### Find your IP on the command line

	curl ifconfig.me
	curl -4/-6 icanhazip.com
	curl ipinfo.io/ip
	curl api.ipify.org
	curl checkip.dyndns.org

#### Making a RAM disk to install an entire OS guest into memory

Sometimes I am just testing an new concept or distro, and I install in directly to RAM. RAM is cheap tese days, and why clutter my hard drive and wear down my SSD with files I am gonna delete right away, anyway?

    sudo mkdir /tmp/ramdisk
    sudo mount -t tmpfs -o size=12G vmramdisk /tmp/ramdisk
    mount | tail -n 1
    
Then I set the install directory to /tmp/ramdisk, play with it, then destroy it. If I need the RAM back, I can just unmount it.

    sudo umount /tmp/ramdisk/

Or make the RAM disk permenant and persistent (athough data will be wiped between reboots).

    vmramdisk  /tmp/ramdisk  tmpfs  defaults,size=12G,x-gvfs-show  0  0    

#### Quick mount of a samba/smb/cifs share ####

    sudo mount -t cifs //diskstation.int.local/Fortran /media/diskstation/fortran -o user=cforrester
    passwd: ****************

#### Visual readout of processes ####

I had an issue where I had to keep an eye out for runaway php processes, and have a more visual way to eyeball it on another screen.  I whipped up this little one-liner to show me the number of php proccesses every 10 seconds:

    while true; do date | tr -d '\n'; foo=$(nice ps aux | grep php | wc -l);\
    echo -n " :: $foo"; printf '%*s' $foo | tr ' ' '*'; echo; sleep 10; done

This prints out a crude bar graph:

    Fri Apr 16 12:41:51 UTC 2021 :: 10**********
    Fri Apr 16 12:42:01 UTC 2021 :: 11***********
    Fri Apr 16 12:42:11 UTC 2021 :: 26**************************
    Fri Apr 16 12:42:21 UTC 2021 :: 27***************************
    Fri Apr 16 12:42:31 UTC 2021 :: 27***************************
    Fri Apr 16 12:42:41 UTC 2021 :: 26**************************
    Fri Apr 16 12:42:51 UTC 2021 :: 15***************
    Fri Apr 16 12:43:01 UTC 2021 :: 12************
    Fri Apr 16 12:43:11 UTC 2021 :: 10**********
    Fri Apr 16 12:43:21 UTC 2021 :: 10**********


#### Adding a user with no password ####

    adduser --shell /bin/bash --disabled-password jenkins

#### Quick Guide to expanding disk size on VMware with Debian/Ubuntu and hoping it's using LVM ####

This assumes that the first disk is **/dev/sda**, and you're adding a third **[3]** partition and using LVM

- Power off the virtual machine
- Extend the virtual disk size
- Power on machine
- ```sudo fdisk /dev/sda```
- p,n,p,3[probably],[enter][enter],t,3[probably],8e[LVM type],w
- Restart machine
- ```sudo pvcreate /dev/sda3```
- ```sudo vgextend vgubuntu /dev/sda3```
- ```sudo vgdisplay vgubuntu | grep "Free"```
- ```sudo lvextend -L+##G /dev/vgubuntu/root``` [where ## is the GB size from previous step]
- ```sudo resize2fs /dev/vgubuntu/root``` [use ext2online if resize2fs gives an error about live filesystems]
- Pray

#### Quick Guide to expanding EBS disk size on AWS with Debian/Ubuntu [LVM not needed] ####

- Expend the EBS in the console or ```aws ec2 modify-volume --size 150 --volume-id vol-1234567890abcdef0``` where 150 is the size in GB
- Then ssh into the instance, check with ```sudo lsblk``` and ```df -h```
- ```sudo growpart /dev/xvda 1``` where xvda 1 [note the space] is the disk volume, parition 1
- ```sudo resize2fs /dev/xvda1``` where xvda1 [no space] is the partition you expanded above
- Prayer not needed

#### Quick Guide to expanding EBS disk size on AWS with Debian/Ubuntu with XFS ####
- Expend the EBS in the console or ```aws ec2 modify-volume --size 150 --volume-id vol-1234567890abcdef0``` where 150 is the size in GB
- Then ssh into the instance, check with ```sudo lsblk``` and ```df -h```
- ```xfs_growfs /mnt``` where /mnt is the mounted disk volume
- ```xfs_fsr``` to optimize
Note: AWS takes a LONG time to optimize from the EBS, and depending on size, may not be done for several hours to half a day. 

#### Removing files over X days old ####

    find /path/to/files* -mtime +5 -exec rm -i {} \;

In this case, 5. Note that there are spaces between rm, {}, and \; and I put an -i for safety in case one cut and pastes. I then hand-fix it to -rf or -r depending on what I need.  Often I am removing log files over 60 days old to save space on really small systems. 

If you are dealing with files, the difference is between mtime, ctime and atime is:

* atime _"access time,"_ is updated when the file's contents are read by an application or a command such as less, grep, or cat.
* ctime _"change time,"_ is when the file's property changes. It will always be changed when the mtime changes, but also when you change the file's permissions, name or location.
* mtime _"modification time,"_ is when the file was last modified. When you change the contents of a file, its mtime changes.

The easiest way to remember which is which is to read their alphabetical order:

* *A*time can be updated alone
* *C*time will update atime
* *M*time will update both atime and ctime.

#### Changing your sudoers file to lecture differently ####

You can change the message you get when someone logs into sudo.  Set lecture=always, never, or once and the message can be set to a text file

    Defaults    lecture=once,lecture_file=/etc/sudo_lecture.txt
    # sudo --reset-timestamp # To reset this "once"
    Defaults 	insults
    # You can insult people who get the sudo password wrong, too

#### Using awk to show lines that have a match in a column ####

Suppose you have an output with columns, and the first, second, or nth column has a match you're looking for, and if that column matches, you print the entire line.  You can use awk, which is designed for this:

    awk '$2 == "LINUX" { print $0 }' test.txt	# Show lines that have LINUX in the second column
    iptables -vL | awk '$1 > 0 { print $0 }'	# Show output of IP tables when the first column (packet hits) is greater than zero
    
#### Regex for email and ip addresses

    grep -E -o "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" email_log.log
    grep -E -o "(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)" list_of_maybe_ips.txt

#### Getting keys and values from bash associative arrays
The keys are accessed using an exclamation point: `${!array[@]}`, the values are accessed using `${array[@]}`

    for i in "${!array[@]}" 
    do
      echo "key  : $i"
      echo "value: ${array[$i]}"
    done

In standard bash arrays, `${!array[@]}` will list indecies, like 0 1 2 ..*n* 

#### How to make a sudoer be able to sudo with no password
If you create a file in `/etc/sudoers.d/<username>` and understand that this is a vulnerability you need to secure HARD... add the line:

    <username> ALL=(ALL) NOPASSWD:ALL

#### You can substitute command output for files
You can substitute commands for files using parentheses.  For example:

    diff <(ls Directory/*.png) <(ls Backups/*.png)
    
#### Move files with ad-hoc web server

    python3 -m http.server [port number]
    wget http://<hostip>:[port number]/filename
    
Launch the web server [default port 8000] and transfer files that way.  Note: only do this on private networks. 

#### Read JSON files in a sane way

    cat test.json | python -mjson.tool
    cat test.json | jq
    
Note, either python or jq have to be installed, respecively. 

#### How to connect to an ansible host NOT in inventory (yet)
Surprisingly, the trick is to append a comma (,) 

    # Host and IP address
    ansible all -i example.com,
    ansible all -i 93.184.216.119,

    # Requires 'hosts: all' in your playbook
    ansible-playbook -i example.com, playbook.yml

#### Have bash determine what quotes to use

    $ # "Nothing's worth more than $20," according to Jim.
    $ !:q
    '# "Nothing'\''s worth more than $20," according to Jim.'

    $ echo '# "Nothing'\''s worth more than $20," according to Jim.'
    # "Nothing's worth more than $20," according to Jim.

#### Update and remove all stale vagrant boxes
To update all your vagrant boxes:

    vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done
    
To update and prune all your outdated boxes, even ones in use:

    vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done && vagrant box prune -f
    
I have a lot of aliases for vagrant because I use it a LOT:

    alias vagpro='vagrant provision'
    alias vagredo='vagrant destroy -f && vagrant up'
    alias vagrm='vagrant destroy -f'
    alias vagssh='vagrant ssh'
    alias vagstat='vagrant global-status'
    alias vagupdate="vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done"
    alias vagtrim="vagrant box list | while read line; do BOX=$(echo $line | awk '{print $1}'); vagrant box update --box $BOX; done && vagrant box prune -f"
    alias vagwho='vagrant global-status'
    alias vgdn='vagrant halt'
    alias vgdown='vagrant halt'
    alias vgssh='vagrant ssh'
    alias vgup='vagrant up'
    
#### Searching for all active crontab jobs
I have found myself in multiple jobs trying to figure out all kinds of cron jobs that are not standardized when I take over a server. Are they in /etc/crontab? Running as a crontab of a user? Something in one of the hours jobs? I developed these four lines of code to find them quickly.

    # Any active jobs in /etc/crontab
      grep -v "^#\|^$" /etc/crontab
    # Any active jobs in the timed directories
      for foo in hourly daily weekly monthly; do echo "==== Cron directory $foo>"; ls /etc/cron.$foo; done
    # Any active jobs in the cron.d directory
      ls /etc/cron.d/*   # grep -v "^#\|^$"
    # Any cron jobs in user crontabs
      for foo in $(ls /var/spool/cron/crontabs/*); do echo "==== User Crontab $foo>"; grep -v "^#\|^$" $foo; done

#### How to List All Running Services Under systemd 

    sudo systemctl --type=service
    sudo systemctl list-units --type=service
    sudo systemctl --type=service --state=active
    sudo systemctl --type=service --state=running
    
Your best bet is to run this as an alias:

    alias sys_active='sudo systemctl --type=service --state=active'
    alias sys_run='sudo systemctl --type=service --state=running'

#### How to run a command for a certain length of time

    timeout 8s ping 192.168.1.1

#### Am I running Raspbian 32 bit or 64 bit?

Run "uname -m" to confirm. If it says aarch64 then it is 64 bit. If it says armv7l then it is 32 bit.  If it says armv61, it's also 32 bit.

#### Check what SSL/TLS client connection you get

This is helpful to find the highest level of TLS that you support.

	openssl s_client -connect [domain]:443 -[tls1/tls1_1/tls1_2/tls1_3]

#### Put your last long command in your editor

Sometimes, you have a long command that you need to edit by hand or swap some stuff out.  Like say you had 

	ansible-playbook -T 60 --extra-vars="foo=bar bar=baz xyzzy=plugh" install-rsyslog-client.yml --vault-password-file=~/.ssh/vault_pass -l manny,mo,jack,cecil,beany,potato1,orangepi1,yakko,rpi-*
	
and the next command, substitute a lot of stuff no easy in one command, run:

	fc
	
It will open up that command in your DEFAULT text editor. What, it's crummy old nano?  Change it to vim.  Open the .bashrc file, and replace both occurrences of program with the editor you want to set as the default editor:

	export EDITOR='vim'
	export VISUAL='vim'
	
Save and reload with "source .basrc"

#### How to measure GPU and CPU temp on a Raspberry Pi

Why was this so hard to find?

    vcgencmd measure_temp
    cat /sys/class/thermal/thermal_zone0/temp

#### More on stdout and stderr

After the post below, I needed a reminder when I look at this page again.

    Handle	Name	Description
    0   	stdin	Standard input
    1   	stdout	Standard output
    2   	stderr	Standard error

    command &>file		# ... OR
    command > file-name 2>&1	# ... pipes both stdout and stderr in a file
    command 2>&1 | less		# ... it can also be piped            
    
    command 2> error.logr.log 	# put only stderr in a log
            
You can also pipe both standard output and standard error into the next stage of the pipeline like this:

	if doesnotexist |& grep 'command not found' >/dev/null
	then
	  echo "oops"
	fi

#### How to grep docker logs

This just seems super annoying, but you have to push all the output to stdout, then grep it, like this example [-f is otional "follow" which I use more often than not]:

    docker logs -f 2434326a55f9 2>&1 | grep "No protocol specified"

#### How to show “Hybrid” line numbers in Vim

	set number
	set relativenumber
	
You can also put the following two config directives in ~/.vimrc

#### For Excel or CSV files

**csvkit** provides in2csv, csvcut, csvjoin, csvgrep, etc.

#### Ah, crap, I didn't mean to type that long command yet, but I don't want to retype it

You can hit **alt+shift+3** which will put a "#" comment in front of it so you can go back to it later in your bash history

#### Some cool hardware reading tricks

What does this box have?  I knew a lot like dmidecde, dmesg, and kernel logs, but there are some new ones:

    # Read BIOS settings
    dd if=/dev/mem bs=1k skip=768 count=256 2>/dev/null | strings -n 8  
    
    lspci -tv    # Show PCI devices
    lsusb -tv    # Show USB devices
    lshal        # Show a list of all devices with their properties
    lsdev        # Information about installed hardware (procinfo has to be installed)
    lshw         # Information about installed hardware

#### How do I prevent a cron job from running over itself if it takes too long?

Use flock (part of the util-linux or flock suite of tools depending on distro).

    $ crontab -l
    * * * * * /usr/bin/flock -w 0 /path/to/cron.lock /usr/bin/php /path/to/cron.php

You can also use fuser to see who and what are using them

	$ fuser -v /path/to/cron.lock
			     USER        PID ACCESS COMMAND
	cron.lock:           root       7836 f.... flock
			     root       7837 f.... php

#### colorize log output

There is a program ccze (not a default install) which replaces colorize but is much faster.  Sadly, it doesn't page by default, so you have to modify the output to ascii and pipe it to less like so:

    ccze -A < /mnt/log/mail.log | less -R

#### remove trailing whitespace

The programs ansible-lint and git hate trailing whitespace, so often I have to remove them from a file with

    sed -i 's/\s*$//g' some_file.yml

#### telnet exit

If you need to escape linux telnet, you hit **control** + **]** which is the escape key "^]".  But you can also change it at the command prompt like:

    telnet -e Q 192.168.0.1 25 
    
Which would set the escape to "Q" 

#### kwallet issues

I kept getting errors in KDE/sddm a.k.a. Kubuntu that would pop up two dialoge boxes that said:

    Configuration file "//.config/kwalletd5rc" not writable. Please contact your system administrator.
    Configuration file "//.kde/share/config/kwalletdrc" not writable. Please contact your system administrator.
    
It did that at every fresh sddm login. For Kubuntu 14.04, 16.04, and even 18.04.  Why is this happening when I don't even USE kwallet?  I did a lot of research, and it turns out that this is due to some bug nobody has fixed for some reason when the pam.d modules are loaded, and they ask for /{$HOME}/[config stuff] and $HOME is not defined. So just disable these 4 lines in /etc/pam.d/sddm

    # -auth   optional        pam_kwallet.so
    # -auth   optional        pam_kwallet5.so

and 

    # -session optional       pam_kwallet.so auto_start
    # -session optional       pam_kwallet5.so auto_start

When you restart, those boxes go away.  I am not sure what this will do when you USE kwallet and its subsystem (probably nothing good), but that wasn't my problem.

#### Something I learned about k3b files

I had a project that I had saved in multiple k3b files.  Years and years went by. I had to see what files were saved and recreate burning audio CDs from them.  First, I had to find CD blanks.  But the next thing was "what the heck are k3b file data stored as?"  I went through a lot of research, and found they are just zipped files with metadata in an XML format stored in them as "maindata.xml."  I had to install the xsltproc and figure out the stylesheet to decode it (included in this repo).  This is imperfect, but it works.  I found out what files they had, and was able to recreate them in K3B or another burner program.

    for foo in $(ls *.k3b); do 
      unzip -p $foo maindata.xml > "$foo.xml"
      xsltproc k3b_stylesheet.xslt $foo.xml > "$foo.cd.txt"
      rm $foo.xml
    done

#### A rare Windows one: get all the system info in a dump

Sometimes I forget what this is called, like msconfig32 or wincfg32 or something.  Always forget it's:

    "C:\Program Files\Common Files\Microsoft Shared\MSInfo\msinfo32.exe"

#### Seeing a conf file without comments or blank spaces

    grep -v "^#\|^$" filename.conf

#### Disabling vagrant-guest plugin for a weird vbox

Sometimes you get a weird box that doesn't want to or just can't install guest additions in VM, so you have to add some tweaks in the vagrantfile in the Vagrant.configure section (usually most of the file):

    Vagrant.configure("2") do |config|
      ....
      if Vagrant.has_plugin?("vagrant-vbguest")
        config.vbguest.auto_update = false
      end
      ....
    end

#### sort IP addresses in a sane way

    sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 ./list_of_addresses.txt

#### awk "print everything past the first two columns" 

For those times you want to weed out time stamps, this will print all but two first columns:

    awk '{$1=$2=""; print $0}' somefile
    
Find the index where you want to start printing (index of $5 in $0) and print the substring of $0 starting at that index.

    awk '{print substr($0,index($0,$5))}' fileName

#### Some git stuff I forget

When, for some reason, my local master branch has some changes I don't care about, to reset to origin/master

    git fetch origin
    git reset --hard origin/master
    git clean -n -f			# Clean localfiles (show only)
    git clean -f			# Clean localfiles (for reals)
    git clean -d -f 			# Also clean local directories
    
If you haven't pulled recently, when branch is out for long time and you need to add changes made to origin/master since

    git rebase master
    
#### Change default browser launched on command line in Ubuntu

    sudo update-alternatives –config x-www-browser

#### Add timeout option to read command, but in case of interactive execution, user can easily skip waiting.

	read -p "Press any key to continue (auto continue in 30 seconds) " -t 30 -n 1

#### AURGH which is it, adduser or useradd?

	useradd - create a user, but not set any passwords or home directories: 
		  good for scripts (useradd -D adds defaults)
	userdel - delete user (userdel -f is a complete purge of home directory, mail spool, etc)
	
	adduser - The interactive shell
	

#### Make sure you are root in a script

	if [ "$(whoami)" != 'root' ]; then
		echo -e "\e[31;1m$0: ERROR: You have no permission to run $0 as non-root user.\e[0m"
		exit 1;
	fi

#### Basic IPtables stuff

Some variables and packages in this Ubuntu example:

	SUBNETINT="192.168.11.0/24"
	apt-get update
	apt-get upgrade -y
	apt-get install -y netfilter-persistent

If ufw is on this system, disable it

	ufw disable

Clear out any old rules

    iptables -P INPUT ACCEPT
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -F
    iptables -Z

Make sure we don't hang up on ourselves, and keep ssh port open

    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT

Set UDP ports for a VPN

    iptables -A INPUT -p udp --dport  500 -j ACCEPT
    iptables -A INPUT -p udp --dport 4500 -j ACCEPT

Set policy routing

    iptables -A FORWARD --match policy --pol ipsec --dir in  --proto esp -s ${SUBNETINT} -j ACCEPT
    iptables -A FORWARD --match policy --pol ipsec --dir out  --proto esp -s ${SUBNETINT} -j ACCEPT
    iptables -t nat -A POSTROUTING -s ${SUBNETINT} -o eth0 -m policy --pol ipsec --dir out -j ACCEPT
    iptables -t nat -A POSTROUTING -s ${SUBNETINT} -o eth0 -j MASQUERADE
    iptables -t mangle -A FORWARD --match policy --pol ipsec --dir in -s ${SUBNETINT} -o eth0 -p tcp -m tcp --tcp-flags SYN,RST SYN -m tcpmss --mss 1361:1536 -j TCPMSS --set-mss 1360


Block all other connections

    iptables -A INPUT -j DROP
    iptables -A FORWARD -j DROP

Save that, needs package "iptables-persistent"

    netfilter-persistent save
    netfilter-persistent reload

#### Network tools 

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

List open interface: lsof -i

	vagrant@ubuntu-xenial:~$ sudo lsof -i
	COMMAND   PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
	dhclient  874    root    6u  IPv4  11617      0t0  UDP *:bootpc 
	chronyd  1402 _chrony    2u  IPv4  17457      0t0  UDP localhost:323 
	chronyd  1402 _chrony    3u  IPv6  17458      0t0  UDP ip6-localhost:323 
	sshd     1424    root    3u  IPv4  16654      0t0  TCP *:ssh (LISTEN)
	sshd     1424    root    4u  IPv6  16663      0t0  TCP *:ssh (LISTEN)
	sshd     2272    root    3u  IPv4  37525      0t0  TCP 192.168.111.15:ssh->192.168.111.2:33696 (ESTABLISHED)
	sshd     2334 vagrant    3u  IPv4  37525      0t0  TCP 192.168.111.15:ssh->192.168.111.2:33696 (ESTABLISHED)

List open interface for just port 22: lsof -i :22


	vagrant@ubuntu-xenial:~$ sudo lsof -i :22
	COMMAND  PID    USER   FD   TYPE DEVICE SIZE/OFF NODE NAME
	sshd    1424    root    3u  IPv4  16654      0t0  TCP *:ssh (LISTEN)
	sshd    1424    root    4u  IPv6  16663      0t0  TCP *:ssh (LISTEN)
	sshd    2272    root    3u  IPv4  37525      0t0  TCP 192.168.111.15:ssh->192.168.111.2:33696 (ESTABLISHED)
	sshd    2334 vagrant    3u  IPv4  37525      0t0  TCP 192.168.111.15:ssh->192.168.111.2:33696 (ESTABLISHED)

    
#### Start a process on a different tty:
This was handy with the Raspberry Pi when I ssh'd in and had to display an output on the attached screen

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

#### Un-ban someone in a running "fail2ban" setup

     fail2ban-client set ssh unbanip 123.123.123.123

#### Ansible notes:
Useful for things that need separate lines:

    extra_lines: |      
      first line
      second line
      third line
      
Will display:

    1. first line
    2. second line
    3. third line

Useful for things that need to be indented but in reality is all one line

    extra_lines: >
      first line
      second line
      third line

Will display:

    first line second line third line

Other stuff:

    --forks  # The default is 5.

    ansible-playbook -u ubuntu -i inventory/dev/ec2.py --vault-password-file=~/.ssh/ansible_vault_pass.txt dev-deploy.yml --private-key=~/.ssh/dev-key.pem --limit 192.168.5.4 --list-hosts

    --check 	# Will do a dry run
    --syntax-check	# Will check yaml structure
    --list-hosts	# Will lists hosts it would run on
    
#### That software that has variables for docker in key/value pairs
- https://consul.io
- https://vaultproject.io

#### Unix permissions: dealing with my dyslexia 
The order is L->R: is User/Owner, Group, Everyone/Other

    -rwxr-xr--  1 amrood   users 1024  Nov 2 00:10  myfile

- User has read, write, execute permissions
- Group "users" has read, execute permissions
- Everyone else has read-only permissions

chmod 0 = no permissions

#### Access control lists:
acl has to be enabled on disk first:

    /dev/sdc1   /encrypt    ext3    defaults,acl    0 0
    
Remount the disk if needed:

    mount -a -o remount    
    
set and read the acl:

    setfacl -Rm "g:dev-interface:rw" /encrypt/sftp
    getfacl /encrypt/sftp

#### VirtualBox management on command line:

Get IP address of running guest:

    VBoxManage guestproperty get {UUID no brackets} "/VirtualBox/GuestInfo/Net/0/V4/IP"
    
Get list of vms/running vms:

    VBoxManage list vms/runningvms
    
#### To change the default editor in Ubuntu

    sudo update-alternatives --config editor

#### That key you like (shorter than the rest, more secure for now):

    ssh-keygen -t ed25519

#### Command line shortcuts 

    CTRL+T : transpose the character before the cursor with the one under the cursor, press Esc + t to transposes the two words before the cursor.
    CTRL+X+backspace : delete all text from the beginning of line to the cursor.

    CTRL+A : move to the beginning of line.
    CTRL+B : move back one character
    CTRL+D : if you've type something, Ctrl + d deletes the character under the cursor, else, it escapes the current shell.
    CTRL+N : same as Down arrow.
    CTRL+P : same as Up arrow.
    CTRL+E : move to the end of line.
    CTRL+F : move forward one character
    CTRL+I : insert a tab
    CTRL+K : cut everything after pointer
    CTRL+K : delete all text from the cursor to the end of line.
    CTRL+U : cut everything before pointer
    CTRL+W : delete word before pointer
    CTRL+Y : paste erased
    CTRL+_ : undo typing.
    CTRL+insert : copy
    CTRL+left/right arrow : Go to beginning of word
    SHIFT+insert: paste

    CTRL+C : SIGTERM
    CTRL+L : redraw screen (helpful if something messes up formatting)
    CTRL+S : to stop output to terminal.
    CTRL+Q : to resume output to terminal after CTRL+S

    CTRL+R : Search history

#### Gives you vi functionality on the command line.

    set -o vi

#### memory info

    vmstat
    free -h
    perf (command)  # May need linux-tools installed
    dstat -ta       # Live stats on cpu/disk/network

#### strace will tell you the path of every file the program tries to open.
Say you've got a utility, and you think it's trying to read a config file, but you don't know what path it's looking for. 

    strace -o [output file]

#### Find all logs which have changed within 5 minutes

    find /var/log -mmin -5 

#### Sometimes instead of netcat you can use socat. Sure it isn't as simple but has a lot more features.

    apt-get install socat

#### Packages you like (note, some may be named different in deb vs. rpm packages):
ncdu screen telnet vim-enhanced multitail lynx bind-utils curl wget openssh-clients lsof net-snmp rsync mlocate man zip unzip htop at yum-utils tree tmux policycoreutils-python boxes figlet sysstat tcpdump 

#### To check an ssh port on SELinux (you need the policycoreutils-python package):
	
    semanage port -l | grep ssh

#### To add an ssh port on SELinux:
	
    semanage port -a -t ssh_port_t -p tcp 222

#### Mailing when people login
In /etc/pam.d/sshd

    session    optional     pam_exec.so /usr/local/bin/send-mail-on-ssh-login.sh

#### show context in grep 2 lines before AND after

    grep -C2 "foo" ./milefile.txt
    
#### Output to clipboard

    command | xclip
    
#### For logs that get rotated, you may want tail -F or tail --follow=name so you start following the new log rather than the old file that got moved out.

    tail -F rotating.log

#### You can also tail -f multiple files simultaneously!  Package multitail also works (with color, too):
    
    tail -f /var/log/*.log is very useful!

#### To terminate an ssh session that's hung or something, type this sequence 

	[Enter] [~] [.]

More of these escape sequences can be listed with [Enter] [~] [?]

	Supported escape sequences:
	  ~.  - terminate session
	  ~B  - send a BREAK to the remote system
	  ~R  - Request rekey (SSH protocol 2 only)
	  ~#  - list forwarded connections
	  ~?  - this message
	  ~~  - send the escape character by typing it twice
	(Note that escapes are only recognized immediately after newline.)

#### Put in your .bashrc or /etc/bash.bashrc for history control

	export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
	export HISTSIZE=100000                   # big big history
	export HISTFILESIZE=100000               # big big history
	shopt -s histappend                      # append to history, don't overwrite it

	# Save and reload the history after each command finishes
	export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


#### awk using multiple field separators, use pipe:
	
    awk -F "=|," 

#### Save a file you edited in vim without the needed permissions

	:w !sudo tee %

#### edit a command in the editor

	ctrl-x-e
	export EDITOR=/usr/bin/vim (to change from nano, put in .bashrc to make permanent)

#### Runs previous command replacing foo by bar every time that foo appears

	!!:gs/foo/bar
	(As opposed to ^foo^bar, which only replaces the first occurrence of foo, this one changes every occurrence.)

#### Put a console clock in top right corner	

	while true; do echo -ne "\e[s\e[0;$((COLUMNS-27))H$(date)\e[u"; sleep 1; done &
	
#### Glob expanding

	[esc] *
	
#### Terminal emulation

	UTF-8 to get proper lines and ncurses and remove â and so on
	
#### Replace a whole line on one match (note "dot star" at beginning and end)

	sed -e "s/.*Alex.*/###########/" deleteme.txt

#### How to I write to dev null again? I always screw the order up in crontab reports.

	[command] > /dev/null 2>&1
	
#### Check if something is in a bash array:

	myarray=(one two three)
	case "${myarray[@]}" in  *"two"*) echo "found" ;; esac

#### Do some stuff with the console (helpful with virsh console [guest]) in Linux KVM

	stty cols 80
	stty rows 50
	TERM=vt100; export TERM

#### Change the text and other Screensaver properties in KDE:
You need to have an ~/.xscreensaver file. There needs to be at least this line: 

		textMode:       program
		textLiteral:    XScreenSaver
		textFile:       
		textProgram:    fortune
		textURL:        http://planet.debian.org/rss20.xml
	
#### yum groups

		yum grouplist 								# Will show you list.  
		yum groupinstall "X Desktop Server" 		# Then you have to enclose it in quotes

#### List a lot of cronbtabs at once:

	ls /etc/cron* + cat
	for user in $(cat /etc/passwd | cut -f1 -d:); do crontab -l -u $user; done
	
#### ASCII "Video" you keep forgetting:

	http://aa-project.sourceforge.net/
	
#### snmpd.conf 

	'dontLogTCPWrappersConnects'      => 'true # To keep "snmpd[3458]: Connection from UDP: [127.0.0.1]:48911" from filling your logs'
	
#### Install XFCE on CentOS 6

	yum groupinstall Xfce
	yum install xorg-x11-fonts-Type1 xorg-x11-fonts-misc
	/sbin/telinit 5
	or startxfce4

#### set in bash

    -e will make the script stop at the first error (instead of coninuting along cheerfully)
    -u will not allow unset/undefined variables (like perl strict)
    -x debug mode 

#### bash sequencing

	for srv in server{1..5}; do echo "$srv";done
	server1
	server2
	server3
	server4
	server5

#### bash sequencing with seq auto-adjusting for width

	for srv in $(seq -w 5 10); do echo "server${srv}";done
	server05
	server06
	server07
	server08
	server09
	server10

#### String maniuplation in bash
len() in bash

	$ var='Hello, World!'
	$ echo "${#var}"
	13
	
left() in bash

    $ var='Hello, World!'
	#${string:position:length}
	$ echo "${var:0:5}"
	Hello
	
right() in bash

	$ var='Hello, World!'
	#${string:position:length}
	$ echo "${var:7:${#var}}"
	World!
	#or a litte more dynamic.. (the 6 most right chars)
	echo "${var:$((${#var}-6)):${#var}}"
	World!
	
mid() in bash

	$ var='Hello, World!'
	#${string:position:length}
	$ echo "${var:4:4}"
	o, W

string replace first in bash (substitute)

	$ var='Hello, World!'
	#${string/substring/replacement}
	$ echo "${var/o/a}"
	Hella, World!

string replace all in bash (substitute)

	$ var='Hello, World!'
	#${string//substring/replacement}
	$ echo "${var//o/a}"
	Hella, Warld!

string to lower case

        $ string="A FEW WORDS"
        $ echo "${string,}"
        a FEW WORDS
        $ echo "${string,,}"
        a few words
        $ echo "${string,,[AEIUO]}"
        a FeW WoRDS
    
string to upper case (all caps)

        $ string="a few words"
        $ echo "${string^}"
        A few words
        $ echo "${string^^}"
        A FEW WORDS
        $ echo "${string^^[aeiou]}"
        A fEw wOrds

Extract string replacing "cut" or "awk" fields

        $ STRING="username:homedir:shell"
        $ echo "$STRING"|cut -d ":" -f 3
        shell
        $ echo "${STRING##*:}"
        shell
	
Extract the value after equal character

	$ VAR="myClassName = helloClass"
	$ echo ${VAR##*= }
	helloClass

Extract text in round brackets:

	$ VAR="Hello my friend (enemy)"
	$ TEMP="${VAR##*\(}"
	$ echo "${TEMP%\)}"
	enemy
	
Set a default value if variable undefined or null

	$ echo ${VAR:-sushi}
	sushi
	$ VAR=sashimi; echo ${VAR:-sushi}
	sashimi

Give an error if a variable is undefined or null

	$ echo ${VAR:?wtf null error}
	bash: VAR: wtf null error
	$ VAR=cookie;echo ${VAR:?wtf null error}
	cookie

Remove a prefix or a suffix of a pattern FROM a variable

	$ x=shark.png
	$ echo ${x%.png}
	shark
	$ echo ${x#shark}
	.png

Find in a variable if it contains substring

        mystring='My string';
        if [[ $mystring =~ "My" ]]; then
            echo "It's there!"
        fi


#### Enable PCRE to group in grep

	tail -f application.log | grep -i -P "(error|warning|failure)"

#### Human copy with progress bar	

	rsync -WavP --human-readable --progress

#### This is a quick step to generate self-signed certificate :

	openssl genrsa 2048 > host.key
	openssl req -new -x509 -nodes -sha256 -days 3650 -key host.key > host.cert
	#[enter *.domain.com for the Common Name]
	openssl x509 -noout -fingerprint -text < host.cert > host.info
	cat host.cert host.key > host.pem
	chmod 400 host.key host.pem

#### I have a keypair. How do I determine the key length?

	openssl rsa -in private.key -text -noout

The top line of the output will display the key size.

    Private-Key: (2048 bit)
	
To view the key size from a certificate:

	openssl x509 -in public.pem -text -noout | grep "RSA Public Key"
	
	RSA Public Key: (2048 bit)	

#### How do I compare a key to a cert?

	openssl x509 -noout -modulus -in /etc/ssl/certs/example.crt | openssl md5;\
	openssl rsa -noout -modulus -in /etc/ssl/private/example.key | openssl md5

#### Get expiration of certificate for various protocols: file, https, pop3, imap, smtps, starttls

	openssl x509 -noout -in server_file.crt -enddate
	echo | openssl s_client -servername https_hostname.com -connect hostname.com:443 2>/dev/null | openssl x509 -noout -enddate
	echo | openssl s_client -connect pop3_hostname.com:995 2>/dev/null | openssl x509 -noout -enddate
	echo | openssl s_client -connect imap_hostname.com:993 2>/dev/null | openssl x509 -noout -enddate
	echo | openssl s_client -connect smtps_hostname.com:465 2>/dev/null | openssl x509 -noout -enddate
	echo | openssl s_client -starttls smtp -connect starttls_hostname.com:587 2>/dev/null | openssl x509 -noout -enddate
	

#### Print out separate colors for each output	

	for foo in $(seq 0 2); do 
		color="[3"
		color+=$(($foo + 1))
		color+="m"
		echo -e "\e$color-------\nprod-sessions-slave$foo\n"
		ssh root@prod-sessions-slave$foo.shrm.org 'df -h'
	done
	echo -e "\e[0m"
	
#### Expand via curly braces:

	for foo in server-cache-{00..12..2}; do
		echo $foo
	done

#### My rsync reminder (because I always get confused)

    rsync -auvz source/ dest/
    rsync -auvz source/ dest
    rsync -auvz source/* dest

will take all the files and subdirectories from source/ and put it into dest/	

#### Formatting time display

    function displaytime {
      local T=$1
      local D=$((T/60/60/24))
      local H=$((T/60/60%24))
      local M=$((T/60%60))
      local S=$((T%60))
      (( $D > 0 )) && printf '%d days ' $D
      (( $H > 0 )) && printf '%d hours ' $H
      (( $M > 0 )) && printf '%d minutes ' $M
      (( $D > 0 || $H > 0 || $M > 0 )) && printf 'and '
      printf '%d seconds\n' $S
    }

#### BASH Auto complete
If you happen to have the servernames listed in a textfile, or if you need to prefix your ssh connections with a username, you could create that server list file like this (with or without the username prefix, depending on how you wish to connect):

    glarson@ndi-web-dev
    glarson@ndi-portal-dev
    glarson@cache-serv001.fishbowl.punkadyne.net 

and so on.  This way, the tab completion will include your username prefix. And to utilize this particular file, you would enter something like this (of course, pointing to your particular server list, not mine):

    complete -W "`cat /home/glarson/serverlist.txt`" ssh

and again, be careful with the quotes and back-ticks.

#### READ LINES WITH SPACES AND STUFF
    
    #!/bin/bash
    file="/home/glarson/list-o-servers.txt"
    while IFS= read -r line
    do
            # display $line or do somthing with $line
            printf '%s\n' "$line"
    done <"$file"

#### You can also read field wise:

    #!/bin/bash
    file="/etc/passwd"
    while IFS=: read -r f1 f2 f3 f4 f5 f6 f7
    do
            # display fields using f1, f2,..,f7
            printf 'Username: %s, Shell: %s, Home Dir: %s\n' "$f1" "$f7" "$f6"
    done <"$file"
    
#### To lock out a user account.  Several ways:

    1. passwd -l $USERACCT                  # -u is unlock, -e expire and set user to change on login
    2. chage -E 0 $USERACCT                 # Setting it to -1 will enable no expiration, otherwise, YYYY-MM-DD
    3. usermod -e 0 $USERACCT               # YYYY-MM-DD format otherwise
    4. usermod -s /sbin/nologin $USERACCT   # Not recommended but can be useful for other purposes

#### To check an ssh port on SELinux (you need the policycoreutils-python package):

	semanage port -l | grep ssh

#### To add an ssh port on SELinux:

	semanage port -a -t ssh_port_t -p tcp 222

#### Make a 4gb swap file

    sudo dd if=/dev/zero of=/swapfile bs=1024 count=4194304
    sudo mkswap /swapfile
    sudo chmod 600 /swapfile
    sudo swapon /swapfile
    sudo echo "/swapfile none  swap  sw 0  0" >> /etc/fstab
    sudo echo "vm.swappiness=50" >> /etc/sysctl.conf
       
Some links:
- https://tldp.org/LDP/abs/html/refcards.html
- https://wiki.bash-hackers.org/syntax/pe
