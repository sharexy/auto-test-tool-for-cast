#!/usr/bin/perl 

############################################
use warnings;
use strict;

############################################



sub trim 
{
	my ($m_str)=@_;
	
	$m_str=~ s/^\s+//g;
	$m_str=~ s/\s+$//g;
	
	return $m_str;
}

sub chkStr
{
	my ($m_str)=@_;
	my $m_flag=-1;
	
	$m_str = &trim($m_str);
	
	
	if ($m_str eq "") {
		printf ("This is a null value ...\n");
		
		$m_flag=0;
	}
	
	return $m_flag;
}

sub chkFile
{
	my ($m_file)=@_;
	my $m_flag=-1;
	
	if (
	(! -e $m_file) ||
	(0==&chkStr($m_file))
	
	){
		printf ($m_file." does not exist ...\n");
		
		$m_flag=0;
	}
	
	return $m_flag;
}

sub getPWD
{
	my ($m_pwd, );

	$m_pwd=readpipe ("echo %cd%");
	$m_pwd=&trim($m_pwd);
	
	return $m_pwd;
	
}

sub getDate
{
	my $m_date;
	my $SYMBOL_DATE_CONNECT='\/|\.|-';  # date format: yyyy/MM/DD, yyyy.MM.DD, yyyy-MM-DD
	my $SYMBOL_TIME_CONNECT=':|\.';	# time format: H: m: d
	
	# parse date
	foreach (split (/\s/, readpipe ("echo %date%"))){
		
		# printf ("%s\n", $_); exit (0); # debug 
		
		if ($_ =~ /$SYMBOL_DATE_CONNECT/){
			($m_date = $_) =~ s/$SYMBOL_DATE_CONNECT/_/g; last; 

		}
		
	}
	
	# printf ("%s\n", $m_date); exit (0); # debug
	
	# parse time
	foreach (split (/\./, readpipe ("echo %time%"))){
		
		# printf ("%s\n", $_); # debug 
		
		if ($_ =~ /$SYMBOL_TIME_CONNECT/){
			($m_date.='_'.$_) =~ s/$SYMBOL_TIME_CONNECT/_/g;
			$m_date =~ s/\s/0/g; 
			last;  
		}
		
	}
	
	# printf ("%s\n", $m_date); # debug	
	
	return $m_date;
}

sub getConf
{
	my ($f_conf)=@_;

	my (@m_info, $m_crt, $m_port);
	
	if (0==&chkFile($f_conf)){
		exit(0);
	}
	
	open (FILE, $f_conf);
		while (my $line=<FILE>){
		
			if(&trim($line) =~ /^#/){
				# skip
			}elsif(&trim($line) eq ""){
				# skip
			}else{
				push (@m_info, &trim($line));
				
			}
			
		}
		
	close (FILE);

	$m_crt=$m_info[0];
	$m_port=$m_info[1];
	
	return ($m_crt, $m_port);

}

sub getHashVal
{
	my ($m_file)=@_;
	
	my ($m_hashVal, $m_getVal);

	
	if (0==&chkFile($m_file)){
		exit(0);
	}
	
	open (FILE, $m_file);
		while(my $m_line=<FILE>){
			if ($m_line =~ /"ITEMS":.*{.*"HASHVAL":\s*(\d+),\s*/){
				$m_hashVal=$1;
				
				if ($m_line =~ /.*"VALUE":\s*("[^"]*"|[^",}]*)[,}]/){
					$m_getVal=$1;
				}
				
			}
			
		}
	close (FILE);
	
	return ($m_hashVal, $m_getVal);
}

sub runVBS
{
	my ($cmd, $m_file, $searchStr)=@_;
	
	my $flag=0;
	
	do {
		sleep(1);
	
		system ($cmd);
		
		sleep(1);
		
		if (0==&chkFile($m_file)){
			exit(0);
		}
		
		sleep(1);
		
		open (FILE, $m_file);
			while(my $line=<FILE>) {
				if (-1==index ($line, $searchStr)) {
					
				}else {
					$flag=1;
					last;
				}
			}
		close (FILE);
		# printf ("%d\n", $flag);
		
	}while (0==$flag);
	
}	

sub fileSearch
{
	my ($m_file, $searchStr)=@_;
	
	my $cnt=0;
	
	if (0==&chkFile($m_file)){
		exit(0);
	}
	
	sleep(1);
	
	open (FILE, $m_file);
		while(my $line=<FILE>) {
			if (-1==index ($line, $searchStr)) {
				
			}else {
				$cnt++;
			
			}
		}
	close (FILE);
	
	return $cnt;
}	

# my $COMLOG		=&getPWD()."\\com_".&getDate().".log";
# my $LOGGING		=&getPWD()."\\logging.vbs";

# sub genLOG
# {
	# my 
	# my $COMLOG	=&getPWD()."\\com_".&getDate().".log";
	# return $COMLOG;
# }

sub getLOG
{
	my $LOGGING	=&getPWD()."\\logging.vbs";
	return $LOGGING;
}
1;
