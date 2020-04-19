// ============================================================================
// HamNewInfo - Unit for Hamster-Classic
// Copyright (c) 2005-2006, Remo Müller.
//
// Version 0.0.1.4
//
// ============================================================================

unit cHamNewInfo;

interface

type x1 = record
        hamsterpfad: String;
        mailuser: integer;
        newscount: integer;
        maildat: boolean;
        commando: String;
        filter: integer;
        error : boolean;
  end;
  type x2 = record
        name: String;
        emails: integer;
        neumail: integer;
  end;
  type x3 = record
        name: String;
        nachrichten: integer;
        neue: integer;
  end;


    function Dateienanzahl(Pfad: String): integer;
    procedure SaveInfos;
    procedure CreateInfos;
    procedure CreateInfos2;
    procedure MailVergleich;
    procedure Report_Mail;
    function HamNewInfo_End: Boolean;
    function HamNewInfo_Start: Boolean;






var
 myprog: x1;                //Programinterne, globale Variablen
 mailuser: array of x2;     //Liste für EMailuser
 mailuser2: array of x2;    //Liste für EMailuser zum Vergleich
 newsgroup: array of x3;    //Liste für Newsgruppen
 newsgroup2: array of x3;    //Liste für Newsgruppen zum Vergleich



implementation

uses
   Windows, inifiles, SysUtils, Classes, Math, Global, uDateTime, uTools,
   Config ;

