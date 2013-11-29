sub 
NMA_send($$@){
#                                                                     2013V0.71   #

###################################################################################
# Funktion, um NotifyMyAndroid leichter zu senden                                 #
#                                                                                 #
#Aufruf: {NMA_send("Betreff","Nachricht"[,Priorität,"User","Absender","Logging"])}#
###################################################################################

###################### Variablen aus Funktionsaufruf bilden #######################
my ($subject, $message, $priority, $user, $application, $Log) = @_;

################################# EINSTELLUNGEN ###################################

$priority = 0 if(!$priority);               # Welche Priorität soll genommen werden, wenn keine übergeben wird?
                                            ########### Prioritäten: ############
                                            # -2 = Very Low    (sehr niedrig)   #
                                            # -1 = Moderate    (mittelmäßig)    #
                                            #  0 = Normal      (Normal)         #
                                            #  1 = High        (Hoch)           #
                                            #  2 = Emergency   (Notfall)        #
                                            #####################################
$application = "FHEM" if(!$application);    # Welcher Absender soll genommen werden, wenn Absender fehlt?
my $FB = 1;                                 # 0=keine FRITZ!Box, 1=fhem läuft auf FRITZ!Box
my $useSSL = 0;                             # 0=ohne SSL, 1=mit SSL (einige Geräte unterstützen kein SSL)
$Log = 1 if(!$Log);                         # 0=kein Eintrag im Logfile, 1=Eintrag im Logfile (kann über Funktionsaufruf separat getriggert werden)

my @usr_List = 
( "Name:1234567890abcdef1234567890abcdef1234567890abcdef"
);

# Listenformat: 
#( "Name1:API-Key1",
#  "Name2:API-Key2"
#);
# nach dem letzten Listeneintrag KEIN Komma! Sonst immer!

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!! ES GEHEN NUR API-KEYS !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
# Wenn kein API-Key vorhanden, auf http://www.notifymyandroid.com einloggen       #
# und im Menü "My Account" unter "Manage my API keys" einen                       #
# "My Account" unter "Manage my API keys" einen API-Key erstellen.                #
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#

($user,my @dummy) = split(/:/, $usr_List[0]) if(!$user);    # setzt den ersten User der Liste, wenn kein User übergeben wurde.

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