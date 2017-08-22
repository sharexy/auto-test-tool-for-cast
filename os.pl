#!/usr/bin/perl -w 
use strict;

# get the os 
my $os=lc($^O);

printf ("os=$os\n");

my $f_main="main.pl";
my $f_template="template.xls";
my $ip=$ARGV[0];

if ($os =~ /win/){
	chdir("win");
	# system ("echo %cd%");
	
	system ("perl ".$f_main." ".$f_template." ".$ip."");
}else{
	chdir("linux");
	# system ("echo %cd%");
}