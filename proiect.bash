#!/bin/bash

#1. Crearea si actualizarea bazei de date.
creare_fisier() {
echo "Crearea si actualizarea bazei de date de tip CSV"
while true
  do
  read -p "Scrieti numele fisierului de tip CSV pe care doriti sa il creati: " fisier
  if echo "$fisier" | grep -Eq ^[a-zA-Z0-9]+$
    then
      break
    else
      echo "Numele introdus pentru fisier nu este valid. Va rugam introduceti doar litere si/sau cifre!"
  fi
  done
nano "$fisier.csv"
echo "Fisierul cu numele $fisier.csv a fost creat!"
sleep 3
}

#2. Adaugarea unor noi inregistrari cu ID autogenerat.
adaugare_inregistrari() {
echo "Adaugarea de noi inregistrari cu ID autogenerat. "

if [ -f "$fisier.csv" ]
  then

IDs=$(tail -n +2 "$fisier.csv" | awk 'BEGIN{FS=","} { printf("%d ", $1)}')

for id in ${IDs[@]}
  do
    ultim=$id
  done
ultim=$((ultim+1))

echo "Urmatoarea inregistrare se va adauga cu ID-ul $ultim"

#verificare nume

while true
  do
    read -p "Introduceti numele angajatului pe care doriti sa il adaugati: " nume
    if echo "$nume" | grep -Eq "^[ a-zA-Z ]+$"
      then
        echo "Numele introdus este valid!"
        break
      else
        echo "Numele introdus NU este valid!"
    fi
  done

#verificare email

while true
  do
    read -p "Introduceti email-ul angajatului: " email
    if echo "$email" | grep -Eq "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"
      then
        echo "Email-ul introdus este valid!"
        break
      else
        echo "Email-ul introdus NU este valid!"
    fi
  done

#verificare varsta

while true
  do
    read -p "Introduceti varsta angajatului: " varsta
    if [[ $varsta =~ ^[0-9]+$ ]] && (( $varsta > 17 )) && (( $varsta < 75 ))
      then
        echo "Varsta introdusa este valida!"
        break
      else
        echo "Varsta introdusa NU este valida!"
    fi
  done

#verificare departament

while true
  do
    read -p "Introduceti numele departamentului din care face parte angajatul: " departament
    if echo "$departament" | grep -Eq "^[ a-zA-Z ]+$"
      then
        echo "Departamentul introdus este valid!"
        break
      else
        echo "Departamentul introdus NU este valid!"
    fi
  done

#verificare vechime

while true
  do
    read -p "Introduceti vechimea pe care o are angajatul in cadrul firmei: " vechime
    if (( $vechime > 0 ))
      then
        echo "Vechimea introdusa este valida!"
        break
      else
        echo "Vechimea introdusa NU este valida!"
    fi
  done

#verificare salariu

while true
  do
    read -p "Introduceti salariul pe care il are angajatul: " salariu
    if [[ $salariu =~ ^[0-9]+$ ]] && (( $salariu > 1500 ))
      then
        echo "Salariul introdus este valid!"
        break
      else
        echo "Salariul introdus NU este valid! Salariul nu poate fi mai mic decat 1500 lei!"
    fi
  done

#adaugarea inregistrarii in fisier

ID=$ultim
echo "$ID, $nume, $email, $varsta, $departament, $vechime, $salariu" >> "$fisier.csv"
echo "Inregistrarea a fost introdusa in $fisier.csv cu succes!"
IDs+=($ID)

  else
    echo "Fisierul nu exista sau nu a fost creat!"
fi

sleep 3
}

#3. Stergerea unei inregistrari avand ca data de intrare ID-ul
stergere_inregistrare() {
echo "Stergerea unei inregistrari avand ca data de intrare ID-ul introdus."
if [ -f "$fisier.csv" ]
  then
listaID=$(tail -n +2 "$fisier.csv" | awk 'BEGIN{FS=","} { printf("%d ", $1)}')
ok=0
while true
  do
    read -p "Introduceti ID-ul inregistrarii pe care doriti sa o stergeti: " IDsters
    if [[ $IDsters =~ ^[0-9]+$ ]]
      then
      for j in ${listaID[@]}
        do
          if (( $IDsters==$j ))
            then
              echo "ID-ul introdus apartine unei inregistrari."
              ok=1
              break
          fi
        done
    fi
    if (( $ok==0 ))
      then
        echo "ID-ul introdus nu este numeric sau nu apartine niciunei inregistrari."
      else
        break
    fi
  done

local temporar="temporarstergere.csv"
touch "$temporar"

while IFS="," read -r ID Nume Email Varsta Departament Vechime Salariu
  do
    if [[ $ID != $IDsters  ]]
      then
        echo "$ID, $Nume, $Email, $Varsta, $Departament, $Vechime, $Salariu" >> "$temporar"
    fi
  done < "$fisier.csv"

mv "$temporar" "$fisier.csv"

echo "Inregistrarea cu ID-ul $IDsters a fost stearsa din $fisier.csv!"
  else
    echo "Fisierul nu exista sau nu a fost creat!"
fi

sleep 3
}

