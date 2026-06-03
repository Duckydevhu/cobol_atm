*> Megmondjuk a fordítónak, hogy felejtse el a régi lyukkártyás oszlop-szabályokat (szabad formátum)
>>SOURCE FORMAT FREE

*> ==============================================================================
*> 1. AZONOSÍTÁSI RÉSZ (A program "személyi igazolványa")
*> [OKTATÁSI MODUL]: Minden COBOL program 4 fő részből (DIVISION) áll. 
*> Az első az IDENTIFICATION DIVISION, amely kötelező. Régen a bankokban itt 
*> adták meg a programozó nevét, a megírás dátumát és a biztonsági szintet is.
*> ==============================================================================
IDENTIFICATION DIVISION.
PROGRAM-ID. ATM-SZIMULATOR.

*> ==============================================================================
*> 2. KÖRNYEZETI RÉSZ (Kapcsolat a külvilággal és a géppel)
*> [OKTATÁSI MODUL]: A COBOL zsenialitása abban rejlik, hogy elválasztja a 
*> hardverfüggő fájlkezelést magától az üzleti logikától. Ezt itt tesszük meg.
*> ==============================================================================
ENVIRONMENT DIVISION.
INPUT-OUTPUT SECTION.
FILE-CONTROL.
    *> [OKTATÁSI MODUL]: Itt történik a "hozzárendelés" (ASSIGN). 
    *> A programon belül "SZAMLA-FAJL" néven fogunk hivatkozni arra az adathalmazra, 
    *> ami a fizikai merevlemezen valójában a "szamlak.dat" néven létezik.
    SELECT SZAMLA-FAJL ASSIGN TO "szamlak.dat"
        *> A LINE SEQUENTIAL azt jelenti, hogy a fájl egyszerű szöveges sorokból áll 
        *> (mint egy .txt fájl a Jegyzettömbben), amelyeket egymás után olvasunk.
        ORGANIZATION IS LINE SEQUENTIAL.
    
    *> Az "OPTIONAL" kulcsszó védi meg a programot az összeomlástól, ha a fájl még nem létezik.
    SELECT OPTIONAL TRANZ-FAJL ASSIGN TO "tranzakciok.txt"
        ORGANIZATION IS LINE SEQUENTIAL.
    
    SELECT OPTIONAL TEMP-FAJL ASSIGN TO "temp.dat"
        ORGANIZATION IS LINE SEQUENTIAL.
    
    SELECT OPTIONAL RIPORT-FAJL ASSIGN TO "riport.txt"
        ORGANIZATION IS LINE SEQUENTIAL.

*> ==============================================================================
*> 3. ADAT RÉSZ (A memória, a fájlok és a változók pontos szerkezete)
*> [OKTATÁSI MODUL]: Ez a program "lelke". A COBOL-ban a memóriafoglalást 
*> karakteres pontossággal kell megadni, megakadályozva a memóriatúlcsordulást.
*> ==============================================================================
DATA DIVISION.

*> --- FÁJL SZEKCIÓ ---
*> Itt írjuk le, hogy az előbb a fizikai fájlokhoz rendelt adatok hogyan néznek ki belülről.
FILE SECTION.

FD  SZAMLA-FAJL.
*> [OKTATÁSI MODUL]: SZINTSZÁMOK (Level Numbers)
*> A COBOL hierarchikusan tárolja az adatokat. A '01' a legmagasabb szint (rekord),
*> ami olyan, mint egy 'struct' vagy 'Class' a modern nyelvekben. A '05' (vagy 10, 15)
*> a rekordon belüli mezőket jelöli.
01  SZAMLA-REKORD.
    *> [OKTATÁSI MODUL]: A 'PIC' (Picture) határozza meg az adattípust:
    *> - PIC 9: Csak numerikus számjegy (0-9). A zárójel a hosszt jelenti (4 bájt).
    *> - PIC X: Alfanumerikus (bármilyen betű, szám, szóköz).
    05 SZAMLA-SZAM      PIC 9(4).
    05 SZAMLA-PIN       PIC 9(4).
    05 SZAMLA-EGYENLEG  PIC 9(7).

