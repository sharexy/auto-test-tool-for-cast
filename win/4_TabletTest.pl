use strict;

require "fun.pl";


sub case4_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder, $package, $method, $interval, $input)=@_;
	
	################################################################################################
	# variable initialize
	my ($rt, $node);
	my ($get_value);
	my ($rstVal);
	my ($result);
	my ($caseName);
	my ($restURL);
	
	# prepared scripts
	my ($f_restAPI, $f_input);

	# produced files
	my ($f_result);
	
	
	# printf ("package=%d\n",$package);
	# printf ("method=%d\n",$method);
	# printf ("interval=%d\n",$interval);
	# printf ("input=%d\n",$input);
	# exit(0);
	$caseName=$0;
	$caseName=~/([^\.]+)\.pl/;
	$caseName=$1;
	
	$f_restAPI	="2_RestAPI.pl";
	$f_input	="input.pl";
	$restURL	=$PROTOCOL."://".$IP.":".$PORT."/restlog";
	
	
	
	################################################################################################
	# change input to $input
	if ($input ne ""){
		$input="\"".$input."\"";
	
		# view the current input
		$node="devices/current_input";
		$rt=readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
		
		

		
		if ($rt=~/Result Value=([^,]+),/){
			$get_value=$1;
			
		}
	
		if ($get_value eq $input){
			
		}else {
			while (1){
				$rt=readpipe ("perl ".$f_input." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder);
				
				if ($rt=~/Result Value=$input/){ 
					last;
				}
			}
		
			sleep (10);
			
		}
		
	}
	################################################################################################
	$node="system/system_information/tv_information/cast_name";
	$rt=readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
	
	if ($rt=~/Result Value=([^,]+),/){
		$get_value=$1;
		
	}
	
	if ($get_value eq "\"\""){
		$rstVal="do not get device name";
		$result="FAIL";
		
	}else {
		# run case
		if ($package eq "TestCast"){
			$rt=readpipe ("perl ".$package."\\run.pl ".$package." ".$method." ".$get_value." ".$interval);
			if ($rt=~/end test/){
			}
			
		}elsif ($package eq "TestSmartCast"){
			
			$rt=readpipe ("perl ".$package."\\run.pl ".$package." ".$method." ".$get_value." ".$interval." ".$restURL);
			if ($rt=~/end test/){
			}
			# system ("perl ".$package."\\run.pl ".$package." ".$method." ".$get_value." ".$interval." ".$restURL);
			# printf ("rt=$rt\n");
			# exit(0);
		}
		
		$rstVal="test finished";
		$result="PASS";
		
	}
	
################################################################################################
	# write to result file
	$f_result=$result_folder."\\".$caseName."_".&getDate().".csv";
	
	open (FILE, ">".$f_result);
		printf FILE ("%s, %s, %s\n", "PASS", $result, $result);
	close (FILE);
		
	return ($rstVal, $result, $result_folder);


}

my ($rstVal, $testRst, $comment)=&case4_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6], $ARGV[7], $ARGV[8]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);