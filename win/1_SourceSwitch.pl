use strict;

require "fun.pl";


sub case1_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder, $input, $url, $time, $expVal)=@_;
	
	################################################################################################
	# variable initialize
	my ($rt			);
	my ($node		);
	my ($get_value	);
	my ($result		);
	my ($caseName	);
	
	# prepared scripts
	my ($f_restAPI	);
	my ($f_input	);
	
	# produced files
	my ($f_log		);
	my ($f_result	);

	$caseName	=	$0;
	$caseName	=~	/([^\.]+)\.pl/;
	$caseName	=	$1;
	
	$f_restAPI	=	"2_RestAPI.pl";
	$f_input	=	"input.pl";
	
	################################################################################################
	# change input to $input
	if ($input ne ""){
		$input	=	"\"".$input."\"";
		
		$node	=	"devices/current_input";
		$rt		=	readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
	
		if ($rt	=~	/Result Value=([^,]+),/){
			$get_value	=	$1;
			
		}
		
		if ($get_value eq $input){
				
		} else {
			while (1){
				$rt	=	readpipe ("perl ".$f_input." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder);
				
				if ($rt	=~	/Result Value=$input/){ 
					last;
					
				}
				
			}
			
			sleep (10);
		}
	}
	
	################################################################################################
	# run case
	if ($url ne ""){
		$f_log	=	$result_folder."\\".$caseName."_".&getDate().".log";
	
		system (
		"curl ".
		"-d \"".$url."\" ".
		"\""."http"."://".$IP.":"."8008"."/apps/Fling\" ".
		"> ".
		$f_log
		);
	}
	
	sleep ($time);
	
	################################################################################################
	# get resolution
	$node	=	"system/system_information/tv_information/resolution";
	
	$rt		=	readpipe ("perl ".$f_restAPI." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node);
	
	if ($rt	=~	/Result Value=([^,]+),/){
		$get_value	=	$1;
		
	}
	
	if (defined ($get_value)){
		if ($get_value	=~	/^"[^"]*"$/){
			$expVal	=	"\"".$expVal."\"";
			
		}
		
		
		if ($get_value eq $expVal) {
			$result	=	"PASS";
			
		}else{
			$result	=	"FAIL";
			
		}
	} else {
		$get_value	=	"";
		$result		=	"FAIL";
		
	}
	
	################################################################################################
	# write result
	$f_result	=	$result_folder."\\".$caseName."_".&getDate().".csv";
	
	open (FILE, ">".$f_result);
		printf FILE ("%s, %s, %s\n", $get_value, $expVal, $result);
	close (FILE);
		
	return ($get_value, $result, $result_folder);


}

my ($rstVal, $testRst, $comment)=&case1_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6], $ARGV[7], $ARGV[8], $ARGV[9]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);