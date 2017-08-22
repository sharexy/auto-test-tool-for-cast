use strict;

require "fun.pl";


sub case3_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder, $device, $sport, $input, $format_name, $expVal)=@_;
	
	################################################################################################
	# variable initialize
	my ($rt			);
	my ($node		);
	my ($get_value	);
	my ($result		);
	my ($caseName	);
	my ($source		);
	
	# prepared scripts
	my ($f_restAPI	); 
	my ($f_input	); 
	my ($f_format_switch);
	
	# produced files
	my ($f_log		); 
	my ($f_result	);
	
	my $f_conf		=	"conf.txt";
	my ($crt, $com)	=	&getConf($f_conf);
	
	$caseName	=	$0;
	$caseName	=~	/([^\.]+)\.pl/;
	$caseName	=	$1;
	
	$f_restAPI	=	"2_RestAPI.pl";
	$f_input	=	"input.pl";
	$f_format_switch	=	"format_switch.vbs";
	
	################################################################################################
	# change input to $input
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

	################################################################################################
	# run case
	$f_log	=	$result_folder."\\".$caseName."_".&getDate().".log";
	
	if ($input	=~	/HDMI/){
		$source	=	"HDMI";
	}else {
		$source	=	$input;
	}
	
	do {
		system (
			$crt." \/SCRIPT ".$f_format_switch." \/ARG ".$f_log." \/ARG ".$source." \/ARG ".$sport." \/ARG ".$device." \/ARG ".$format_name
		);
		
		sleep (10);
		
	}while(2	!=	&fileSearch($f_log, $format_name));
	
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
		
	}else {
		$get_value	=	"";
		$result		=	"FAIL";
		
	}
	
	################################################################################################
	# write to result file
	$f_result=$result_folder."\\".$caseName."_".&getDate().".csv";
	
	open (FILE, ">".$f_result);
		printf FILE ("%s, %s, %s\n", $get_value, $expVal, $result);
	close (FILE);
		
	return ($get_value, $result, $result_folder);


}

my ($rstVal, $testRst, $comment)=&case3_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6], $ARGV[7], $ARGV[8], $ARGV[9]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);