FD  TRANZ-FAJL.
01  TRANZ-REKORD.
    05 TR-SZAMLA        PIC 9(4).
    05 TR-TIPUS         PIC X(10).
    05 TR-OSSZEG        PIC 9(7).

FD  TEMP-FAJL.
01  TEMP-REKORD.
    05 TP-SZAMLA        PIC 9(4).
    05 TP-PIN           PIC 9(4).
    05 TP-EGYENLEG      PIC 9(7).

FD  RIPORT-FAJL.
01  RIPORT-KIMENET      PIC X(50).


*> --- MUNKAMEMÓRIA SZEKCIÓ ---
*> Ide kerülnek azok a változók, amik nem fájlból jönnek, hanem a futás során 
*> számoláshoz, állapot-tároláshoz szükségesek (RAM).
WORKING-STORAGE SECTION.
*> Fájl vége (End Of File) jelző. 'Y' (Yes) vagy 'N' (No).
01  WS-EOF              PIC X VALUE 'N'.
01  WS-BEIRT-SZAMLA     PIC 9(4).
01  WS-BEIRT-PIN        PIC 9(4).
01  WS-SIKERES-LOGIN    PIC X VALUE 'N'.
01  WS-AKTUALIS-EGYENLEG PIC 9(7) VALUE ZEROS.
01  WS-MENU-VALASZTAS   PIC X VALUE '0'.
01  WS-ATM-FUT          PIC X VALUE 'Y'.
01  WS-MUVELET-OSSZEG   PIC 9(7) VALUE ZEROS.
01  WS-SORSZAM          PIC 99 VALUE ZEROS.

*> Változók az Utalás funkcióhoz
01  WS-CEL-SZAMLA       PIC 9(4).
01  WS-CEL-TALALAT      PIC X VALUE 'N'.
01  WS-CEL-EGYENLEG     PIC 9(7).
01  WS-CEL-PIN          PIC 9(4).

*> Változók a Riport funkcióhoz
01  WS-RIPORT-TIPUS      PIC X.
01  WS-KERT-DARAB        PIC 9(3) VALUE ZEROS.
01  WS-OSSZ-TRANZAKCIO   PIC 9(4) VALUE ZEROS.
01  WS-JELENLEGI-SORSZAM PIC 9(4) VALUE ZEROS.
01  WS-START-INDEX       PIC 9(4) VALUE ZEROS.

*> A riportba beírandó formázott sor szerkezete
01  WS-FORMAS-SOR.
    05 FS-DATUM         PIC X(12) VALUE "2026-05-25 |".
    05 FS-TIPUS         PIC X(11).
    *> [OKTATÁSI MODUL]: A 'Z' betű a "Zero Suppression" maszkolást jelenti.
    *> Ha az összeg 0005000, akkor a PIC 9999999 kiírná a nullákat is.
    *> A PIC ZZZZZZ9 eltünteti a vezető nullákat, így "   5000" lesz belőle (könnyebb olvasni).
    05 FS-OSSZEG        PIC ZZZZZZ9.
    05 FS-VALUTA        PIC X(5) VALUE " HUF".


*> ==============================================================================
*> 4. ELJÁRÁSI RÉSZ (Maga a futtatható algoritmus / A cselekvések)
*> [OKTATÁSI MODUL]: Itt vannak a parancsok. A COBOL megpróbálja az angol nyelvtant
*> utánozni (pl. "ADD A TO B", "READ FILE", "OPEN INPUT"). Nincsenek szigorú függvények,
*> hanem bekezdések (paragrafusok) vannak, amelyeket a PERFORM utasítás hív meg.
*> ==============================================================================
PROCEDURE DIVISION.

