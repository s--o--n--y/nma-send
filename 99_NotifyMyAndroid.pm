##############################################
# $Id: 99_NotifyMyAndroid.pm ? 2013-12-02 12:50:38Z gemx $
# Written by Florian Ruhnke, Andreas Kwasnik, 2012-2013
#

package main;
use strict;
use LWP::UserAgent;
use warnings;
use POSIX;

sub
NotifyMyAndroid_Initialize($$) {
	my ($hash) = @_;

	$hash->{DefFn}     = "NMA_Define";
	$hash->{UndefFn}   = "NMA_Undefine";
	$hash->{SetFn}	   = "NMA_send";
	$hash->{AttrList}  = "useSSL:0,1 applicationName isFB:0,1 useHTTPUtils:0,1";
	return;
}

sub NMA_Define($$) {
	my ($hash, $def) = @_;
	my $name=$hash->{NAME};
	my @a = split("[ \t][ \t]*", $def);
  
	my $apikey = $a[2];

	return "wrong syntax: define <name> NotifyMyAndroid <apikey> [<isFB>]" if(@a<3);  

	$hash->{apikey} = $apikey;
	$hash->{STATE} = "Initialized";

	$attr{$name}{isFB}=$a[3] if ((@a==4) && ($a[3]==1));
	$attr{$name}{useSSL}=1;		
	$attr{$name}{useHTTPUtils}=1;	
	$attr{$name}{applicationName}="FHEM";
  return;
}

sub NMA_Undefine($$) {
    my ( $hash, $arg ) = @_;
    return undef;
}

sub NMA_send($@){
	my ($hash, @a) = @_;

	return "No argument given to dummyDebug_Set" if ( !defined( $a[1] ) );	
	my $arg     = lc($a[1]); 

	if ( $arg eq "send" ) {	
		my $subject =  $a[2];
		my $message =  $a[3];
		my $priority = 0;	
		$priority = $a[4] if(@a==5); 
		if (($priority<-2) || ($priority>2)) {
			return "ERROR: priority must be a valid int value between -2 and 2";
		}
		
		my $apikey = $hash->{apikey};
		my $name = $hash->{NAME};	
		my $useSSL = $attr{$name}{useSSL};
		my $useFB  = $attr{$name}{useFB};
		my $appname = $attr{$name}{applicationName};
		
		my $protocol;
		if (($useSSL == 1) && ($useFB==0)) { 
			$protocol = "https:";
		} else { 
			$protocol = "http:";
		}
		my $url = $protocol."//www.notifymyandroid.com/publicapi/notify";
		my $put = "?apikey=".$apikey."&application=".$attr{$name}{applicationName}."&event=".$subject."&description=".$message."&priority=".$priority;
		my $success=1;
		if ($attr{$name}{useHTTPUtils}==1) {
			fhem(CustomGetFileFromURL(0,$url,4,$put,$useFB));
		} else {
			my ($userAgent, $request, $response, $requestURL);
			$userAgent = LWP::UserAgent->new;
			$userAgent->agent("NMAScript/1.0");
			$userAgent->env_proxy();                
			$requestURL = $url.$put;
			$request = HTTP::Request->new(GET => $requestURL);
			$response = $userAgent->request($request);
			if (!$response->is_success) {
				Log 3, ("ERROR: Notification not posted: " . $response->content . "\n");
				success=0;	
			}               		
		}
			
		if ($success==1) {
			Log 3, ("[".$name."] Die Benachrichtigung wurde versendet: ".$subject."; ".$message);
			$hash->{STATE} = "notification sent";
			$hash->{READINGS}{state}{TIME} = TimeNow();
			$hash->{READINGS}{state}{VAL} = "notification sent";		
		} else {
			Log 3, ("FEHLER: [".$name."] Die Benachrichtigung konnte nicht versendet werden: ".$subject."; ".$message);
			$hash->{STATE} = "ERROR";
			$hash->{READINGS}{state}{TIME} = TimeNow();
			$hash->{READINGS}{state}{VAL} = "ERROR";				
		}
		return;
	} else {
		return "Unknown command '". $a[1]. "', choose one of send"; # This looks quite strange but it seems as if fhem expects certain words to parse out the commands
	}
}

1;

=pod
=begin html

<a name="NotifyMyAndroid"></a>
<h3>NotifyMyAndroid</h3>
<ul>
  This module is an fhem device to send notifications to an android phone.
  You need to obtain an apikey first at <a href="http://www.notifymyandroid.com">http://www.notifymyandroid.com</a>
  <br><br>

  <a name="NMA_Define"></a>
  <b>Define</b>
  <ul>
    <code>define &lt;name&gt; NotifyMyAndroid &lt;apikey&gt; [&lt;isFB&gt;]</code>
      <br><br>

      Defines a NMA device with 1 apikey. If you want to sent a notification to multiple devices/apikeys<br>
	  you have to define more devices and eventually group them via the structure command.<br>.
	  <br>
	  <code>isFB</code> is optional and defines if FHEM is running in a Fritz!Box or not.<br>
	  The default is "0"=no.
  </ul>
  <br>

  <a name="NMA_send"></a>
  <b>Set &lt;event&gt; &lt;message&gt; [&lt;priority&gt;]</b>
  <ul>
      <li>send <br>
	  Actually sends the notification.<br>
	  &lt;event&gt; is the event or title of the notification<br>
	  &lt;message&gt; is the body of the notification<br>
	  &lt;priority&gt; can be between -2 (very low) and 2 (emergency). If not specified a default priority of 0 (normal) will be set</li>
  </ul>
  <br>
  <a name="NMAattr"></a>
  <b>Attributes</b>
  <ul>
    <li></li><br>
    <li><a href="#applicationName">applicationName</a> The application name to be displayed in the NotifyMyAndroid app</li><br>
    <li><a href="#isFB">isFB</a> Set to 1 if using a Fritz!Box</li><br>
    <li><a href="#useSSL">useSSL</a> Set to 1 if the request should use SSL</li><br>
	<li><a href="#useHTTPUtils">useHTTPUtils</a> 1 is the default. If set to 0, an alternative method (HTTP::Request) is used instead of a socket connection. Use this if the default method doesn't work.<br>It seems that this is the case if running under windows.</li><br>
  </ul>
  <br>
</ul>
=end html

=cut
