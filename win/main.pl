#!/usr/bin/perl -w 

use strict;
use Spreadsheet::ParseExcel;
use Spreadsheet::WriteExcel;


require "fun.pl";

my $run_folder =&getDate();
mkdir ($run_folder);

my $DEVICE_ID	="12345";
my $DEVICE_NAME	="12345";
my $PROTOCOL	="https";
my $PORT		="9000";
my $RESTLOG;	# "restlog";
my $CMDLOG;		# "cmdlog";
my $IP;
my $PIN;
my $TOKEN;
my $AUTH;
# my $COMLOG		=&genLOG();
my $COMLOG		=&getPWD()."\\".$run_folder."\\com_".&getDate().".log";
# my $LOGGING		=&getPWD()."\\logging.vbs";

# printf ("COMLOG=%s\n", $COMLOG);exit(0);
# &getLOG();exit(0);

sub pair
{
	
	my @line;
	
	# generate pin & token
	$CMDLOG=$run_folder."\\cmdlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request PUT ".
	"--header \"content-type: application/json\" ".
	"--data \"{\\\"DEVICE_ID\\\": \\\"".$DEVICE_ID."\\\", \\\"DEVICE_NAME\\\": \\\"".$DEVICE_NAME."\\\"}\" ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/pairing/start\" ".
	"--insecure ".
	"> ".
	$CMDLOG
	);
	
	# save restlog 2 times
	$RESTLOG=$run_folder."\\restlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request GET ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/restlog\" ".
	"--insecure ".
	"> ".
	$RESTLOG
	);
	
	$RESTLOG=$run_folder."\\restlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request GET ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/restlog\" ".
	"--insecure ".
	"> ".
	$RESTLOG
	);
	
	# get pin & token
	# 1.
	open(FILE, $RESTLOG);
		@line=<FILE>;
	close(FILE);
	
	foreach my $line (@line){
		if ($line=~/_typeMobileDevice::init\($DEVICE_ID, $DEVICE_NAME, ([^,]+), None, ([^\)]+)\)/){
			$PIN=$1;
			$TOKEN=$2;
			# printf ("0, line=$line\n");
		}elsif ($line=~/_typeMobileDevice::setPin\(([^\)]+)\)/){
			if ($1 ne "None"){
				$PIN=$1;
			}
			# printf ("1, line=$line\n");
		}elsif ($line=~/_typeMobileDevice::setPairingReqToken\(([^\)]+)\)/){
			if ($1 ne "None"){
				$TOKEN=$1;
			}
			# printf ("2, line=$line\n");
		}elsif ($line=~/PIN =([^\s]+)\s/){
				$PIN=$1;
			# printf ("3, line=$line\n");
		}
		
	}
	
	# 2.
	open(FILE, $CMDLOG);
		@line=<FILE>;
	close(FILE);
	
	foreach my $line (@line){
		if ($line=~/"PAIRING_REQ_TOKEN": ([^}]+)}/){
			$TOKEN=$1;
		}
		
	}
	
	# generate auth
	$CMDLOG=$run_folder."\\cmdlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request PUT ".
	"--header \"content-type: application/json\" ".
	"--data \"{\\\"DEVICE_ID\\\": \\\"".$DEVICE_ID."\\\", \\\"CHALLENGE_TYPE\\\": 1, \\\"RESPONSE_VALUE\\\": \\\"".$PIN."\\\", \\\"PAIRING_REQ_TOKEN\\\": ".$TOKEN."}\" ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/pairing/pair\" ".
	"--insecure ".
	"> ".
	$CMDLOG
	);
	
	# save restlog 
	$RESTLOG=$run_folder."\\restlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request GET ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/restlog\" ".
	"--insecure ".
	"> ".
	$RESTLOG
	);
	
	# get auth
	# 1. 
	open(FILE, $RESTLOG);
		@line=<FILE>;
	close(FILE);
	
	foreach my $line (@line){
		if ($line=~/_typeMobileDevice::setAuthToken\(([^\)]+)\)/){
			if ($1 ne "None"){
				$AUTH=$1;
			}
		}
		
	}
	
	# 2. 
	open(FILE, $CMDLOG);
		@line=<FILE>;
	close(FILE);
	
	foreach my $line (@line){
		if ($line=~/"AUTH_TOKEN": "([^"]+)"/){
			$AUTH=$1;
		}
		
	}
	# printf ("PIN=$PIN, TOKEN=$TOKEN, AUTH=$AUTH\n");exit(0);
	if (! defined($PIN) ||
		! defined($TOKEN) ||
		! defined($AUTH) 
	){
		die ("Cannot get PIN, TOKEN or AUTH\n");
		
	}else{
		printf ("PIN=$PIN, TOKEN=$TOKEN, AUTH=$AUTH\n");
	}
	
	
}