#4. Sortarea inregistrarilor dupa un anumit criteriu
sortare() {
echo "Sortarea inregistrarilor dupa un anumit criteriu."
if [ -f "$fisier.csv" ]
  then


echo "Sortarea inregistrarilor se poate face dupa unul din urmatoarele criterii: "
echo "1. Nume (se vor afisa primii angajati introdusi, in functie de numarul dorit)."
echo "2. Varsta, in ordine crescatoare sau descrescatoare."
echo "3. Vechime, in ordine crescatoare sau descrescatoare."
echo "4. Salariu."

while true
  do
    read -p "Introduceti tipul de sortare dorit (a se alege dintre indicii din textul de mai sus): " indice
    if (( $indice<5 )) && (( $indice>0 ))
      then
        break
      else
        echo "Indicele introdus nu reprezinta un tip de sortare. Va rugam sa alegeti un indice cuprins intre 1 si 5!"
    fi
  done

numar_inregistrari=$(awk 'BEGIN {FS=","} NR>1 {count++} END {print count}' "$fisier.csv")

if (( $indice==1 ))
  then
    echo "Sortarea aleasa de catre dumneavoastra este prin nume."

    while true
    do
      read -p "Introduceti primii cati angajati doriti sa va apara pe ecran(numarul de angajati este de $numar_inregistrari): " sortare_nume
      if  (( $sortare_nume<$numar_inregistrari+1 )) &&  [[ $sortare_nume =~ ^[0-9]+$ ]]
        then
          break
        else
          echo "Numarul introdus nu este numeric sau nu exista atatia angajati!"
          echo "Numarul de angajati este de $numar_inregistrari."
      fi
    done
    echo "Primii $sortare_nume angajati sunt: "
    head -n 1 "$fisier.csv"
    tail -n +2 "$fisier.csv" | sort -t ',' -k 1 -n | head -n "$sortare_nume"
fi

if (( $indice==2 ))
  then
    echo "Sortarea aleasa de catre dumneavoastra este prin varsta."
    while true
      do
         read -p "Introduceti daca doriti ca angajatii sa fie sortati crescator sau descrescator dupa varsta: " sortare_varsta
         if [[ $sortare_varsta == "crescator" ]] || [[ $sortare_varsta == "descrescator" ]]
           then
             break
           else
             echo "Nu ati introdus corect daca doriti ca angajatii sa fie sortati crescator sau descrescator. Va rugam sa rescrieti exact ca in mesaj."
         fi
      done
    echo "Ati ales ca angajatii sa fie sortati prin varsta in mod $sortare_varsta."
    echo "Angajatii sortati in mod $sortare_varsta: "
    head -n 1 "$fisier.csv"
    if [[ $sortare_varsta == "crescator" ]]
      then
        tail -n +2 "$fisier.csv" | sort -t ','  -k 4 -n
      else
        tail -n +2 "$fisier.csv" | sort -t ',' -k 4 -nr
    fi
fi
if (( $indice==3 ))
  then
    echo "Sortarea aleasa de catre dumneavoastra este prin vechimea angajatilor."
    while true
      do
         read -p "Introduceti daca doriti ca angajatii sa fie sortati crescator sau descrescator dupa vechime: " sortare_vechime
         if [[ $sortare_vechime == "crescator" ]] || [[ $sortare_vechime == "descrescator" ]]
           then
             break
           else
             echo "Nu ati introdus corect daca doriti ca angajatii sa fie sortati crescator sau descrescator. Va rugam sa rescrieti exact ca in mesaj."
         fi
      done
    echo "Ati ales ca angajatii sa fie sortati prin vechime in mod $sortare_vechime."
    echo "Angajatii sortati in mod $sortare_vechime: "
    head -n 1 "$fisier.csv"
    if [[ $sortare_vechime == "crescator" ]]
      then
        tail -n +2 "$fisier.csv" | sort -t ','  -k 6 -n
      else
        tail -n +2 "$fisier.csv" | sort -t ',' -k 6 -nr
    fi
fi

if (( $indice==4 ))
  then
    echo "Sortarea aleasa de catre dumneavoastra este prin salariu."
    while true
      do
        read -p "Introduceti cati angajati care au salariul in ordine descrescatoare doriti sa vedeti: " sortare_salariu
        if [[ $sortare_salariu =~ ^[0-9]+$ ]] && (( $sortare_salariu<$numar_inregistrari+1 ))
          then
            break
          else
            echo "Numarul introdus nu este in format numeric sau este un numar mai mare decat numarul de angajati."
            echo "Numarul de angajati este de $numar_inregistrari."
        fi
      done
    echo "Ati ales sa fie afisati primii $sortare_salariu angajati cu salariul in ordine descrescatoare."
    echo "Primii $sortare_salariu angajati cu salariul in ordine descrescatoare sunt: "
    head -n 1 "$fisier.csv"
    tail -n +2 "$fisier.csv" | sort -t ',' -k 7 -nr | head -n "$sortare_salariu"
fi

read -n 1 -s -p "Apasati orice tasta pentru a continua ... " tasta

  else
    echo "Fisierul nu exista sau nu a fost creat!"
fi
sleep 3
}

