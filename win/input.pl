use strict;

require "fun.pl";

sub input_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder)=@_;
	
	# variable initialize
	my ($rt, $node);
	my ($preVal, $get_value);
	my ($result);
	my ($caseName);

	
	# prepared files
	my ($f_restAPI);
	
	# produced files
	my ($f_result, $f_set_log);
	
	$caseName=$0;
	$caseName=~/([^\.]+)\.pl/;
	$caseName=$1;
	
	# prepared script
	$f_restAPI="2_RestAPI.pl";
	
	# get node info
	$node="devices/current_input";
	
	$rt=readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
	
	$rt=~/Result Value=([^,]*),/;
	$preVal=$1;
	if (! defined ($preVal) ){
		$preVal="";
	}
	# printf ("preVal=$preVal\n");
	
	# switch source to cast, comp, hdmi1, hdmi2 ...
	$f_set_log=$result_folder."\\".$caseName."_".&getDate().".log";
	
	system (
	"curl ".
	"--request PUT ".
	"--header \"content-type: application/json\" ".
	"--header \"auth: ".$AUTH."\" ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/key_command/\" ".
	"--data \"{\\\"KEYLIST\\\":[{\\\"CODESET\\\":7,\\\"CODE\\\":1,\\\"ACTION\\\":\\\"KEYPRESS\\\"},{\\\"CODESET\\\":7,\\\"CODE\\\":1,\\\"ACTION\\\":\\\"KEYPRESS\\\"}]}\" ".
	"--insecure ".
	"> ".
	$f_set_log
	);
	
	sleep (10);
	
	# get node info
	$rt=readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
	
	$rt=~/Result Value=([^,]*),/;
	$get_value=$1;

	if (! defined ($get_value) ){
		$get_value="";
	}
	
	# printf ("get_value=$get_value\n");
	
	if ($get_value eq $preVal) {
		$result="FAIL";
	}else{
		$result="PASS";
	}
	
	# write to result file
	$f_result=$result_folder."\\".$caseName."_".&getDate().".csv";
	
	open (FILE, ">".$f_result);
		printf FILE ("%s, %s, %s\n", $preVal, $get_value, $result);
	close (FILE);
		
	return ($get_value, $result, $result_folder);


}

my ($rstVal, $testRst, $comment)=&input_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);