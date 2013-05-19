#!/usr/bin/perl
###########################################
#
# Simple Time Zone Converter (c) Arjun Roychowdhury, arjunrc@gmail.com
#
# This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#################################################

use POSIX;
use POSIX qw(tzset);
use Date::Parse;



# Lets check if you have the right packages
eval
{
require LWP::UserAgent;
};

if ($@)
{

print "<?xml version='1.0'?><items><item uid='tz-calc-oops' valid='NO'><title>Oops!</title><subtitle>you need to install LWP::UserAgent in Perl for this to work</subtitle><icon>oops.png</icon></item></items>";
exit;
}

eval
{
require Date::Parse;
};

if ($@)
{
print "<?xml version='1.0'?><items><item uid='tz-calc-oops' valid='NO'><title>Oops!</title><subtitle>you need to install Date::Parse in Perl for this to work</subtitle><icon>oops.png</icon></item></items>";
exit;
}


Date::Parse->import();
LWP::UserAgent->import();




my %cities; # will be populated with convenience names from file
my %tzmaps; # will contain full timezone and shortname hash
my %revtzmaps; 

#-------------------------------------------------------------------------------#
# Simple Date/Time and Timezone converer
#
# I needed a flexible no-nonsense Date/Time TZ converter that 
# allowed me to enter free form text. Did not find any simple 
# enough to use, so wrote this.
#
#							- Arjun Roychowdhury
# ------------------------------------------------------------------------------#
#

#---------------------------------------------------------
# Capitalize a string
#---------------------------------------------------------

sub capitalize {
   local $_ = shift;
   s/\b(.*?)\b/$1 eq uc $1 ? $1 : "\u\L$1"/ge;
   return $_;
}


#---------------------------------------------------------
# Debug printing
#---------------------------------------------------------
sub print_dbg {
    print "DBG::", @_, "\n"  if ($x_dbg);
}