sub unpair
{
	$CMDLOG=$run_folder."\\cmdlog_".&getDate().".log";
	
	system (
	"curl ".
	"--request PUT ".
	"--header \"content-type: application/json\" ".
	"--data \"{\\\"DEVICE_ID\\\": \\\"".$DEVICE_ID."\\\", \\\"CHALLENGE_TYPE\\\": 1, \\\"RESPONSE_VALUE\\\": \\\"".$PIN."\\\", \\\"PAIRING_REQ_TOKEN\\\": ".$TOKEN." }\" ".
	"--url \"".$PROTOCOL."://".$IP.":".$PORT."/pairing/cancel\" ".
	"--insecure ".
	"> ".
	$CMDLOG
	);
}

sub runCase
{
	my ($cmd)=@_;
	
	my ($rstVal, $testRst, $comment );

	printf ("%s\n", $cmd);
	
	# system($cmd);
	my $rt=readpipe($cmd);
	my $last_result=rindex($rt, "Result Value=");
	
	$rt=substr($rt, $last_result);
	$rt=~/Result Value=(.*), testRst=(.*), comment=(.*)/;
	
	if (! defined ($1)){
		$rstVal="";
	}
	
	if (! defined ($2)){
		$testRst="";
	}
	
	if (! defined ($3)){
		$comment="";
	}
	
	($rstVal, $testRst, $comment)=($1, $2, $3);
	
	return ($rstVal, $testRst, $comment);
	
}


sub parseCase
{
	my ($sheet, $startIndex, $endIndex, $arr)=@_;
	
	
	my $file	=	$sheet.".pl";
	# my $result_folder = $run_folder."\\".$sheet."\\".$caseInfo[1];
	my $result_folder = $run_folder."\\".$sheet;
	my $record	=	"";
	my $cmd;
	
	
	# printf ("result_folder=$result_folder\n");
	
	# copy a record of array
	my @caseInfo	=	@$arr[$startIndex .. $endIndex];
	my $col_max		= 	$endIndex - $startIndex;
	my $expValIndex	=	$col_max-3;
	# printf ("expValIndex=$expValIndex\n");
	
	# produce the case folder
	if (! -d $run_folder."\\".$sheet){
		mkdir ($run_folder."\\".$sheet);
	}
	
	$result_folder = $result_folder."\\".$caseInfo[1];
	if (! -d $result_folder){
		if ($caseInfo[1] ne "NO"){
			mkdir ($result_folder);
		}
	}
	
		
	if ( $caseInfo[0] eq "Y" ){
		if($sheet eq "0_ImageBurn")
		{
			
			my ($type, $branchID, $buildNO, $url)=
			($caseInfo[$expValIndex-5], $caseInfo[$expValIndex-4], $caseInfo[$expValIndex-3], $caseInfo[$expValIndex-2]);
			
			if ($buildNO eq ""){
				$buildNO="\"\"";
			}
			
			if ($url eq ""){
				$url="\"\"";
			}
			
			$cmd="perl ".$file." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$COMLOG." ".$type." ".$branchID." ".$buildNO." ".$url;
			
		}
		elsif ($sheet eq "1_SourceSwitch")
		{
			
			my ($input, $url, $time, $expVal)=
			($caseInfo[$expValIndex-3], $caseInfo[$expValIndex-2], $caseInfo[$expValIndex-1], $caseInfo[$expValIndex]);
			
			if ($input eq ""){
				$input="\"\"";
			}
			
			if ($url eq ""){
				$url="\"\"";
			}
			
			$cmd="perl ".$file." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$input." ".$url." ".$time." ".$expVal;
		}
		elsif($sheet eq "2_RestAPI")
		{
			if ($caseInfo[$expValIndex] =~ /random/){
				my (@valueInfo)=split(",", $caseInfo[$expValIndex]);
					
				my ($minVal, $maxVal);

				if (
					defined ($valueInfo[1]) &&
					defined ($valueInfo[2]) 
				){
					($minVal, $maxVal)=(&trim($valueInfo[1]), &trim($valueInfo[2]));
					
				}else{
					($minVal, $maxVal)=(0, 100);
					
				}
					
				$caseInfo[$expValIndex] = $minVal+int( rand (abs($minVal)+$maxVal+1) );

			}
			
			my ($node, $expVal)=
			($caseInfo[$expValIndex-3], $caseInfo[$expValIndex]);
			
			$cmd="perl ".$file." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$node." ".$expVal;
		
		}
		elsif ($sheet eq "3_FormatSwitch")
		{
			
			my ($device, $sport, $input, $format_name, $expVal)=
			($caseInfo[$expValIndex-9], $caseInfo[$expValIndex-8], $caseInfo[$expValIndex-4], $caseInfo[$expValIndex-1], $caseInfo[$expValIndex]);
			
			
			$cmd="perl ".$file." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$device." ".$sport." ".$input." ".$format_name." ".$expVal;
		}
		elsif ($sheet eq "4_TabletTest")
		{
			
			my ($package, $method, $interval, $input)=
			($caseInfo[$expValIndex-6], $caseInfo[$expValIndex-5], $caseInfo[$expValIndex-4], $caseInfo[$expValIndex-3]);
			
			if ($input eq ""){
				$input="\"\"";
			
			}
			
			$cmd="perl ".$file." ".$PROTOCOL." ".$IP." ".$PORT." ".$AUTH." ".$result_folder." ".$package." ".$method." ".$interval." ".$input;
			
		}
		
	} else {
	
		if (
			($caseInfo[0] ne "Tag") 
		){
			$caseInfo[$expValIndex+2]="NT";
		}
		
		
	}
		
	
	if (defined ($cmd) ){
		(
		$caseInfo[$expValIndex+1], 
		$caseInfo[$expValIndex+2], 
		$caseInfo[$expValIndex+3]
		)=&runCase($cmd);
		
	}
	
	
	@$arr[$startIndex .. $endIndex]=@caseInfo;
	
	foreach my $i (0 .. $col_max){
	 	$record=$record.$caseInfo[$i].", ";
	}
	
	return ($record);
}