*> --- A FŐCIKLUS (Belépési pont) ---
MAIN-LOGIC.
    PERFORM KEPERNYO-TORLES.
    DISPLAY "=======================================".
    DISPLAY "       UDVOZLI A COBOL BANK ATM        ".
    DISPLAY "=======================================".
    
    *> [OKTATÁSI MODUL]: A PERFORM parancs egy szubrutin-hívás. 
    *> Laugrik a megadott bekezdéshez, végrehajtja, majd VISSZATÉR ide.
    PERFORM AZONOSITAS.
    
    IF WS-SIKERES-LOGIN = 'Y' THEN
        *> Ez a fő program-hurok (while loop). Addig ismétlődik, amíg a változó 'N' nem lesz.
        PERFORM UNTIL WS-ATM-FUT = 'N'
            PERFORM MENU-KIRAJZOLAS
            PERFORM MENU-VEZERELES
        END-PERFORM
    END-IF.
    
    PERFORM KEPERNYO-TORLES.
    DISPLAY "=======================================".
    DISPLAY " KOSZONJUK, HOGY MINKET VALASZTOTT!   ".
    DISPLAY "=======================================".
    *> STOP RUN = Az operációs rendszernek visszaadjuk az irányítást, program vége.
    STOP RUN.

*> ------------------------------------------------------------------------------
*> BELÉPTETÉS RUTINJA (Fájl olvasási algoritmus)
*> ------------------------------------------------------------------------------
AZONOSITAS.
    DISPLAY "Kerem, adja meg a 4 jegyu szamlaszamot: " WITH NO ADVANCING.
    ACCEPT WS-BEIRT-SZAMLA.
    DISPLAY "Kerem, adja meg a 4 jegyu PIN kodot: " WITH NO ADVANCING.
    ACCEPT WS-BEIRT-PIN.
    
    *> [OKTATÁSI MODUL]: Fájl olvasásának alapstruktúrája.
    *> 1. Megnyitjuk olvasásra (INPUT).
    OPEN INPUT SZAMLA-FAJL.
    MOVE 'N' TO WS-EOF.
    
    *> 2. Addig olvasunk egy ciklusban, amíg az EOF (End Of File) változó 'Y' nem lesz.
    PERFORM UNTIL WS-EOF = 'Y'
        READ SZAMLA-FAJL
            *> AT END = Ha a beépített olvasó a fájl legvégébe ütközik:
            AT END 
                MOVE 'Y' TO WS-EOF
            *> NOT AT END = Sikeres sor-beolvasás esetén fut le
            NOT AT END
                IF SZAMLA-SZAM > 0 THEN
                    IF SZAMLA-SZAM = WS-BEIRT-SZAMLA AND SZAMLA-PIN = WS-BEIRT-PIN THEN
                        MOVE 'Y' TO WS-SIKERES-LOGIN
                        MOVE SZAMLA-EGYENLEG TO WS-AKTUALIS-EGYENLEG
                        *> "Becsapjuk" a ciklust: ha megtaláltuk, beállítjuk az EOF-ot 'Y'-ra,
                        *> így a ciklus feleslegesen már nem olvassa végig a maradék fájlt.
                        MOVE 'Y' TO WS-EOF
                    END-IF
                END-IF
        END-READ
    END-PERFORM.
    *> 3. Lezárjuk a fájlt (memória felszabadítása).
    CLOSE SZAMLA-FAJL.
    
    IF WS-SIKERES-LOGIN = 'Y' THEN
        DISPLAY ">>> SIKERES BELEPES! <<<"
        PERFORM NYOMJ-ENTERT
    ELSE
        DISPLAY ">>> HIBA: Helytelen adatok! A program leall. <<<"
        PERFORM NYOMJ-ENTERT
    END-IF.

