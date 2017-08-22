#!/usr/bin/perl -w 

use strict;

require "fun.pl";

sub case2_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder, $node, $set_value)=@_;
	
	# printf ("PROTOCOL=$PROTOCOL\n");
	# printf ("IP=$IP\n");
	# printf ("PORT=$PORT\n");
	# printf ("AUTH=$AUTH\n");
	# printf ("result_folder=$result_folder\n");
	# printf ("node=$node\n");
	# printf ("set_value=$set_value\n");
	
	# variable initialize
	my ($HASHVAL, $get_value );
	my ($result);
	my ($f_node, $f_get_log, $f_set_log, $f_result);
	
	$f_node=$node;
	$f_node=~s/\//-/g;

	$f_get_log=$result_folder."\\".$f_node."_get_".&getDate().".log";
	
	# get node info	
	sleep (5);
	
	system (
	"curl ".
	"--request GET ".
	"--header \"auth: ".$AUTH."\" ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/menu_native/dynamic/tv_settings/".$node."\" ".
	"--insecure ".
	"> ".
	$f_get_log
	);
	
	sleep (5);
	
	($HASHVAL, $get_value)=&getHashVal($f_get_log);
	
	if (! defined ($get_value)) {
		$get_value="";
		$result="FAIL";
		
	} else {
		
		if (! defined ($set_value) ){
			$set_value="";
			$result="PASS";
			
		} else {
			
			if ( $get_value=~/^".*"$/ ){
				$set_value="\\\"".$set_value."\\\"";
				
			}
			
			# set value
			$f_set_log=$result_folder."\\".$f_node."_set_".&getDate().".log";
			
			sleep (5);
			
			system (
			"curl ".
			"--request PUT ".
			"--header \"content-type: application/json\" ".
			"--header \"auth: ".$AUTH."\" ".
			"--url \"".$PROTOCOL."://".$IP.":".$PORT."/menu_native/dynamic/tv_settings/".$node."\" ".
			"--data \"{\\\"REQUEST\\\":\\\"MODIFY\\\", \\\"HASHVAL\\\":".$HASHVAL.", \\\"VALUE\\\":".$set_value."}\" ".
			"--insecure ".
			"> ".
			$f_set_log
			);
			
			sleep (10);
			
			# get value
			$f_get_log=$result_folder."\\".$f_node."_get_".&getDate().".log";
			
			sleep (5);
			
			system (
			"curl ".
			"--request GET ".
			"--header \"auth: ".$AUTH."\" ".
			"--url \"".$PROTOCOL."://".$IP.":".$PORT."/menu_native/dynamic/tv_settings/".$node."\" ".
			"--insecure ".
			"> ".
			$f_get_log
			);
			
			sleep (5);
			
			($HASHVAL, $get_value)=&getHashVal($f_get_log);
			
			if (! defined ($get_value)) {
				$get_value="";
				$result="FAIL";
				
			}else{
				if ( $get_value=~/^"[^"]*"$/ ){
					$set_value=~s/^(\\\"){1}/\"/;
					$set_value=~s/(\\\"){1}$/\"/;
				}
				
				# compare the result
				if (
				($set_value eq $get_value) ||
				($set_value =~ /^$get_value\*?$/)
				){
					$result="PASS";
				}else{
					$result="FAIL";
				}
			}
			
		}
	}
	
	# write to result file
	$f_result=$result_folder."\\".$f_node."_".&getDate().".csv";
	
	open (FILE, ">".$f_result);
		printf FILE ("%s, %s, %s\n", $set_value, $get_value, $result);
	close (FILE);
		
	return ($get_value, $result, $result_folder);
	
}

my ($rstVal, $testRst, $comment)=&case2_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);