#5. Actualizarea unei inregistrari avand cunoscut ID-ul acesteia
actualizare_inregistrare() {
echo "Actualizarea unei inregistrari avand cunoscut ID-ul acesteia."
if [ -f "$fisier.csv" ]
  then
    while true
      do
        read -p "Introduceti ID-ul inregistrarii pe care doriti sa o actualizati: " IDactualizare
        if [[ $IDactualizare =~ ^[0-9]+$ ]]
          then
            if grep -q "^$IDactualizare," "$fisier.csv"
              then
                while true
                  do
                    read -p "Ce camp doriti sa actualizati? Alegeti dintre Nume, Email, Varsta, Departament, Vechime sau Salariu): " camp
                    if echo "$camp" | grep -Eq "^[ a-zA-Z ]+$"
                      then
                       case $camp in
                         Nume)
                           while true
                               do
                                 read -p "Introduceti numele actualizat: " nume_nou
                                 if echo "$nume_nou" | grep -Eq "^[ a-zA-Z ]+$"
                                   then
                                     echo "Numele introdus este valid!"
                                     break
                                 else
                                   echo "Numele introdus NU este valid! Introduceti doar litere!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v nume_nou=" $nume_nou" '$1 == IDactualizare { $2 = nume_nou } { print }' "$fisier.csv" > "$temporar.csv"
                           echo "Numele a fost actualizat cu succes!"
                           break;;
                         Email)
                             while true
                               do
                                 read -p "Introduceti email-ul actualizat: " email_nou

if echo "$email_nou" | grep -Eq "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"
                                   then
                                     echo "Email-ul introdus este valid!"
                                     break
                                 else
                                   echo "Email-ul introdus NU este valid!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v email_nou=" $email_nou" '$1 == IDactualizare { $3 = email_nou } { print }' "$fisier.csv" > "$temporar.csv"
                           echo "Email-ul a fost actualizat cu succes!"
                           break;;
                         Varsta)
                            while true
                               do
                                 read -p "Introduceti varsta actualizata: " varsta_nou
                                 if [[ $varsta_nou =~ ^[0-9]+$ ]] && (( $varsta_nou > 17 )) && (( $varsta_nou < 75 ))
                                   then
                                     echo "Varsta introdusa este valida!"
                                     break
                                 else
                                   echo "Varsta introdusa NU este valida! Introduceti doar cifre!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v varsta_nou=" $varsta_nou" '$1 == IDactualizare { $4 = varsta_nou } { print }' "$fisier.csv" > "$temporar.csv">
                           echo "Varsta a fost actualizata cu succes!"
                           break;;
                         Departament)
                           while true
                               do
                                 read -p "Introduceti departamentul actualizat: " departament_nou
                                 if echo "$departament_nou" | grep -Eq "^[ a-zA-Z ]+$"
                                   then
                                     echo "Departamentul introdus este valid!"
                                     break
                                 else
                                   echo "Departamentul introdus NU este valid! Introduceti doar litere!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v departament_nou=" $departament_nou" '$1 == IDactualizare { $5 = departament_nou } { print }' "$fisier.csv" > "$temporar.csv"
                           echo "Departamentul a fost actualizat cu succes!"
                           break;;
 Vechime)
                           while true
                               do
                                 read -p "Introduceti vechimea actualizata: " vechime_nou
                                 if (( $vechime_nou > 0 ))
                                   then
                                     echo "Vechimea introdusa este valida!"
                                     break
                                 else
                                   echo "Varsta introdusa NU este valida! Introduceti doar cifre!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v vechime_nou=" $vechime_nou" '$1 == IDactualizare { $6 = vechime_nou } { print }' "$fisier.csv" > "$temporar.csv">
                           echo "Varsta a fost actualizata cu succes!"
                           break;;
                         Salariu)
                           while true
                               do
                                 read -p "Introduceti salariul actualizat: " salariu_nou
                                 if [[ $salariu_nou =~ ^[0-9]+$ ]] && (( $salariu_nou > 1500 ))
                                   then
                                     echo "Salariul introdusa este valid!"
                                     break
                                 else
                                   echo "Salariul introdus NU este valid! Introduceti doar cifre, iar salariul nu poate fi mai mic de 1500 lei!"
                                   fi
                               done
                           awk -F, -v OFS=',' -v IDactualizare="$IDactualizare" -v salariu_nou=" $salariu_nou" '$1 == IDactualizare { $7 = salariu_nou } { print }' "$fisier.csv" > "$temporar.csv">
                           echo "Salariul a fost actualizat cu succes!"
                           break;;
                         *) echo "Optiunea introdusa nu esta valida.";;
                       esac
                    else
                      echo "Campul introdus trebuia sa contina doar litere si sa fie scris exact ca in mesajul de mai sus!"
                    fi
                done
              else
                echo "Nu exista nicio inregistrare cu ID-ul introdus."
              fi
        else
          echo "ID-ul introdus nu este numeric!"
        fi
        #Inlocuim in fisierul original, actualizarile din fisierul temporar