*> ------------------------------------------------------------------------------
*> MENÜ KIRAJZOLÁSA 
*> ------------------------------------------------------------------------------
MENU-KIRAJZOLAS.
    PERFORM KEPERNYO-TORLES.
    DISPLAY "--- ATM FO MENU (Szamla: " WS-BEIRT-SZAMLA ") ---".
    DISPLAY "1. Szamlaegyenleg lekerdezese".
    DISPLAY "2. Keszpenz befizetes (+)".
    DISPLAY "3. Keszpenz felvetel (-)".
    DISPLAY "4. Utalas masik szamlara".
    DISPLAY "5. Riport keszitese (.txt)".
    DISPLAY "6. Kilepes (Bankkartya visszaadasa)".
    DISPLAY "Valasztasod (1-6): " WITH NO ADVANCING.
    ACCEPT WS-MENU-VALASZTAS.

*> ------------------------------------------------------------------------------
*> MENÜ VEZÉRLÉSE 
*> ------------------------------------------------------------------------------
MENU-VEZERELES.
    *> [OKTATÁSI MODUL]: Az EVALUATE utasítás a C/Java/Python switch-case megfelelője.
    *> Sokkal olvashatóbb, mint egymásba ágyazott IF-ELSE parancsokat írni.
    EVALUATE WS-MENU-VALASZTAS
        WHEN '1'
            DISPLAY " "
            DISPLAY "Aktualis egyenleged: " WS-AKTUALIS-EGYENLEG " HUF"
            PERFORM NYOMJ-ENTERT
        WHEN '2'
            PERFORM BEFIZETES-LOGIKA
            PERFORM NYOMJ-ENTERT
        WHEN '3'
            PERFORM KESZPENZ-FELVET-LOGIKA
            PERFORM NYOMJ-ENTERT
        WHEN '4'
            PERFORM UTALAS-LOGIKA
            PERFORM NYOMJ-ENTERT
        WHEN '5'
            PERFORM RIPORT-LOGIKA
            PERFORM NYOMJ-ENTERT
        WHEN '6'
            DISPLAY " "
            DISPLAY "Bizonylat nyomtatasa... Kartya kiadasa."
            PERFORM NYOMJ-ENTERT
            *> Kilépünk a főciklusból
            MOVE 'N' TO WS-ATM-FUT
        WHEN OTHER
            DISPLAY " "
            DISPLAY "HIBA: Ervenytelen valasztas! Keresem 1 es 6 kozott valassz."
            PERFORM NYOMJ-ENTERT
    END-EVALUATE.

*> ------------------------------------------------------------------------------
*> MŰVELETI LOGIKÁK (Matematika és fájlba írás)
*> ------------------------------------------------------------------------------
BEFIZETES-LOGIKA.
    DISPLAY " "
    DISPLAY "Add meg a befizetni kivant osszeget: " WITH NO ADVANCING.
    ACCEPT WS-MUVELET-OSSZEG.
    
    *> Matematikai parancsok: ADD (összeadás), SUBTRACT (kivonás), MULTIPLY (szorzás), DIVIDE (osztás).
    ADD WS-MUVELET-OSSZEG TO WS-AKTUALIS-EGYENLEG.
    DISPLAY "Sikeres befizetes! Uj egyenleg: " WS-AKTUALIS-EGYENLEG " HUF".
    
    *> [OKTATÁSI MODUL]: EXTEND mód a fájlmegnyitásnál.
    *> Ezzel nem felülírjuk a fájlt (mint az OUTPUT-tal), hanem a legvégére fűzünk új sorokat (Logolás).
    OPEN EXTEND TRANZ-FAJL.
    MOVE WS-BEIRT-SZAMLA TO TR-SZAMLA.
    MOVE "BEFIZETES " TO TR-TIPUS.
    MOVE WS-MUVELET-OSSZEG TO TR-OSSZEG.
    WRITE TRANZ-REKORD.
    CLOSE TRANZ-FAJL.
    
    PERFORM ADATBAZIS-FRISSITESE.

