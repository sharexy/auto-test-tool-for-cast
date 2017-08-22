#!/usr/bin/perl -w 
use strict;
require "fun.pl";

my $package = $ARGV[0];
my $jar		=$package.".jar"; 
my $method 	= $ARGV[1]; 
my $deviceName 	= $ARGV[2];
my $escape 	= $ARGV[3]; # seconds
my $restURL	= $ARGV[4]; 
my $pwd		=&getPWD()."\\".$package;
my $binFolder 	= $pwd."\\bin";
# printf ($pwd."\n");
my $class 	= "com.vizio.vue.launcher.test.".$package;
# printf ($class."\n");
my $rt="";


system ("adb push ".$binFolder."\\".$jar." /data/local/tmp/");

sleep (5);

printf ("begin test\n");

# power off
printf ("power off\n");
do {
	$rt=readpipe ("adb shell uiautomator runtest ".$jar." -e deviceName \"".$deviceName."\"  -e restURL \"".$restURL."\" -c ".$class."#".$method);
	
	if ($rt=~/end test/ || $rt=~/INSTRUMENTATION_CODE/ || $rt=~/Time:/){
		
	}
	
	sleep (30);
	
	# read the tv status
	$rt=readpipe ("curl -sL -w \"%{http_code}\" ".$restURL." --connect-timeout 30 --insecure -o /dev/null");
	printf ("1::rt=$rt\n");
}while ($rt eq "200");
	
sleep ($escape);

# power on
printf ("power on\n");
do {
	$rt=readpipe ("adb shell uiautomator runtest ".$jar." -e deviceName \"".$deviceName."\"  -e restURL \"".$restURL."\" -c ".$class."#".$method);

	if ($rt=~/end test/ || $rt=~/INSTRUMENTATION_CODE/ || $rt=~/Time:/){
		
	}
	
	sleep (30);
	
	$rt=readpipe ("curl -sL -w \"%{http_code}\" ".$restURL." --connect-timeout 30 --insecure -o /dev/null");
	printf ("2::rt=$rt\n");
}while ($rt eq "000");

sleep (5);

printf ("end test\n");