if [ -f "$temporar.csv" ]
  then
    mv "$temporar.csv" "$fisier.csv"
    echo "Inregistrarea cu ID-ul $IDactualizare a fost actualizata cu succes!"
  else
    echo "Inregistrarea cu ID-ul $IDactualizare NU a fost actualizata!"
fi

ok=0
#Vedem daca utilizatorul doreste sa mai faca modificari
  while true
    do
      read -p "Doriti sa mai faceti alte actualizari in vreo inregistrare? Scrieti da sau nu: " actualizari
      if [[ $actualizari == "nu" ]]
        then
          ok=1
          break
        else
          if [[ $actualizari == "da" ]]
            then
              break
          fi
      fi
    done
  if (( $ok==1 ))
    then
      break
  fi
  done
  else
    echo "Fisierul nu exista sau nu a fost creat!"
fi

read -n 1 -s -p "Apasati orice tasta pentru a continua ... " tasta
}

#6. Afisarea inregistrarilor
afisare_inregistrari() {
echo "Afisarea tuturor inregistrarilor: "
if [ -f "$fisier.csv" ]
  then
echo " ID |   Nume   |      Email      |  Varsta  |  Departament  |  Vechime  |  Salariu  |"
echo "-------------------------------------------------------------------------------------"
tail -n +2 "$fisier.csv" | awk 'BEGIN{FS=",";OFS=" | "} {printf "%-4s  %-8s  %-17s   %-10s %-15s %-11s %-11s\n", $1, $2, $3, $4, $5, $6, $7}'
echo "-------------------------------------------------------------------------------------"
  else
     echo "Fisierul nu exista sau nu a fost creat!"
fi
read -n 1 -s -p "Apasati orice tasta pentru a continua ... " tasta
}

#Meniu
i=100
while [ $i -ne 0 ]
  do
     clear
     echo "1. Crearea si actualizarea bazei de date de tip CSV."
     echo "2. Adaugarea unei inregistrari noi cu ID autogenerat."
     echo "3. Stergerea unei inregistrari avand ca data de intrare ID-ul."
     echo "4. Sortarea inregistrarilor dupa un anumit criteriu."
     echo "5. Actualizarea unei inregistrari fiind cunoscut ID-ul acesteia."
     echo "6. Afisarea tuturor inregistrarilor."
     echo "0. EXIT."
     while true
       do
       read -p "Introduceti optiunea dorita: " i
       if [[ $i =~ ^(0|[1-9][0-9]*)$ ]]
         then
           break
         else
           echo "Optiunea introdusa NU este numerica!"
       fi
       done
 case $i in
      1) creare_fisier;;
      2) adaugare_inregistrari;;
      3) stergere_inregistrare;;
      4) sortare;;
      5) actualizare_inregistrare;;
      6) afisare_inregistrari;;
      0) echo "Iesire din program."; sleep 3;;
      *) echo "Optiune invalida, va rugam alegeti alta optiune."; sleep 3;;
     esac
  done