{==============================================================================}
{ .----------------------------------------------------------------------.}
{ | Funktion zum Suchen der Dateien (Anzahl) in einen Verzeichnis        |
  |                                                                      |
  `----------------------------------------------------------------------'}

function Dateienanzahl(Pfad: String): integer;
var
    Count: Integer;
    SRec: TSearchRec;
    retval: Integer;
    oldlen: Integer;

  begin
  Count:=0;
      oldlen := Length( Pfad );
      {* look for normal files *}
      retval := FindFirst( Pfad, faAnyFile, SRec );
      While retval = 0 Do Begin
        If (SRec.Attr and (faDirectory or faVolumeID)) = 0 Then
         Count:= Count +1;

        retval := FindNext( SRec );
      End;
      FindClose( SRec );
      Result:=Count;

end;
{ '----------------------------------------------------------------------}
{ | Alle Informationen zur Anzahl der EMails der Mailuser und            |
  | Anzahl der Nachrichten in Newsgruppen als INI-File 'mail.dat' sicher.|
  `----------------------------------------------------------------------'}

procedure SaveInfos;
var i: integer;
    ExePfad : string;
    ini: TIniFile;

begin
ExePfad := PATH_BASE + 'mail.dat';
ini := Tinifile.Create(ExePfad);
ini.WriteInteger('Allgemein','Users',myprog.mailuser);

For i:=1 to myprog.mailuser do begin
ini.WriteString(IntToStr(i),'Username',mailuser[i].name );
ini.WriteInteger(IntToStr(i),'EMails',mailuser[i].emails);
end;

//Newsgroups - Info's speichern
ExePfad := PATH_BASE + 'news.dat';
ini := Tinifile.Create(ExePfad);
ini.WriteInteger('Allgemein','Newsgroups',myprog.newscount);

For i:=1 to myprog.newscount do begin
ini.WriteString(IntToStr(i),'Newsgroup',newsgroup[i].name );
ini.WriteInteger(IntToStr(i),'Anzahl',newsgroup[i].nachrichten);
end;

WriteProfileString(nil, nil, nil);
ini.Free;
end;

{ '----------------------------------------------------------------------}
{ | Alle Informationen zur Anzahl der EMails der Mailuser und            |
  | Anzahl der Nachrichten in Newsgruppen >>erstellen<<.                 |
  | Der aktuelle IST-Zustand wird erfasst.                               |
  `----------------------------------------------------------------------'}

// Erstellt Infos über Mailuser
procedure CreateInfos;
var DataPfad, temp : string;
    Count: Integer;
    Templist: TStrings;
    ini: TIniFile;
begin
//Hamsterpfad auslesen
myprog.hamsterpfad := PATH_BASE;

//Benutzerzahl auslesen
ini:=Tinifile.Create(myprog.hamsterpfad + 'Accounts.!!!');
myprog.mailuser:=ini.ReadInteger('Common','UserIDMax',0);

//Benutzervariable dimensionieren
SetLength(mailuser, myprog.mailuser +1 );

//Alle Usernamen einlesen und deren EMailsanzahl

temp:='';
for Count:=1 to myprog.mailuser do begin
mailuser[Count].name := ini.ReadString(IntToStr(Count),'Username','leer');
temp:=myprog.hamsterpfad + 'mails\' + mailuser[Count].name + '\*.*';
mailuser[Count].emails:=Dateienanzahl(temp);
end;

//Newsgruppennamen auslesen (Groups.hst)
Templist:= TStringlist.Create ;
Templist.LoadFromFile(myprog.hamsterpfad + 'Groups.hst');
myprog.newscount:= templist.Count ;

//Benutzervariable dimensionieren
SetLength(newsgroup, myprog.newscount + 1);

//Newsdaten auslesen (Namen und Anzahl der Nachrichten)

For Count:=0 to myprog.newscount -1 do begin
newsgroup[Count +1 ].name:= Templist.Strings[Count];
DataPfad:= myprog.hamsterpfad + 'Groups\' + newsgroup[Count +1 ].name + '\data.ini';
ini:=Tinifile.Create(DataPfad);
newsgroup[Count +1 ].nachrichten:= ini.ReadInteger('Ranges','Local.Max',0);
end;

WriteProfileString(nil, nil, nil);
ini.Free;
end;

{ '----------------------------------------------------------------------}
{ | Alle Informationen zur Anzahl der EMails der Mailuser und            |
  | Anzahl der Nachrichten in Newsgruppen >>erstellen<<.                 |
  | Der neue IST-Zustand wird erfasst.  / END   Zum Vergelich            |
  `----------------------------------------------------------------------'}

procedure CreateInfos2;
var ExePfad,DataPfad,temp : string;
    Count: Integer;
    ini: TIniFile;

begin
//Hamsterpfad auslesen
myprog.hamsterpfad := PATH_BASE;

//Benutzerzahl auslesen
ExePfad := PATH_BASE + 'mail.dat';
ini := Tinifile.Create(ExePfad);
myprog.mailuser:=ini.ReadInteger('Allgemein','Users',0);

//Benutzervariable dimensionieren
SetLength(mailuser2, myprog.mailuser +1 );

//Alle Usernamen einlesen und deren EMailsanzahl
temp:='';
for Count:=1 to myprog.mailuser do begin
mailuser2[Count].name := ini.ReadString(IntToStr(Count),'Username','leer');
temp:=myprog.hamsterpfad + 'mails\' + mailuser2[Count].name + '\*.*';
mailuser2[Count].emails:=Dateienanzahl(temp);
end;

//Newsgruppennamen einlesen (news.dat)
ExePfad := PATH_BASE + 'news.dat';
ini := Tinifile.Create(ExePfad);
myprog.newscount:=ini.ReadInteger('Allgemein','Newsgroups',0);

//Benutzervariable dimensionieren
SetLength(newsgroup2, myprog.newscount + 1);

//Newsgruppennamen einlesen aus news.dat
ExePfad := PATH_BASE + 'news.dat';
ini := Tinifile.Create(ExePfad);
For Count:=1 to myprog.newscount do begin
newsgroup2[Count].name:= ini.ReadString(IntToStr(Count),'Newsgroup','leer');
end;

//Newsanzahl neu erfassen
For Count:=1 to myprog.newscount do begin
DataPfad:= myprog.hamsterpfad + 'Groups\' + newsgroup2[Count].name + '\data.ini';
ini:=Tinifile.Create(DataPfad);
newsgroup2[Count].nachrichten:= ini.ReadInteger('Ranges','Local.Max',0);
end;

WriteProfileString(nil, nil, nil);
ini.Free;
end;

{ .----------------------------------------------------------------------.
  | Alten Infostand laden und mit neuen Infostand vergleichen            |
  | Der neue Status wird erfasst.  / END   Zum Vergleich                 |
  `----------------------------------------------------------------------'}

procedure MailVergleich;
var ExePfad: String;
    i: Integer;
    ini: TIniFile;

begin
//Alten EMailstand laden
ExePfad := PATH_BASE + 'mail.dat';
ini := Tinifile.Create(ExePfad);
myprog.mailuser:= ini.ReadInteger('Allgemein','Users',0);

//Benutzervariable dimensionieren
SetLength(mailuser, myprog.mailuser +1 );

//Usernamen und EMailanzahl auslesen
For i:=1 to myprog.mailuser do begin
mailuser[i].name:= ini.ReadString(IntToStr(i),'Username','none');
mailuser[i].emails:= ini.ReadInteger(IntToStr(i),'Emails',0);
end;

//Alten Newsbestand laden
ExePfad := PATH_BASE + 'news.dat';
ini := Tinifile.Create(ExePfad);
myprog.newscount := ini.ReadInteger('Allgemein','Newsgroups',0);

//Benutzervariable "NewsGroup" dimensionieren
SetLength(newsgroup, myprog.newscount +1 );

//Newsgroup-Namen und alte Nachrichtenzahl auslesen
For i:=1 to myprog.newscount  do begin
newsgroup[i].name := ini.ReadString(IntToStr(i),'Newsgroup','none');
newsgroup[i].nachrichten:= ini.ReadInteger(IntToStr(i),'Anzahl',0);
end;

//Neuen Status erfassen - Prozedur "CreateInfo2" aufrufen
CreateInfos2;


//Neue EMails auszählen
For i:=1 to myprog.mailuser do begin
mailuser[i].neumail := mailuser2[i].emails - mailuser[i].emails ;
end;
//Neue Newsnachrichten auszählen
For i:=1 to myprog.newscount do begin
newsgroup[i].neue := newsgroup2[i].nachrichten - newsgroup[i].nachrichten;
end;

WriteProfileString(nil, nil, nil);
ini.Free;
end;

{ .----------------------------------------------------------------------.
  | Der Report wird nun erstellt und als Datei abgespeichert.            |
  |   / END                                                              |
  `----------------------------------------------------------------------'}

procedure Report_Mail;
var TempList: TStrings;
    i,x1,x2,x3: Integer;
    fuelle, saveto, DestPath: String;


begin

//Nachrichtenblock erstellen
TempList := TStringList.Create;

{Header erstellen ...}

TempList.Add('Date: ' + DateTimeGMTToRfcDateTime( NowGMT, NowRfcTimezone ) );
TempList.Add('Message-ID: ' + MidGenerator( Def_FQDNforMIDs ) );
TempList.Add('To: <' + 'admin@hamster.invalid' + '>' );
Templist.Add('From: <' + 'local-smtp@hamster.invalid' + '>');
TempList.Add('Subject: Hamster-Report: ' + DateTimeToStr(Now) );
TempList.Add(#13#10);
 
{Nachrichtentext ...}
TempList.Add('Statusbericht über neue EMails:  ' + DateTimeToStr(Now));
Templist.Add('----------------------------------------------------------------');
Templist.Add('  ');

x3:=0;

For i:=1 to myprog.mailuser do begin
  x1:= 47 - (Length(mailuser[i].name) +1)  ;
  fuelle :='';
    For x2:=1 to x1 do begin
    fuelle := fuelle + '.';
    end;

    if mailuser[i].neumail > 0 then
    begin
        Templist.Add(mailuser[i].name + ' ' + fuelle + ' ' +IntToStr(mailuser[i].neumail) + ' neue EMail(s).');
    end;
    x3:= x3 + mailuser[i].neumail;
end;

Templist.Add('  ');
Templist.Add('----------------------------------------------------------------');
Templist.Add('Insgesamt sind: ' + IntToStr(x3) + ' neue EMail(s) angekommen.');
Templist.Add('  ');
Templist.Add('  ');

// ----------------------- NEWSGRUPPEN ---------------------------------------

TempList.Add('Statusbericht über neue Beiträge in Newsgruppen:  ');
Templist.Add('----------------------------------------------------------------');
Templist.Add('  ');

x3:=0;

For i:=1 to myprog.newscount do begin
  x1:= 47 - (Length(newsgroup[i].name ) +1)  ;
  fuelle :='';
    For x2:=1 to x1 do begin
    fuelle := fuelle + '.';
    end;

    if newsgroup[i].neue > 0 then
    begin
        Templist.Add(newsgroup[i].name  + ' ' + fuelle + ' ' +IntToStr(newsgroup[i].neue) + ' neue Beiträge.');
    end;
    x3:= x3 + newsgroup[i].neue;
end;

Templist.Add('  ');
Templist.Add('----------------------------------------------------------------');
Templist.Add('Insgesamt sind: ' + IntToStr(x3) + ' Newsgruppenbeiträge angekommen.');
//message1.Body := Templist;

DestPath:= PATH_BASE + 'Mails\Admin\';
saveto:= CfgHamster.GetUniqueMsgFilename( DestPath , 'mail' );



Templist.SaveToFile(saveto);
Templist.Free;


end;

{ .----------------------------------------------------------------------.
  | Befehlsfolge für HamNewInfo / END                                    |
  | Procedure: HamNewInfo_End;                                           |
  `----------------------------------------------------------------------'}

function HamNewInfo_End: Boolean;
var ExePfad : string;
begin

ExePfad := PATH_BASE + 'mail.dat';
myprog.maildat:=false;

  if FileExists(ExePfad) then
  begin
    myprog.maildat:=true;
  end;

  if myprog.maildat=false then
  begin
  // application.Terminate;
  ScriptAddlog('HamNewInfo-Error: Mail.dat fehlt.',3);
  end;

  if myprog.maildat=true then
  begin
  //Auswertung
  MailVergleich;
  Report_Mail;
  ScriptAddlog('HamNewInfo: Status-Nachricht an Admin zugesellt.',3);
  // application.Terminate;
  end;
  
  Result:=True;
end;

{ .----------------------------------------------------------------------.
  | Befehlsfolge für HamNewInfo / START                                  |
  | Procedure: HamNewInfo_Start;                                         |
  `----------------------------------------------------------------------'}

function HamNewInfo_Start: Boolean;

begin
    ScriptAddlog('HamNewInfo erfasst aktuellen Status.',3);
    CreateInfos;
    SaveInfos;
    Result:=True;
end;



//------------------------------------------------------------------------------




{===== END cHamNewInfo.pas ============================================}




end.
