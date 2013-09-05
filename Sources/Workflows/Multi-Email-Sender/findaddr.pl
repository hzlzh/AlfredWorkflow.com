sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}

# MAIN #

$freetext=$ARGV[0];
$freetext=join(" ",@ARGV);
$listofemails="";
$found=0;
($tolist,$cclist)=split('/',$freetext);
$tolist=trim($tolist);
$cclist=trim($cclist);

if (!$cclist)
{
	($tolist,$cclist)=split('\?cc=',$freetext);
	$tolist=trim($tolist);
	$cclist=trim($cclist);
}

#print ("TO:$tolist*********CC:$cclist\n");

@destinations=split(',',$tolist);
if ($cclist)
{
	push(@destinations,"!CC-LIST!");
	@ccdest=split(',',$cclist);
	push(@destinations,@ccdest);

}
print "<?xml version='1.0'?><items>";
$iscc="";
foreach $b (@destinations)
{
	$b=trim($b);
#	print ("***********************$b\n");

	if ($b =~ /\@/)
	{
		$listofemails = $listofemails."$b,";
		next;
	}
	if ($b eq "!CC-LIST!")
	{
		$listofemails=$listofemails."?cc=";
		$iscc="(cc:) ";
		next;
	}

	if (length($b) <4)
	{
		$tmp_uid=localtime;
		print "<item uid='$tmp_uid' valid='no'><title>Please keep typing...</title><subtitle>I'll wait for at least 4 characters to be typed before I search your Contacts</subtitle><icon>wait.png</icon></item>";
		next;
	}

	system ("sh", "search.sh",$b);
	open (FH, "<temp.names") || die "No names";
	$first=1;
	while (<FH>)
	{
    		next if /^(\s)*$/;
    		chomp;
		if ($first)
		{
			$first=0;
			$tmp=localtime;
			print "<item uid='$tmp' valid='no'><title></title><subtitle>These are the names I've found. To select a name and continue with other names, hit TAB after selecting it</subtitle><icon></icon></item>";
		}
    		($email,$name)=split('!:!',$_);
		$newid="&quot;$name &quot;&lt;$email&gt;";
		print "<item uid='$name' valid='yes' arg='$listofemails$email' autocomplete='$listofemails$email'>";
		print "<title>$iscc$name</title>";
		print "<subtitle>$email</subtitle>";
		print "<icon>email.png</icon>";
		print "</item>";
	} # while
} # foreach
$status=$listofemails.$email;
$txt_status="yes";
if ($status eq "") {$txt_status="no";}
$tmp_id=localtime;
print "<item uid='$tmp_id' valid='$txt_status' arg='$listofemails$email'><title>send</title><icon>send.png</icon></item>";
print "</items>";
print $listofemail.$email;

