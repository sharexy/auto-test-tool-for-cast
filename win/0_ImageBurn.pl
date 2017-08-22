use strict;

require "fun.pl";

sub writeComment
{
	my ($m_file, $m_comment)=@_;
	open (FILE, ">".$m_file);
		printf FILE ("%s\n", $m_comment);
	close (FILE);
}

sub case0_main
{
	my ($PROTOCOL, $IP, $PORT, $AUTH, $result_folder, $COMLOG, $type, $branch_id, $build_no, $url)=@_;

	# printf ("PROTOCOL=$PROTOCOL\n");
	# printf ("IP=$IP\n");
	# printf ("PORT=$PORT\n");
	# printf ("AUTH=$AUTH\n");
	# printf ("result_folder=$result_folder\n");
	# printf ("type=$type\n");
	# printf ("branch_id=$branch_id\n");
	# printf ("build_no=$build_no\n");
	# printf ("url=$url\n");exit(0);
	
	my ($rt);
	
	# my ($f_result, $f_download_log, $f_build_log);
	my ($f_result, $f_download_log, );
	my ($f_download_script);
	my ($f_conf);

	my ($crt, $path, $program, $com);
	
	my ($result, $get_comment);
	my ($caseName);
	my ($times);
	
	$caseName=$0;
	$caseName=~/([^\.]+)\.pl/;
	$caseName=$1;
	
	$f_conf				="conf.txt";
	$f_download_script	="download_image_script.vbs";
	
	$f_result		=$result_folder."\\".$caseName."_".&getDate().".csv";
	$f_download_log	=$result_folder."\\download_".&getDate().".log";
	# $f_build_log	=$result_folder."\\build_".&getDate().".log";
	
	($crt, $com)=&getConf($f_conf);
	$crt=~/^"([^"]+)\\([^"]+)"$/;
	$path="\"".$1."\"";
	$program=$2;
	
	$get_comment 		= "";
	
	
	# get the latest build number
	if ($build_no eq ""){
	
		if ($url ne ""){
		
			$rt=readpipe(
			"curl ".
			"--request GET ".
			"--url \"".$url."\" "
			# "> ".
			# $f_build_log
			);
			# printf ("rt=$rt\n");
			if ($rt=~/<td class="pane build-name"><a[^>]*><img[^>]*class="icon-blue[^>]*><\/a>\s* *\s*#(\d+)/s){
				$build_no=$1;
				
			}
			
		}
	
	}
	# printf ("build_no=$build_no\n");exit(0);
	
	if ($build_no eq ""){
		$get_comment.="Cannot get Build NO.! ";
		&writeComment($f_result, $get_comment);
	
		$result="FAIL";
			
	}else{
		$times=5;
		
		do {
			$times--;
		
			# close all process of SecureCRT
			system ("taskkill /IM SecureCRT.exe /T /F");
			sleep(1);
			system ("del ".$COMLOG);
			
			&runVBS (
			$crt.
			" \/SCRIPT ".$f_download_script.
			" \/ARG ".$f_download_log." \/ARG ".$build_no." \/ARG ".$IP." \/ARG ".$type." \/ARG ".$branch_id."", 
			$f_download_log,
			" bootmode "
			);
			
			
			system ("start /D ".$path." /NORMAL ".$program." /LOG ".$COMLOG." /SCRIPT ".&getLOG()." /SERIAL ".$com." /BAUD 115200 /DATA 8 /CTS ");
			
			sleep (180);
			
			open (FILE, $COMLOG);
				while(my $line=<FILE>) {
					if (-1==index ($line, "[ro.build.version.incremental]: [".$build_no."]")) {
						
					}else {
						$times=-1;
						last;
						
					}
					
				}
			close (FILE);
			# printf ("times=$times\n");
		}while (($times!=0) && ($times!=-1));
		
		if ($times == -1){
			$get_comment.="burn image done! ";
			&writeComment($f_result, $get_comment);
			
			$result="PASS";
		}else {
			$get_comment.="burn image failed! ";
			&writeComment($f_result, $get_comment);
			
			$result="FAIL";
		}
		
			
	}


	# write to result file

	&writeComment($f_result, $get_comment.", ".$result);
	
	return ($get_comment, $result, $result_folder.", BuildNo=".$build_no);
}


my ($rstVal, $testRst, $comment)=&case0_main($ARGV[0], $ARGV[1], $ARGV[2], $ARGV[3], $ARGV[4], $ARGV[5], $ARGV[6], $ARGV[7], $ARGV[8], $ARGV[9]);

printf ("Result Value=%s, testRst=%s, comment=%s\n", $rstVal, $testRst, $comment);