KESZPENZ-FELVET-LOGIKA.
    DISPLAY " "
    DISPLAY "Add meg a felvenni kivant osszeget: " WITH NO ADVANCING.
    ACCEPT WS-MUVELET-OSSZEG.
    
    IF WS-MUVELET-OSSZEG > WS-AKTUALIS-EGYENLEG THEN
        DISPLAY "HIBA: Nincs elegendo fedezet a szamlan!"
    ELSE
        SUBTRACT WS-MUVELET-OSSZEG FROM WS-AKTUALIS-EGYENLEG
        DISPLAY "Vegye el a keszpenzt! Uj egyenleg: " WS-AKTUALIS-EGYENLEG " HUF"
        
        OPEN EXTEND TRANZ-FAJL
        MOVE WS-BEIRT-SZAMLA TO TR-SZAMLA
        MOVE "PENZFELVET" TO TR-TIPUS
        MOVE WS-MUVELET-OSSZEG TO TR-OSSZEG
        WRITE TRANZ-REKORD
        CLOSE TRANZ-FAJL
        
        PERFORM ADATBAZIS-FRISSITESE
    END-IF.

UTALAS-LOGIKA.
    DISPLAY " "
    DISPLAY "Add meg a cel szamlaszamot: " WITH NO ADVANCING.
    ACCEPT WS-CEL-SZAMLA.
    
    IF WS-CEL-SZAMLA = WS-BEIRT-SZAMLA THEN
        DISPLAY "HIBA: Sajat magadnak nem utalhatsz!"
    ELSE
        DISPLAY "Add meg az utalni kivant osszeget: " WITH NO ADVANCING
        ACCEPT WS-MUVELET-OSSZEG
        
        IF WS-MUVELET-OSSZEG > WS-AKTUALIS-EGYENLEG THEN
            DISPLAY "HIBA: Nincs elegendo fedezet!"
        ELSE
            *> Címzett keresése
            MOVE 'N' TO WS-CEL-TALALAT
            OPEN INPUT SZAMLA-FAJL
            MOVE 'N' TO WS-EOF
            PERFORM UNTIL WS-EOF = 'Y'
                READ SZAMLA-FAJL
                    AT END MOVE 'Y' TO WS-EOF
                    NOT AT END
                        IF SZAMLA-SZAM = WS-CEL-SZAMLA THEN
                            MOVE 'Y' TO WS-CEL-TALALAT
                            MOVE SZAMLA-EGYENLEG TO WS-CEL-EGYENLEG
                            MOVE SZAMLA-PIN TO WS-CEL-PIN
                        END-IF
                END-READ
            END-PERFORM
            CLOSE SZAMLA-FAJL
            
            *> Tranzakció végrehajtása
            IF WS-CEL-TALALAT = 'Y' THEN
                SUBTRACT WS-MUVELET-OSSZEG FROM WS-AKTUALIS-EGYENLEG
                ADD WS-MUVELET-OSSZEG TO WS-CEL-EGYENLEG
                DISPLAY "Sikeres utalas! Uj egyenleged: " WS-AKTUALIS-EGYENLEG " HUF"
                
                OPEN EXTEND TRANZ-FAJL
                MOVE WS-BEIRT-SZAMLA TO TR-SZAMLA
                MOVE "UTALAS KI " TO TR-TIPUS
                MOVE WS-MUVELET-OSSZEG TO TR-OSSZEG
                WRITE TRANZ-REKORD
                
                MOVE WS-CEL-SZAMLA TO TR-SZAMLA
                MOVE "UTALAS BE " TO TR-TIPUS
                WRITE TRANZ-REKORD
                CLOSE TRANZ-FAJL
                
                PERFORM ADATBAZIS-FRISSITESE
            ELSE
                DISPLAY "HIBA: A megadott cel szamla nem letezik az adatbazisban!"
            END-IF
        END-IF
    END-IF.

