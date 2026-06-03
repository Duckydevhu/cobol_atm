# 🏦 COBOL ATM Szimulátor – Oktatási Projekt

Ez a tároló (repository) egy kifejezetten oktatási célokra írt, teljesen funkcionális bankautomata (ATM) szimulátort tartalmaz, amely **COBOL** nyelven készült. 

A projekt célja, hogy bemutassa a COBOL nyelv alapjait, a szekvenciális fájlkezelést és a klasszikus üzleti/pénzügyi logikák felépítését egy könnyen érthető, jól dokumentált példán keresztül.

---

## 🎯 Mit tanulhatsz ebből a projektből?

A forráskód gazdagon el van látva magyar nyelvű oktatási kommentekkel (`*> [OKTATÁSI MODUL]`), amelyek elmagyarázzák a következő fogalmakat:
* **A COBOL programok 4 fő divíziója:** `IDENTIFICATION`, `ENVIRONMENT`, `DATA`, `PROCEDURE`.
* **Memóriakezelés és adattípusok:** A `PIC` (Picture) záradékok és a szintszámok (01, 05) használata.
* **Karakter-manipuláció:** Slicing és maszkolás (pl. "Zero Suppression" a `PIC ZZZZZZ9` segítségével).
* **Fájlkezelés:** Szöveges fájlok olvasása (`INPUT`), írása (`OUTPUT`) és hozzáfűzése (`EXTEND`).
* **A "Master-Transaction" minta:** Hogyan frissítsünk adatokat szekvenciális fájlokban egy ideiglenes (Temp) fájl beiktatásával (mivel a COBOL nem használ modern relációs adatbázisokat alapértelmezetten).

---

## ⚙️ Funkciók

A szimulátor az alábbi banki műveleteket képes elvégezni a terminálban:
1.  PIN kódos beléptetés (adatbázis ellenőrzéssel)
2.  Számlaegyenleg lekérdezése
3.  Készpénz befizetése
4.  Készpénz felvétele (fedezet-ellenőrzéssel)
5.  Utalás egy másik számlára (a címzett egyenlegének frissítésével)
6.  Tranzakciós riport (kivonat) generálása egy formázott `.txt` fájlba

---

## 🚀 Telepítés és Futtatás

A program futtatásához egy COBOL fordítóra lesz szükséged. A legnépszerűbb nyílt forráskódú megoldás a **GnuCOBOL**.

### 1. GnuCOBOL telepítése
* **Ubuntu/Debian:** `sudo apt-get install gnucobol`
* **macOS (Homebrew):** `brew install gnu-cobol`
* **Windows:** Érdemes WSL-t (Windows Subsystem for Linux) használni, vagy telepíteni egy natív GnuCOBOL portot.

### 2. A program fordítása
Klónozd a tárolót, nyiss egy terminált abban a mappában, és futtasd a fordítót:
bash
cobc -x -free atm-szimulator.cob -o atm
(Megjegyzés: A -free kapcsoló – vagy a kódban lévő >>SOURCE FORMAT FREE direktíva – jelzi a fordítónak, hogy ne a régi, 80 oszlopos lyukkártyás formátumot várja, hanem a modern, szabad sortördelést.)

3. Futtatás
Bash
./atm
📁 Fájlstruktúra
A program futása során az alábbi szöveges fájlokkal dolgozik (ezek a fizikai meghajtón jönnek létre az első futtatások során):

atm-szimulator.cob: Maga a COBOL forráskód.

szamlak.dat: A "Master" adatbázis. Ide mentődnek a számlaszámok, PIN kódok és egyenlegek.

tranzakciok.txt: A műveleti napló (log fájl), ahová minden utalás, felvét és befizetés bekerül egymás után fűzve.

temp.dat: Ideiglenes fájl, ami a szamlak.dat biztonságos frissítésekor jön létre a háttérben.

riport.txt: A felhasználó által a menüből generált csinosított bankszámlakivonat.

💡 Hasznos tanács a teszteléshez
Mielőtt futtatod a programot, érdemes létrehoznod egy kezdeti szamlak.dat nevű fájlt ugyanabban a mappában, amiben teszt számlák vannak. Példa tartalom (Számlaszám, PIN, Egyenleg - szóközök nélkül egybefűzve):

Plaintext
111112340050000
222256780000000
(Ez a sor azt jelenti: 1111-es számla, 1234-es PIN kód, 50 000 HUF egyenleg).