sub parseTemplate
{
	my ($file, $sheet)=@_;
	
	my (@page);

	my ($parser, $workbook, $worksheet);
	
	$parser = Spreadsheet::ParseExcel->new();
	$workbook = $parser->parse($file);
	
	if ( !defined $workbook ) {
		die $parser->error(), ".\n";
	}
	
	$worksheet = $workbook->worksheet($sheet);

	my ( $row_min, $row_max ) = $worksheet->row_range();
	my ( $col_min, $col_max ) = $worksheet->col_range();
	
	for my $row ( $row_min .. $row_max ) {
		for my $col ( $col_min .. $col_max ) {
		
		   my $cell = $worksheet->get_cell( $row, $col );
		   next unless $cell;
		   
			push (@page, $cell->value());
			
		}		
		
	}
	
	return ($row_max, $col_max, @page, );
}


sub genRst
{
	my ($worksheet, 
	($border_red, $border_green, $border_black, $border_blue), 
	$row_max, $col_max, @page)=@_;
	
	my ($row_min, $col_min, $index) = (0, 0, 0);
	
	for my $row ( $row_min .. $row_max ) {
		
		for my $col ($col_min .. $col_max){
			$index=$row * ($col_max + 1) + $col;
			
			if ($page[$index] eq "PASS") {		
						
				$worksheet->write($row, $col, $page[$index], $border_green);
				
			}elsif($page[$index] eq "FAIL" ){
				
				$worksheet->write($row, $col, $page[$index], $border_red);
				
			}elsif($page[$index] eq "NT" ){
				
				$worksheet->write($row, $col, $page[$index], $border_blue);
				
			}else {
				$worksheet->write($row, $col, $page[$index], $border_black);
			}
			
		}
					
		
	}
	
	
	
}