*> ------------------------------------------------------------------------------
*> RIPORT GENERÁLÁS LOGIKÁJA (Szövegformázás és Slicing)
*> ------------------------------------------------------------------------------
RIPORT-LOGIKA.
    DISPLAY " "
    DISPLAY "Riport tipusa (T = Teljes tortenet, X = Utolso X darab): " WITH NO ADVANCING.
    ACCEPT WS-RIPORT-TIPUS.
    
    MOVE 0 TO WS-START-INDEX.
    
    IF WS-RIPORT-TIPUS = 'X' OR WS-RIPORT-TIPUS = 'x' THEN
        DISPLAY "Hany darab tranzakciot szeretnel latni? " WITH NO ADVANCING
        ACCEPT WS-KERT-DARAB
        
        MOVE 0 TO WS-OSSZ-TRANZAKCIO
        OPEN INPUT TRANZ-FAJL
        MOVE 'N' TO WS-EOF
        PERFORM UNTIL WS-EOF = 'Y'
            READ TRANZ-FAJL
                AT END MOVE 'Y' TO WS-EOF
                NOT AT END
                    IF TR-SZAMLA = WS-BEIRT-SZAMLA THEN
                        ADD 1 TO WS-OSSZ-TRANZAKCIO
                    END-IF
            END-READ
        END-PERFORM
        CLOSE TRANZ-FAJL
        
        IF WS-OSSZ-TRANZAKCIO > WS-KERT-DARAB THEN
            SUBTRACT WS-KERT-DARAB FROM WS-OSSZ-TRANZAKCIO GIVING WS-START-INDEX
        END-IF
    END-IF.

    OPEN OUTPUT RIPORT-FAJL.
    
    *> [OKTATÁSI MODUL]: Karakter-manipuláció (String Slicing)
    *> A memóriaszemét eltakarítása fontos (MOVE SPACES). A COBOL megengedi, 
    *> hogy egy hosszú string adott pontjától adott hosszúságú részt írjunk felül.
    *> Formátum: VALTOZO (KEZDOPONT : HOSSZ)
    MOVE SPACES TO RIPORT-KIMENET.
    MOVE "==== KIVONAT: " TO RIPORT-KIMENET(1:14).
    MOVE WS-BEIRT-SZAMLA TO RIPORT-KIMENET(15:4).
    MOVE " ====" TO RIPORT-KIMENET(19:5).
    WRITE RIPORT-KIMENET.
    
    MOVE 0 TO WS-JELENLEGI-SORSZAM.
    OPEN INPUT TRANZ-FAJL.
    MOVE 'N' TO WS-EOF.
    
    PERFORM UNTIL WS-EOF = 'Y'
        READ TRANZ-FAJL
            AT END MOVE 'Y' TO WS-EOF
            NOT AT END
                IF TR-SZAMLA = WS-BEIRT-SZAMLA THEN
                    ADD 1 TO WS-JELENLEGI-SORSZAM
                    IF WS-JELENLEGI-SORSZAM > WS-START-INDEX THEN
                        MOVE TR-TIPUS TO FS-TIPUS
                        MOVE TR-OSSZEG TO FS-OSSZEG
                        MOVE WS-FORMAS-SOR TO RIPORT-KIMENET
                        WRITE RIPORT-KIMENET
                    END-IF
                END-IF
        END-READ
    END-PERFORM.
    
    CLOSE TRANZ-FAJL.
    
    MOVE SPACES TO RIPORT-KIMENET.
    MOVE "==== AKTUALIS EGYENLEG: " TO RIPORT-KIMENET(1:24).
    MOVE WS-AKTUALIS-EGYENLEG TO FS-OSSZEG.
    MOVE FS-OSSZEG TO RIPORT-KIMENET(25:7).
    MOVE " HUF" TO RIPORT-KIMENET(32:4).
    WRITE RIPORT-KIMENET.
    
    CLOSE RIPORT-FAJL.
    DISPLAY "Sikeresen letrejott a 'riport.txt' fajl a mappaban!".

