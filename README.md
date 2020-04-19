# HamNewInfo-Unit
Unit für Hamster-Classic  

Um die Unit "<code>cHamNewInfo.pas</code>" nutzen zu können, muss diese Unit im Project
von [Hamster-Classic](https://de.wikipedia.org/wiki/Hamster_(Software))  
hinzugefügt werden. Folgende Veränderung in der Unit "<code>cHscEngine.pas</code>" müssen erfolgen: 

1. Unit "<code>cHamNewInfo</code>" im Bereich USES deklarieren
2. 
```batch
-----------------[ Änderung ]---------------------------------------------------
       'h': if FuncIs( 'hex', 1, 2 ) then begin
               Result.AsStr := inttohex( ParI(0), ParI(1,1) );
       {RM} end else if FuncIs( 'hamnewinfo_start', 0, 0 ) then begin
               Result.AsBool  := HamNewInfo_Start;
       {RM} end else if FuncIs( 'hamnewinfo_end', 0, 0 ) then begin
               Result.AsBool  := HamNewInfo_End;
            end;
-----------------[ Änderung ]---------------------------------------------------
```
Damit stehen nun 2 neue Befehle zu Verfügung.  
Weitere Informationen sind den Projekt [HamNewInfo](https://github.com/HackIT0/HamNewInfo) zu entnehmen.
