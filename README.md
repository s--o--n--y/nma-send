# nma-send
Automatically exported from code.google.com/p/nma-send

https://forum.fhem.de/index.php?topic=12722.0

Moin!

So, nachdem es mir den fhem-Stick zerlegt hat, durfte ich von vorne anfangen...  >:( Natürlich hatte ich auf keinem meiner Rechner eine Kopie der Daten... (*heul* seit Anbeginn meiner fhem-Zeit geschriebene Logs sind auch weg...)

Jetzt bin ich schlauer geworden und habe den Codeschnipsel hier abgelegt. Ist noch ein wenig buggy und auch noch nicht ganz fertig. Netterweise bietet Google hier aber auch einen Bug-Tracker (siehe dazu Menüpunkt "Issues") an.

Kann also fleißig drauf los geladen und getestet werden.

Versionshistorie: 0.1 ist die Ursprungsversion. Vorm Datenverlust hatte ich 0.5 im Test (die ich auch versprochen hatte mit euch zu teilen...). Da ich neu anfangen musste und noch ein wenig Hoffnung habe, die defekten Daten retten zu können, habe ich die neue Version 0.6 genannt.

Mit dem oben genannten Direktlink auf das SVN sieht man die Warnung nicht. Daher hier der Hinweis:
WARNUNG! DER DATEINAME 99_MyUtils.pm IST NUR EIN HINWEIS AUF DIE DATEI IN DER DIESER CODE GESPEICHERT WERDEN SOLLTE. ÜBERSCHREIBEN SIE NIEMALS DIE ORIGINALE 99_MyUtils.pm VON FHEM MIT DIESER DATEI!

Edit: Was kann die neue Version eigentlich?

{NMA_send("Überschrift","Text",Prio,Benutzer,Absender,Log)}

- Überschrift: Pflichtwert
- Text (Freitext): Pflichtwert
- Prio (Freitext): Optional. Wird keine Prio angegeben, wird 0 ("Prio:normal") angenommen.
- Benutzer (Freitext): Optional. Wird kein Benutzer angegeben, wird der erste Benutzer aus der @usr_List genommen.
- Log (0, 1): Optional. Überschreibt den fest hinterlegten Log-Wert des Snippets (generelle Einstellung ob Log ja oder nein: $Log)