*> ------------------------------------------------------------------------------
*> ADATBÁZIS FRISSÍTÉSE (A Master-Transaction COBOL Minta)
*> ------------------------------------------------------------------------------
ADATBAZIS-FRISSITESE.
    *> [OKTATÁSI MODUL]: Szekvenciális Fájl Frissítési Stratégia
    *> Szekvenciális (soros) fájl közepén lévő adatot nem lehet helyben felülírni, 
    *> mert elcsúszhat a struktúra. A banki szabvány erre a következő:
    *> 1. Olvassuk végig a Master fájlt.
    *> 2. A megváltozott (tranzakciós) adatokat frissítsük a RAM-ban.
    *> 3. Írjunk ki MINDENT egy új Temp (Átmeneti) fájlba.
    *> 4. A folyamat végén a Temp fájlt másoljuk rá a Master fájlra.
    
    *> Fázis 1: Frissítés és Temp fájl készítése
    OPEN INPUT SZAMLA-FAJL.
    OPEN OUTPUT TEMP-FAJL.
    MOVE 'N' TO WS-EOF.
    
    PERFORM UNTIL WS-EOF = 'Y'
        READ SZAMLA-FAJL
            AT END
                MOVE 'Y' TO WS-EOF
            NOT AT END
                IF SZAMLA-SZAM > 0 THEN
                    MOVE SZAMLA-SZAM TO TP-SZAMLA
                    MOVE SZAMLA-PIN TO TP-PIN
                    MOVE SZAMLA-EGYENLEG TO TP-EGYENLEG
                    
                    *> Ha miénk a sor, új egyenleget írunk
                    IF SZAMLA-SZAM = WS-BEIRT-SZAMLA THEN
                        MOVE WS-AKTUALIS-EGYENLEG TO TP-EGYENLEG
                    END-IF
                    
                    *> Ha utalás volt és ez a címzett sora, az ő új egyenlegét írjuk
                    IF WS-MENU-VALASZTAS = '4' AND SZAMLA-SZAM = WS-CEL-SZAMLA THEN
                        MOVE WS-CEL-EGYENLEG TO TP-EGYENLEG
                    END-IF
                    
                    WRITE TEMP-REKORD
                END-IF
        END-READ
    END-PERFORM.
    CLOSE SZAMLA-FAJL.
    CLOSE TEMP-FAJL.
    
    *> Fázis 2: Temp fájl tartalmának visszamásolása a Master fájlra
    OPEN INPUT TEMP-FAJL.
    OPEN OUTPUT SZAMLA-FAJL.
    MOVE 'N' TO WS-EOF.
    
    PERFORM UNTIL WS-EOF = 'Y'
        READ TEMP-FAJL
            AT END
                MOVE 'Y' TO WS-EOF
            NOT AT END
                MOVE TEMP-REKORD TO SZAMLA-REKORD
                WRITE SZAMLA-REKORD
        END-READ
    END-PERFORM.
    CLOSE TEMP-FAJL.
    CLOSE SZAMLA-FAJL.

*> ------------------------------------------------------------------------------
*> SEGÉD: VÁRAKOZÁS GOMBNYOMÁSRA ÉS KÉPERNYŐTÖRLÉS
*> ------------------------------------------------------------------------------
NYOMJ-ENTERT.
    DISPLAY " ".
    DISPLAY "Tovabblepeshez nyomjon Entert (egy barmilyen gombot)..." WITH NO ADVANCING.
    ACCEPT WS-MENU-VALASZTAS.

KEPERNYO-TORLES.
    MOVE 0 TO WS-SORSZAM.
    PERFORM UNTIL WS-SORSZAM = 50
        DISPLAY " "
        ADD 1 TO WS-SORSZAM
    END-PERFORM.