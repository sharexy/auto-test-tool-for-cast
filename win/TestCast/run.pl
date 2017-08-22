#!/usr/bin/perl -w 
use strict;
require "fun.pl";

my $package = $ARGV[0];
my $jar		=$package.".jar"; #"TestCast.jar";
my $method 	= $ARGV[1]; # "youtubeTestDemo";
my $deviceName 	= $ARGV[2];
my $escape 	= $ARGV[3]; # seconds

my $pwd		=&getPWD()."\\".$package;
my $binFolder 	= $pwd."\\bin";

my $class 	= "com.google.android.cast.test.".$package;

my $rt="";

system ("adb push ".$binFolder."\\".$jar." /data/local/tmp/");

sleep (5);

printf ("begin test\n");

system ("adb shell screencap -p /sdcard/screencap.png");
system ("adb pull /sdcard/screencap.png ".$pwd."\\screencap.png");

$rt=readpipe ("adb shell uiautomator runtest ".$jar." -e deviceName \"".$deviceName."\"  -c ".$class."#".$method);

if ($rt=~/end test/){
	
}

sleep ($escape);
	
printf ("end test\n");

sleep (5);