sub main
{
	my $file;
	my $report="report";
	
	if (@ARGV < 2){
		die ("LESS ARG GET!\n");
		
	}else{
		$file	=$ARGV[0];
		$IP		=$ARGV[1];
	}

	my ($mainSheet)=("LoopInfo");
	my ($workbook, $worksheet);
	
	my (%border, %red, %green, %black, %blue);
	my ($border_red, $border_green, $border_black, $border_blue);
		
	my ($rstBak, $record);
	my ($row_max, $col_max, @page);
	
	my ($f_conf, $crt, $path, $program, $com);
	
	# prepared all the scripts
	my @fileList=("conf.txt", "fun.pl", "input.pl", "download_image_script.vbs", "logging.vbs", "format_switch.vbs");
	push (@fileList, "TestCast\\bin\\TestCast.jar", "TestCast\\run.pl");
	push (@fileList, "TestSmartCast\\bin\\TestSmartCast.jar", "TestSmartCast\\run.pl");
	
	$f_conf="conf.txt";
	($crt, $com)=&getConf($f_conf);
	
	$crt=~/^"([^"]+)\\([^"]+)"$/;
	$path="\"".$1."\"";
	$program=$2;
	# printf ("crt=$crt, path=$path, program=$program");exit(0);
	
	$workbook= Spreadsheet::WriteExcel->new($run_folder."\\".$report."_".&getDate().".xls");
	# exit(0);
	%border	= (bottom=>1, top=>1, left=>1, right=>1);
	%red  	= (color=>'red');
	%green	= (color=>'green');
	%black	= (color=>'black');
	%blue	= (color=>'blue');
	
	$border_red		= $workbook->add_format(%border, %red);
	$border_green 	= $workbook->add_format(%border, %green);
	$border_black 	= $workbook->add_format(%border, %black);
	$border_blue 	= $workbook->add_format(%border, %blue);
	
	$worksheet = $workbook->add_worksheet($mainSheet);
	
	($row_max, $col_max, @page) = &parseTemplate($file, $mainSheet);
	
	&genRst($worksheet, 
	($border_red, $border_green, $border_black, $border_blue), 
	$row_max, $col_max, @page);
	
	my %gWorkSheet=@page;
	
	# pop up the title
	delete ($gWorkSheet{"CaseName"});
	
	# check files ready
	foreach my $key (sort keys(%gWorkSheet)) {
		my ($sheet, $loopTimes) =($key, $gWorkSheet{$key});
		
		if ( 0==&chkFile($sheet.".pl") ){
			exit(0);
		}
	}
	
	foreach my $script (@fileList) {
		if ( 0==&chkFile($script) ){
			exit(0);
		}
	}
	
	# exit(0);
	
	# close all process of SecureCRT
	system ("taskkill /IM SecureCRT.exe /T /F");

	sleep(1);
	
	# open com to logging
	system ("start /D ".$path." /NORMAL ".$program." /LOG ".$COMLOG." /SCRIPT ".&getLOG()." /SERIAL ".$com." /BAUD 115200 /DATA 8 /CTS ");
	
	# exit (0);
	&pair();

	# read sheet
	foreach my $key (sort keys(%gWorkSheet)) {
		my ($sheet, $loopTimes) =($key, $gWorkSheet{$key});
		my $loop="continue"; 
	
		printf ("sheet=%s\tloop times=%d\n", $sheet, $loopTimes);
		
		$rstBak=$run_folder."\\".$sheet."\\".$file."_".$sheet."_".&getDate().".csv";
		# printf ("rstBak=$rstBak\n");exit(0);
		$worksheet = $workbook->add_worksheet($sheet);
		
		($row_max, $col_max, @page) = &parseTemplate($file, $sheet);
		
		while (
			($loopTimes--) && 
			($loop eq "continue")
		){
			# open(RST, ">".$rstBak);
			
			for(my $i=0; $i<=$row_max; $i++){
				my ($startIndex, $endIndex)=($i*(1+$col_max), $i*(1+$col_max)+$col_max);
				
				$record=&parseCase($sheet, $startIndex, $endIndex, \@page);
				
				open(RST, ">>".$rstBak);
				printf RST ("%s\n", $record);
				close(RST);
				
				if ($record =~ /FAIL/){
					$loop="break";
					
				}
				
			}
			
		}
		
		&genRst($worksheet, ($border_red, $border_green, $border_black, $border_blue), $row_max, $col_max, @page);
		
		if (defined ($record) &&
			($record =~ /FAIL/) &&
			($sheet eq "0_ImageBurn")
		){
			last;
		}
		
	}

	$workbook->close();
	&unpair();
	
	system ("taskkill /IM SecureCRT.exe /T /F");
}

# the entrance
&main();
