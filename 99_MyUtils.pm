sub 
NMA_send($$@){
#                                                                    2013V0.6     #

###################################################################################
# Funktion, um NotifyMyAndroid leichter zu senden                                 #
#                                                                                 #
#Aufruf: {NMA_send("Betreff","Nachricht"[,Priorität,"User","Absender","Logging"])}#
###################################################################################

###################### Variablen aus Funktionsaufruf bilden #######################
my ($subject, $message, $priority, $user, $application, $Log) = @_;

$application = "FHEM" if(!$application); # Ohne Absender wird "FHEM" gesendet.

################################# EINSTELLUNGEN ###################################
# User und dazugehörige NotifyMyAndroid-ID erfassen, soll die Funktion geloggt    #
# werden und läuft das Script auf einer FritzBox?                                 #
###################################################################################

my $FB = 1;         # 0=keine FRITZ!Box, 1=fhem läuft auf FRITZ!Box
$Log = 0 if(!$Log); # 0=kein Eintrag im Logfile, 1=Eintrag im Logfile (kann über Funktionsaufruf separat getriggert werden)

my @usr_List = 
( "User:1234567890abcdef1234567890abcdef1234567890abcdef"
);
# Listenformat: 
#( "Name1:API-Key1",
#  "Name2:API-Key2"
#);
# nach dem letzten Listeneintrag KEIN Komma! Sonst immer!

$user = split(/:/, @usr_List) if(!$user); # setzt den ersten User der Liste, wenn kein User übergeben wurde.

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!! ES GEHEN NUR API-KEYS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
# Wenn kein API-Key vorhanden, auf http://www.notifymyandroid.com einloggen       #
# und im Menü "My Account" unter "Manage my API keys" einen                       #
# "My Account" unter "Manage my API keys" einen API-Key erstellen.                #
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

## Prioritäten: ##
# -2 = Very Low  #
# -1 = Moderate  #
#  0 = Normal    #
#  1 = High      #
#  2 = Emergency #
##################

$priority = 0 if(!$priority); # Ohne Angabe wird "Normal" angenommen.

############# Benutzer suchen, Daten splitten, Ausgaben vorbereiten ###############
my $usr_ListHash = {}; 
foreach(@usr_List)
{ 
        my @usr_ListLine = split(/:/, $_);
        $$usr_ListHash{$usr_ListLine[0]} = $usr_ListLine[1];
}
my $apikey = $$usr_ListHash{$user};
if (!defined $$usr_ListHash{$user})
{
        Log 0, ("NMA_send: User $user not found\n");
} else {
	## Und ab dafür Richtung Cell-Phone und ggf. ins Logfile ###
	my $url = "http://www.notifymyandroid.com/publicapi/notify";
	my $put = "apikey=".$apikey."&application=".$application."&event=".$subject."&description=".$message."&priority=".$priority;
	fhem (CustomGetFileFromURL(0,$url,4,$put,$FB));
	if ($Log == 1) {Log 3, ("Der Benutzer ".$user." erhielt die Benachrichtigung: ".$subject."; ".$message)}
	}
}