#---------------------------------------------------------
# remove leading and trailing ws
#---------------------------------------------------------
sub trim($)
{
	my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

#---------------------------------------------------------
# Given a convenience name, converts to 
# proper TZ value
#---------------------------------------------------------
sub convenience_convert($)
{
	my $sstring = shift;
	return $sstring if (!$sstring);
	$sstring=lc($sstring);
	my $conv = "";
	$conv = $cities{$sstring};
		
	$conv = $sstring if (!$conv);
print_dbg ("Converted ".$sstring. " to ".$conv) if ($sstring ne $conv);
	return $conv;
}

#--------------------------------------------------------
# Geocode API to convert city name to TZ
# really really bad/dirty parsing, but serves my needs
# don't want to use any additional XML parse modules
# as target audience may not have these modules
# -------------------------------------------------------

sub getTz($){
  my $browser = LWP::UserAgent->new;
 $browser->ssl_opts(verify_hostname=>0);
  my ($address) = @_;
  my $format = "xml";
  my $geocodeapi = "https://maps.googleapis.com/maps/api/geocode/";
  my $url = $geocodeapi . $format . "?sensor=false&address=" . $address;
  my $response=$browser->get($url);
  die "Error ",$response->status_line unless $response->is_success;
  $out = $response->content;

  $retval="";
  $cnt=0;
  while  ( ($out =~ m/\<formatted_address\>/) && ($cnt<=1) )
  {
	$out =~ m!\<formatted_address\>(.*?)\</formatted_address\>!;
	$location=$1;
	$out=substr($out,$+[0]);
	$out =~ m!\<lat\>(.*?)\</lat\>!;
	$lat=$1;
	$out =~ m!\<lng\>(.*?)\</lng\>!;
	$lng=$1;
	$tzurl="https://maps.googleapis.com/maps/api/timezone/xml?location=$lat,$lng&timestamp=1331161200&sensor=false";
	my $response=$browser->get($tzurl);
  	die "Error ",$response->status_line unless $response->is_success;
	$tzout = $response->content;
	$tzout =~ m!\<time_zone_id\>(.*?)\</time_zone_id\>!;
	$tz=$1;
	$retval = $tz;
	$cnt++;
  }
  return ($retval,$location);
}

#---------------------------------------------------------
# Main routine
#---------------------------------------------------------

sub main_entry($)
{
	$return_string="";
	my $s_time = $freetext;
	print_dbg("I got $freetext");

	$x_dbg = 0;
	($a,$b) = split (/ to /i,$s_time); # if user typed ' to ' that means the time box has both source and destination inputs
    	$a=trim($a);
    	$b=trim($b);

	print_dbg ("From:$a To:$b");

	    # read convenience mappings before each query
	open (FH,"<mycities.txt") || die "Cannot find convenience mappings";
	while (<FH>)
	{
		 s/#.*//;  # remove comments
		 next if /^(\s)*$/;
		chomp;
		($key,$value)=split(':',$_);
		$key = trim ($key);
		$value = trim ($value);
		$cities{$key}=$value;
	}	
	print_dbg("A total of ".keys(%cities)." convenience mappings have been detected in mycities.inc");

		
	# now see if user has specified multiple  timezones
    	@destinations=split(',',$b);
	$original_a = $a;
	$cur_tz= strftime("%Z", localtime());

	foreach $b (@destinations)
	{
		$ENV{TZ}=$cur_tz;
		print_dbg ("~~~~~~~~~~~~~~~ TZ SET TO $cur_tz ~~~~~~~~~~~~~~");
		print_dbg("********************************** FOR $b ***********************");
		$goog=0;
		$oopsie=0;
		$a = $original_a; # since we strip tz from $a, we need the original back for a comma separated list
		$b=trim($b);
		my @atz=("","");
            	# resolve EST ambiguity - bias towards US/EST here - since EST is also used for other timezones in the world
	     	if (lc($atz[0]) eq "est")    {$atz[0]="EST5EDT";print_dbg("Source:Converted EST to EST5EDT (I assumed you meant EST of USA)");}
		if (lc($atz[1]) eq "est") {$atz[1]="EST5EDT";print_dbg("Dest:Converted EST to EST5EDT (I assumed you meant EST of USA)");}
		   
		$atz[0] = convenience_convert ($atz[0]);
		$atz[1]= convenience_convert ($atz[1]);
		$original_b = $b;
		$b = convenience_convert ($b); # convert any convenience code to FQTZ

	   	if ($b)
	   	{
			print_dbg("Found all values in Time box..");
			$atz[1]=$b;
		} #if b

		print_dbg ("ATZ0=".$atz[0]." ATZ1=".$atz[1]);
				
		# now we need to check if $a also has TZ
		# logic is we check for last word. If it ends with 't' and does not
		# begin with 'a', it is a timezone, since otherwise it may be august
		# Alternately, if it had a '/' then it is also a timezone

		$olda=$a;
		$a =~s/(\S+)$//; #get last word in $1, remove last word from time
		$etz=$1;

		$oetz=$etz;
		$etz = convenience_convert($etz);
		if (($etz eq $oetz) && !($etz =~ m:/:))
		{
			($etz,$discard)=getTz($etz);
			($etz=$oetz) if (!$etz);
		}
		print_dbg("ETZ:$etz");

		# now that we have extracted the last word, let us see if it is really a timezone
		if ( ((lc(substr($etz,-1,1)) eq "t") && (lc(substr($etz,0,1)) ne "a")) || ($etz =~ m:/:))
		{
			$s_time = $a;
			$atz[0] = $etz;
		}
		else # last word was not a timezone
		{
			#well maybe google can tell me if its a TZ
			$s_time=$olda; # so, put it back to where it belongs
		}

	   	# if no timezone, assume one. If I figure out how to pick local timezone, will replace this
	   	if (!$atz[0]) 
		{
			$atz[0]="America/New_York"; 
			print_dbg("You did not specify a source timezone, so I am defaulting to America/New_York");
		}
	   	if (!$atz[1]) 
		{
			$atz[1]="America/New_York"; 
			print_dbg("You did not specify a destination timezone, so I am defaulting to America/New_York");
		}

		if ((!($atz[0]=~m:/:)) || (!($atz[1]=~m:/:)))
		{
			print_dbg("You are using shortcodes in timezones. Remember that the same shortcode can represent different time zones");
			print_dbg("So I am going to try a best match. If it is not what you want, I suggest you use the full Timezone name from the dropdown-list");
		}

	        # flexible parser for freeform date/time entries
	 	print_dbg("STRPSTIME $s_time");
		($xss,$xmin,$xhr,$xday,$xmonth,$xyear,) = strptime($s_time);

	       
	   	#foreach $elem (@atz)
		$elem=$atz[1];
	  	
		  if   ($tzmaps{uc($elem)})
		  {
		   	print_dbg("Found ". uc($elem).", replacing with".$tzmaps{uc($elem)}
			."  (which supposedly also uses a timezone shortcode of ".uc($elem).")");
			$elem = $tzmaps{uc($elem)};
		  }
		 elsif (!$revtzmaps{uc($elem)}) 
	      				{
						
							if (length($elem)>=2)
							{
							# print "Oops. I don't recognize '$elem'\n";					
							$oldelem=$elem;
							$goog=1;
							($elem,$original_b)=getTz($elem);
							$b=$elem;
							$oopsie=1 if (!$b);
							print_dbg("*****************Google:B is $b, ORIGB:$original_b\n");
							}
						
					}
		   	
		   if (!$oopsie)
		   {
		   my $s_tz = $atz[0];
		   print_dbg ("WHOA B IS $b");
		   my $d_tz = $b;
		   #my $d_tz = $atz[1];
			
		 
		   $s_tz=capitalize($s_tz);
		   $d_tz=capitalize($d_tz);

		   # the above does not capitalize the character after _ so let us do it manually
		   # otherwise set_time_zone barfs - it needs exact capitalization

		   $s_tz =~ s/_(.)/"_".uc($1)/eg;
		   $d_tz =~ s/_(.)/"_".uc($1)/eg;
		   print_dbg("Final values: STZ=$s_tz and DTZ=$d_tz");


		  $ENV{TZ} = $s_tz;
		  # get localtime
		  ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =localtime(time);	

		  print_dbg("XHR:$xhr, XMIN:$xmin, XDAY:$xday, XMONTH:$xmonth, XYER:$xyear");
		  if (defined $xhr) {$hour=$xhr; $min=0; $sec=0; }
		  if (defined $xmin) {$min=$xmin; $sec=0; }
		  if (defined $xss) {$sec=$xss;}
		  $mday=$xday if (defined $xday);
		  $mon=$xmonth if (defined $xmonth);
		  $year=$xyear if (defined $xyear);

		  print_dbg ("*** Going with Month:$mon, Day:$mday, Year:$year, $hour:$min:$sec");

		  $stime_t = POSIX::mktime( $sec, $min, $hour, $mday,$mon,$year);
		  ( $sec, $min, $hour, $mday,$mon,$year,$wday,$yday,$isdst) = localtime($stime_t);
		  $stime_str = POSIX::strftime ("%a,%b %d %Y: %I:%M%p %Z",$sec, $min, $hour, $mday,$mon,$year,$wday,$yday,$isdst);
		  print_dbg("Resulting source time: $stime_str");

			

		  $ENV{TZ} = $d_tz;
		  ( $sec, $min, $hour, $mday,$mon,$year,$wday,$yday,$isdst) = localtime($stime_t);
                  $dtime_str = POSIX::strftime ("%a,%b %d %Y: %I:%M%p %Z",$sec, $min, $hour, $mday,$mon,$year);
		  print_dbg("Resulting destination time: $dtime_str");
		  

		   $tmp=$stime_str. " is ".$dtime_str;
		   $rt= $dtime_str;
		   @td= localtime(time);
		   $uid=join(' ',@td);
		   $icn='icon.png';
		   $icn='gicon.png' if ($goog);
		   $return_string = $return_string."<item uid='$uid' arg='$tmp' valid='YES'><title>$rt in $original_b ($b)</title><subtitle>$tmp</subtitle><icon>$icn</icon></item>";
	     } # oopsie
	  } # end foreach dest
	return($return_string);

}

#-------------------------
# MAIN
#-------------------------

#grab all well formatted timezones
@tzs="";
unshift(@tzs,""); # add a blank entry on top - just for form display

#populate tz/shortname hash for faster search
open (FH,"<alltz.txt");
while (<FH>)
{
	next if /^(\s)*$/;
	chomp;
	($ndx,$sname) = split('==>',$_);
	$tzmaps{$sname}=$ndx;
	$revtzmaps{uc($ndx)}=uc($sname);
}
close(FH);

#$freetext="{query}";
$freetext=$ARGV[0];
($a,$b) = split (/ to /i,$freetext);
if ($b)
{

$retval="";
$retval = main_entry($freetext);
#if (!$retval) {$retval="<item uid='timecalc' arg='oops' valid='YES'><title>Uh-Oh</title><subtitle>Bad entry</subtitle></item>";}
print "<?xml version='1.0'?><items>$retval</items>";
}



