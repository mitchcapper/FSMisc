fs_logger.pl a data collection and obfuscation tool for FreeSWITCH
=================================
OVERVIEW
-----
fs_logger.pl is primarily a tool to assist with the collection of logging data from freeswitch. It runs fs_cli at the core and excepts all the parameters fs_cli takes in addition to its own. It also provides some extended features around fs_cli and data logging. The tool will save the log data it collects either to a file or send it to pastebin depending on the command line option and can optionally obfuscate of sensitive information before doing so. When done with fs_logger.pl hit control + c. fs_logger.pl will try to clean up any changes it made to loglevels of tracing prior to exiting. fs_logger.pl can run in interactive mode which allows it to provide fs_cli basic emulation (so you can use one shell for logging and interacting with FreeSWITCH). 

Table of Contents
=================

   * [Requirements / Download / Installation](#requirements--download--installation)
   * [Usage](#usage)
     * [Auto Mode (-A)](#auto-mode--a)
     * [Obfuscation (-oa -of)](#obfuscation--oa--of)
     * [Interactive Options (-ia -do)](#interactive-options--ia--do)
     * [Pastebin / Output File (-pb -f -pbt -pbn -pbp)](#pastebin--output-file--pb--f--pbt--pbn--pbp)
     * [fs_logger.pl Debug Mode (-D)](#fs_loggerpl-debug-mode--d)
     * [Just Read File (-jrf)](#just-read-file--jrf)
     * [Command Execution (-x -X)](#command-execution--x--x)
     * [Sip Tracing (-st)](#sip-tracing--st)
     * [Freeswitch / Sofia Log Level (-l -sd)](#freeswitch--sofia-log-level--l--sd)
   * [Improvements/ Contributions/ Bug Fixes](#improvements-contributions-bug-fixes)
   * [Helping Others Debug with fs_logger.pl](#helping-others-debug-with-fs_loggerpl)
   * [Memory Usage](#memory-usage)

Requirements / Download / Installation
------------
fs_logger.pl does not depend on any external dependencies and works on Windows/Linux/OS X, as long as you have a working fs_cli (from version 1.2 of FS or git master from after 4/7/2012) you can use fs_logger.pl. If you are on Windows and do not want to install perl you can download a standalone fs_logger.exe version that does not require perl at all.

Download of the latest version can be found at: https://github.com/mitchcapper/FSMisc/raw/master/fs_logger.pl or short redirect url of: http://fluky.org/fs_logger.pl place it in the same folder as fs_cli and if you run linux make sure its executable (chmod +x fs_logger.pl)

A compiled windows exe that does not require perl can be found at: http://mitchcapper.com/fs_logger.exe

You do not need to install fs_logger.pl however it must be able to find fs_cli. It will search for fs_cli (or fs_cli.exe) in the same folder as fs_logger.pl, the working directory, and in the default location for the system (c:/program files/Freeswitch/fs_cli.exe or /usr/local/freeswitch/bin/fs_cli). 

Usage
------------
     Usage: fs_logger.pl options
       -A, --auto                     Auto mode, equiv of -pb -do -st internal -l 7 -ia
       -h, --help                     Usage Information
       -H, --host=hostname            Host to connect
       -P, --port=port                Port to connect (1 - 65535)
       -u, --user=user@domain         user@domain
       -p, --password=password        Password
       -x, --execute=command          Execute Command on connect
       -X, --quit-execute=command     Execute Command when quitting
       -l, --loglevel=command         Log Level
       -d, --debug=level              fs_cli Debug Level (0 - 7)
       -t, --timeout                  Timeout for API commands (in milliseconds)
       -q, --quiet                    Disable logging
       -r, --retry                    Retry connection on failure
       -R, --reconnect                Reconnect if disconnected
       -f, --file=<file>              Output file
       -pb --paste-bin[=<name>]       Post to FS Pastebin (optional post as)
       -st --sip-trace[=<profile>]    Sip trace (optional profile to trace on)
       -sd --sip-debug=<level>        Set SIP debug level
       -oa --obfuscate-auto           Auto obfuscate sensitive information
       -of --obfuscate-file=<file>    File containing strings to obfuscate
       -do --display-output           Display output on stdout
       -ia --input-accept             Pass input to the freeswitch console
       -D, --fslogger-debug           FSLogger debug mode
       -jrf --just-read-file=<file>   Read file instead of collecting log from fs_cli
       -pbt --pastebin-time=<time>    Minutes until it expires, forever(default)
       -pbn --pastebin-name=<title>   Title for the pastebin
       -pbp --pastebin-private        Make the pastebin private
          The -st, -X, -x options can be used multiple times
          fs_logger.pl will run until fs_cli ends or control+c

### Auto Mode (-A)

Auto mode (or -A) turns on a few different options to some defaults that are generally what developers are looking for when debugging. All the options it would set are not overwritten if already specified on the command line. To see the exact options it turns on see -h but in short it will enable sip tracing on the internal profile, turn up some debug levels and send the results to pastebin.

### Obfuscation (-oa -of)

The auto obfuscation mode (-oa) will try to randomize any ips/passwords/hashes or domains found in the log file. It tries to do so in a discrete manor so that it does not interfere with debugging (mainly ips/passwords/hashes/domains). IP addresses when randomized have their common subnets preserved relative to each other. This means 192.168.50.10 may turn into 123.123.123.8 but ensures that 192.168.50.30 will have the same base (123.123.123.) class so networks can be identified.

The file obfuscation (-of) allows you to manually specify sensitive data you want always obfuscated and optionally what to obfuscate it with (say swap your company name from the logs for something generic).   File should have one entry per line.  If the line starts with a '^' it treats the pattern as a regular expression, you can optionally capture groups to only replace those groups or no groups and it will replace the entire match. If line contains an equals sign(not proceeded by a '\') what is to the right of the equals sign is used as the replacement.  Note keep in mind the longest items are replaced first.  This means if you tell it to replace XYZ but the text contains  XYZ.com it will not be replaced by what you specified (unless you specify XYZ.com).

### Interactive Options (-ia -do)

The -ia and -do options allow fs_logger.pl to behave more like you were interacting with fs_cli directly. The display ouput (-do) option shows you what data is being logged as its being generated (although not obfuscated yet). The input accept mode (-ia) passes lines you type in fs_logger.pl to fs_cli. With both these options it is almost exactly as if you were interacting with fs_cli. There are a few minor differences: tab auto complete does not work, function keys (F1-F12) do not work, up and down for history only work in windows (as its the console that actually does it there) and there is no colorization of lines.

### Pastebin / Output File (-pb -f -pbt -pbn -pbp)

One of these options must be specified. -f will just save the captured output to the filename specified. -pb will post the captured output up to pastebin, you can option pass a username (-pb user) to post to pastebin as. -pbt allows you to specify how long the pastebin will remain in minutes, by default its forever you can pass -pbt d for day or -pbt m for month also.  -pbn allows specifying of the title for the pastebin and -pbp marks the pastebin as private (not on the recent list).

### fs_logger.pl Debug Mode (-D)

If for some reason fs_logger.pl doesn't work as it should -D may help print out some additional information about what its doing to help trace the issue.

### Just Read File (-jrf)

This flag allows for you to just read a file in and use its contents as if that was what fs_cli has spit out. fs_logger.pl does not connect to the FreeSWITCH server at all when this is used and jumps straight to the finish function which will optionally obfuscate the file and/or pastebin or write out the file to disk. This is useful if you want to try and tweak your -of file but allowing you to used a previously captured log file and rather than re-capture data. It can also be used to just throw a file onto pastebin. You can optionally obfuscate the file (using the options above) but do not have do. ./fs_logger.pl -pb -jrf test.c will post test.c to the pastebin with the proper syntax highlighting and no other changes. ./fs_logger.pl -of of_file.txt -pb -jrf profile.xml will run profile.xml through the obfuscater for the items specified in of_file.txt.

### Command Execution (-x -X)

-x is for commands to execute on connect and -X is for commands to execute on disconnect. You can use them multiple times and they will be executed one after another once fs_logger.pl connects to the server.

### Sip Tracing (-st)

Sip tracing causes all the sip traffic to be printed on one or more of the sofia profiles. You can use -st without any options to enable tracing on all profiles, or use it with a specific profile (-st internal) to enable it on just that profile. You can use it multiple times to enable it only on a few select profiles.

### Freeswitch / Sofia Log Level (-l -sd)

You can set the freeswitch log level (warn/info/debug etc) using the -l setting, it will default to debug by default. You can also set the sofia loglevel for all sofia components with -sd (0-9).

Improvements/ Contributions/ Bug Fixes
------------
Are all very welcome, catch me on IRC (MitchCapper) or a PR/Bug Report on github

Helping Others Debug with fs_logger.pl
------------
To help users remotely debug [fs_logger.pl] can be a powerful script. First have them put fs_logger.pl in their bin folder, a simple "wget http://fluky.org/fs_logger.pl && chmod +x fs_logger.pl" will get them started. It allows you to give users simple commands to capture much of the logging needed to help troubleshoot their problem. For example if a user is unable to complete a call you could tell them to run: 
./fs_logger.pl -A

Memory Usage
------------
It's important to note that fs_logger.pl keeps all output in memory until its done. This makes it may eat several megabytes of memory if you leave fs_logger.pl running for weeks or months if freeswitch is outputting a lot of data or has a very high debug mode enabled. 