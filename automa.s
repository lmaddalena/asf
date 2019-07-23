#=======================================================================================#
# Grammatiche regolari, automi a stati finiti e riconoscimento di stringhe              #
# Luca Maddalena #4563165 lmaddalena@lm-tech.it                                         # 
#=======================================================================================#

		.data
		
CHR_Z:		.word  90		# codice ASCII del carattere Z 
CHR_A:		.word  65		# codice ASCII del carattere A
CHR_a:		.word  97		# codice ASCII del carattere a
CHR_z:		.word 122		# codice ASCII del carattere z
CHR_LF:		.word  10		# codice ASCII line feed
CHR_SP:		.word  32		# codice ASCII del carattere SPACE
TESTA:		.word	0		# TESTA dell'automa
CODA:		.word	0		# CODA  dell'automa


msgstart:   	.asciiz "LABORATORIO DI ARCHITETTURA DEGLI ELABORATORI\n\nGrammatiche regolari, automi a stati finiti e \nriconoscimento di stringhe\n\nLuca Maddalena\nMatricola #4563165\nlmaddalena@lm-tech.it\n\n"
msgmenu:	.asciiz "\n\nMENU' PRINCIPALE\n================\n\n1. inserimento della grammatica\n2. riconoscimento di parole\n3. uscita\n"
msgchoice:  	.asciiz "\nscegli l'opzione (1, 2, 3): "
msgend:		.asciiz "\n\nFine\n\n"
msgcheck:	.asciiz "\n\nVerifica della grammatica inserita:"
msgchkerr:	.asciiz "\n*** Errori nella grammatica. Ripetere l'inserimento"
msgchkok:	.asciiz "\nGrammatica formalmente corretta"
msgline:        .asciiz "\n----------------------------------------------------"



		.text
		.globl	main
				
main:	
		# --
		# -- stampa il messaggio iniziale
		# --
		la $a0, msgstart 	# mette in $a0 l'indirizzo della stringa msgstart		 
		li $v0, 4      		# codice per la stampa di un stringa		 
		syscall 		# stampa il messaggio iniziale (msgstart)

		# --
		# -- stampa il menu
		# --
mainmenu:	la $a0, msgmenu 	# mette in $a0 l'indirizzo della stringa msgmenu
		li $v0, 4      		# codice per la stampa di un stringa
		syscall 		# stampa il menu (msgmenu)

		# --
		# -- salva nei registri $t1, $t2, $t3 i codici ascii delle opzioni
		# --
		li $t1, 49		# memorizzo in $t1 il codice ascii del carattere 1
		li $t2, 50		# memorizzo in $t2 il codice ascii del carattere 2
		li $t3, 51		# memorizzo in $t3 il codice ascii del carattere 3

		# --
		# -- stampa il messaggio di effettuare la scelta
		# --
choice:		la $a0, msgchoice	# mette in $a0 l'indirizzo della strina msgmenu
		li $v0, 4		# codice per la stampa di una stringa      				
		syscall 		# stampa il messaggio di scelta (msgchoice)
			
		# --
		# -- legge la scelta dalla console
		# --
		li $v0, 12     		# codice per leggere un carattere dalla console		
		syscall			# legge un carattere da console e salva il valore in $v0

		# --
		# -- valuta l'opzione scelta. Se diversa da 1,2,3 ripete la richiesta
		# --
		beq $v0, $t1, opt1	# se $v0 = 1 salta all'etichetta opt1
		beq $v0, $t2, opt2	# se $v0 = 2 salta all'etichetta opt2
		beq $v0, $t3, exit	# se $v0 = 3 salta all'etichetta exit		
		j choice		# non è stato inserito una valore valido, ripete la richiesta di scegliere una opzione
			
		# --
		# -- richiama la procedura di inserimento della grammatica
		# --
opt1:		jal insgramm		# chiama la procedura insgramm

		# --
		# -- se non è stata inserita la grammatica torna al menu principale
		# --
		lw $t0, TESTA		  # $t0 = TESTA 
		beq $t0, $zero, mainmenu  # se $t0 = $zero non è stata inserita la grammatica, salta a meinmenu

		# --
		# -- verifica della grammatica inserita
		# --
		la $a0, msgcheck 	  # mette in $a0 l'indirizzo della stringa msgcheck
		li $v0, 4      		  # codice per la stampa di una stringa
		syscall 		  # stampa il messaggio di verifica della grammatica

		la $a0, msgline 	  # mette in $a0 l'indirizzo della stringa msgline
		li $v0, 4      		  # codice per la stampa di una stringa
		syscall 		  # stampa la linea di separazione
		
		jal check		  # chiama la procedura di verifica della grammatica inserita 
		bne $v0, $zero, checkerr  # se $v0 != 0 sono stati rilavati errori nella grammatica, salta a checkerr
		

		# --
		# -- la grammatica inserita è corretta. Stampa il messaggio e torna al menu
		# --	
		la $a0, msgline 	# mette in $a0 l'indirizzo della stringa msgline
		li $v0, 4      		# codice per la stampa di una stringa
		syscall 		# stampa la linea di separazione
		
		la $a0, msgchkok	# mette in $a0 l'indirizzo della stringa msgchkok
		li $v0, 4      		# codice per la stampa di una stringa
		syscall 		# stampa il messaggio di grammatca corretta

		j mainmenu		# salta a mainmenu
		
		# --
		# -- errori nella grammatica. Azzera i puntatori della lista, stampa il messaggio di errore e torna al menu
		# --
checkerr:	sw $zero, TESTA		# TESTA = 0
		sw $zero, CODA		# CODA  = 0

		la $a0, msgline 	# mette in $a0 l'indirizzo della stringa msgline
		li $v0, 4      		# codice per la stampa di una stringa
		syscall 		# stampa la linea di separazione

		la $a0, msgchkerr	# mette in $a0 l'indirizzo della stringa msgchkerr
		li $v0, 4		# codice per la stampa di una stringa
		syscall 		# stampa il messaggio di errore nella grammatica
		
		j mainmenu		# torna all'inizio

		# --
		# -- riconoscimento di parole
		# --
opt2:       	jal riconoscimento	# chiama la procedura riconoscimento
		j mainmenu		# torna all'inizio
		
		# --
		# -- Scrive il messaggio di fine e termina l'esecuzione
		# --	
exit:
		la $a0, msgend		# mette in $a0 l'indirizzo della stringa msgchkerr
		li $v0, 4      		# codice per la stampa di una stringa
		syscall			# stampa il messaggio di fine (msgend)

		li $v0, 10                	
		syscall			# termina il programma
		
		
#=======================================================================================#
# procedura inserimento della grammatica                                                #
#=======================================================================================#

insgramm:
		.data		
msgtitle1:	.asciiz "\n\ninserimento grammatica regolare\n-------------------------------\n\n"
msgguide:	.asciiz "Guida:\n\nG = (T,N,S,P) grammatica\nT = {a,...,z} simboli terminali (carattere alfabetico minuscolo)\nN = {A,...,Z} simboli non terminali (carattere alfabetico maiuscolo)\nS = simbolo non terminali iniziale (assioma)\nP = insieme delle produzioni nella forma aS, a\n\n[INVIO] per terminare l'inserimento\n\n"
msgnote:    	.asciiz "Nota: Il primo simbolo non terminale inserito viene assunto come simbolo iniziale.\n      Z è il simbolo non terminale finale predefinito.\n\n"
msgsymb:	.asciiz "\ninserisci un simbolo non terminale N = {A,...,Y}: "
msgprod:	.asciiz "\n\ninserisci le produzioni per il simbolo inserito (forma aS, a): "
msgparamerr: 	.asciiz "\n\n**** valore inserito non valido\n"
msgzetaerr:	.asciiz "\n\n**** non è consentito iserire il simbolo Z poichè è il simbolo finale predefinito.\n"
instr:		.space 3 		# riserva 3 byte per la stringa di input"

		.text

		# --
		# -- Salva i registri nello stack
		# --
		addi $sp, $sp, -24	# alloca 24 byte nello stack per salvare i registri		
		sw   $s0, 20($sp)	# salva il registro $s0
		sw   $s1, 16($sp)	# salva il registro $s1
		sw   $s2, 12($sp)	# salva il registro $s2
		sw   $s3,  8($sp)	# salva il registro $s3
		sw   $s4,  4($sp)	# salva il registro $s4
		sw   $ra,  0($sp)	# salva il registro $ra

		# --
		# -- Azzera i puntatori della lista
		# --		
		sw $zero, TESTA		# TESTA = 0
		sw $zero, CODA		# CODA  = 0

		# --
		# -- Stampa il titolo della procedura
		# --		
		la $a0, msgtitle1	# mette in $a0 l'indirizzo della stringa msgchkerr
		li $v0, 4		# codice per la stampa di una stringa
		syscall 		# stampa il titolo della procedura 

		# --
		# -- Stampa la guida
		# --		
		la $a0, msgguide	# mette in $a0 l'indirizzo della stringa msgguida
		li $v0, 4		# codice per la stampa di una stringa
		syscall 		# stampa la guida

		# --
		# -- Stampa le note
		# --		
		la $a0, msgnote 	# mette in $a0 l'indirizzo della stringa msgnote
		li $v0, 4 		# codice per la stampa di una stringa
		syscall 		# stampa le note

		# --
		# -- Inserimento del simbolo non terminale
		# --		
inssymb:	la $a0, msgsymb 	# mette in $a0 l'indirizzo della stringa msgsymb
		li $v0, 4      		# codice per la stampa di una stringa
		syscall 		# stampa il messaggio di inserimento di un simbolo

		# --
		# -- Legge un carattere dalla console e lo salva in $s0
		# --			
		li $v0, 12     		# codice per leggere un carattere: $v0=carattere
		syscall
		
		move $s0, $v0		# metto $v0 in $s0

		# --
		# -- Appoggia nei registri temporanei i codici ASCII dei caratteri di controllo
		# --			
		lw $t2, CHR_Z		# $t2 = CHR_Z  (codice ascii Z)
		lw $t3, CHR_A		# $t3 = CHR_A  (codice ascii A)
		lw $t4, CHR_LF		# $t4 = CHR_LF (codice ascii Line Feed)
		
		# --
		# -- Valuta il carattere inserito dalla console
		# --					
		beq $s0, $t4, exitopt1	# se $s0 = $t4 (è stato premuto invio) salta a exitopt1 
		beq $s0, $t2, zetaerr	# se $s0 = $t2 (è stato inserito il carattere Z) salta a zetaerr
		blt $s0, $t3, symberr	# se $s0 < $t3 (è stato inserito un carattere non valido) salta a symberr
		bgt $s0, $t2, symberr	# se $s0 > $t2 (è stato inserito un carattere non valido) salta a symberr

		j insprod		# tutto ok. Salta a insprod (inserimento produzioni)

		# --
		# -- E' stato inserito un valore non valido. Stampa un messaggio e ripete l'inserimento
		# --							
symberr:	la $a0, msgparamerr	# mette in $a0 l'indirizzo della stringa msgparamerr
		li $v0, 4      		# codice per la stampa di una stringa	
		syscall 		# stampa il messaggio di errore inserimento parametro
			
		j inssymb		# salta a inssymb (ripete la richiesta di inserire un simbolo)

		# --
		# -- E' stato inserito il simbolo Z. Stampa un messaggio e ripete l'inserimento
		# --										
zetaerr:	la $a0, msgzetaerr	# mette in $a0 l'indirizzo della stringa msgzetaerr
		li $v0, 4      		# codice per la stampa di una stringa	
		syscall 		# stampa il messaggio di errore inserimento simbolo Z
			
		j inssymb		# salta a inssymb (ripete la richiesta di inserire un simbolo)


		# --
		# -- Il simbolo inserito è valido. Richiede di inserire le produzioni
		# --					
insprod:	la $a0, msgprod 	# mette in $a0 l'indirizzo della stringa msgprod
		li $v0, 4      		# codice per la stampa di una stringa	
		syscall 		# stampa il messaggio di richiesta di inserire le produzioni

		# --
		# -- Legge una stringa di due caratteri dalla console
		# --					
		li $v0, 8      		# codice per leggere una stringa arguments: $a0=buffer, $a1=length
		la $a0, instr		# $a0 = puntatore all'area di memoria che conterrà la stringa
		li $a1, 3		# $a1 = 3 (lunghezza della stringa di input in byte)
		syscall

		# --
		# -- Salva i due caratteri inseriti in $s1 e $s2 
		# --					
		la $t0, instr		# carico in $t0 l'indirizzo della stringa di input
		lb $s1, 0($t0)		# carico in $s1 il primo byte a partire dall'indirizzo in $t0 (primo carattere inserito)
		lb $s2, 1($t0)		# carico in $s2 il secondo byte a partire dall'indirizzo in $t0 (secondo carattere inserito)
			
		# --
		# -- Se è stato premuto invio sulla console torna a inserimento simbolo
		# --					
		li  $t0,  10		# $t0 =  10 (codice ascii Line Feed)
		beq $s1, $t0, inssymb	# se è stato premuto invio salta a insysymb (inserimento simbolo non terminale)


		# --
		# -- Effettua il parsing della produzione inserita. Se c'è un errore ripete l'inserimento
		# --					
		move $a0, $s1		# primo paramentro della procedura (primo carattere della produzione)
		move $a1, $s2		# secondo paramentro della procedura (secondo carattere della produzione)
		jal  parseprod		# richiama la procedura parseprod

		beq $v0, $zero, insprod # se c'è stato un errore nel parsing chiede nuovamente di inserire la produzione

		# --
		# -- Il parsing è andata a buon fine. Salva i valori di ritorno della procedura insprod in $s1 e $s2 
		# --					
		move $s1, $v0		# salva il primo valore di ritorno della procedura insprod in $s1
		move $s2, $v1		# salva il secondo valore di ritorno della procedura insprod in $s2

		# --
		# -- Inserisce la produzione nella lista in memoria e ripete la richiesta di inserimento
		# --
		move $a0, $s0		# primo paramentro della procedura (simbolo NT)
		move $a1, $s1		# secondo paramentro della procedura (primo carattere della produzione)
		move $a2, $s2		# terzo paramentro della procedura (secondo carattere della produzione)
		jal  addprod		# richiama la procedura addprod
		
		j    insprod		# chiede di inserire una nuova produzione
					
			
exitopt1:	
		# --
		# -- ripristina i registri ed esce dalla procedura
		# --
		lw   $s0, 20($sp)	# ripristina il registro $s0
		lw   $s1, 16($sp)	# ripristina il registro $s1
		lw   $s2, 12($sp)	# ripristina il registro $s2
		lw   $s2,  8($sp)	# ripristina il registro $s3
		lw   $s2,  4($sp)	# ripristina il registro $s4		
		lw   $ra,  0($sp)	# ripristina il registro $ra
		
		addi $sp, $sp, 24	# libera lo stack
		jr   $ra		# torna al chiamante




#=======================================================================================#
# procedura per il parsing della produzione                                             #
#                                                                                       #
# Parametri:                                                                            #
# $a0 - primo elemento della produzione (simbolo terminale)                             #
# $a1 - secondo elemento della produzione (simbolo non terminale)                       #
#                                                                                       #
# Valori di ritorno:                                                                    #
# $v0 - primo elemento della produzione dopo il parse (zero se c'è stato un errore)     #
# $v1 - secondo elemento della produzione dopo il parse (zero se c'è stato un errore)   #
#=======================================================================================#
parseprod:
		.data
msgerr1: 	.asciiz "\n\n**** valore inserito non valido\n"
msgerr2:	.asciiz "\n\n**** non è consentito iserire il simbolo Z poichè è il simbolo finale predefinito.\n"

		.text

		# --
		# -- Salva i registri utilizzati nello stack
		# --
		addi $sp, $sp, -12	# alloca 12 byte nello stack per salvare i registri
		sw   $s0, 8($sp)	# nei primi 4 byte memorizza il valore del registro $s0
		sw   $s1, 4($sp)	# nei secondi 4 byte il valore di $s1
		sw   $s2, 0($sp)	# nei restanti 4 byte il valore di $s2
		
		# --
		# -- Salva i parametri di input della procedura in $s0 e $s1
		# --
		move $s0, $a0		# $s0 = $a0 primo parametro della procedura
		move $s1, $a1		# $s1 = $a1 secondo parametro della procedura

		# --
		# -- Appoggia nei registri temporanei i codici ascii dei caratteri di controllo
		# --
		lw   $t0, CHR_A		# $t0 = CHR_A  (codice ascii A)
		lw   $t1, CHR_Z		# $t1 = CHR_Z  (codice ascii Z)
		lw   $t2, CHR_a		# $t2 = CHR_a  (codice ascii a)
		lw   $t3, CHR_z		# $t3 = CHR_z  (codice ascii z)
		lw   $t4, CHR_LF	# $t4 = CHR_LF (codice ascii Line Feed)
		
		# --
		# -- Verifica che il primo carattere della produzione sia compreso tra a - z
		# --
		blt  $s0, $t2, proderr	# se $s0 < $t2 (è stato inserito un carattere non valido) salta a proderr
		bgt  $s0, $t3, proderr	# se $s0 > $t3 (è stato inserito un carattere non valido) salta a proderr

		# --
		# -- Controlla se è stato inserito solamente il simbolo terminale
		# --	
		beq  $s1, $t4, nosymb 	# è stato inserito un solo carattere nella produzione, salta a nosymb

		# --
		# -- Controlla se è stato inserito il simbolo non terminale Z
		# --	
		beq  $s1, $t1, zerr	# se $s1 = $t1 (è stato inserito Z nel secondo carattere della produzione) salta a zerr				
	
		# --
		# -- Controlla che il secondo carattere della produzione sia comprezo tra A - Z
		# --
		blt  $s1, $t0, proderr	# se $s1 < $t0 (è stato inserito un carattere non valido) salta a proderr
		bgt  $s1, $t1, proderr	# se $s1 > $t1 (è stato inserito un carattere non valido) salta a proderr

		# --
		# -- Tutto ok. Memorizza i simboli nei registri di ritorno ed esce
		# --
		move $v0, $s0		# valorizza il primo valore di ritorno
		move $v1, $s1		# valorizza il secondo valore di ritorno
		j    exitparseprod	# Salta a exitparseprod

		# --
		# -- E' stato inseito sulo il simbolo terminale, mette nel secondo parametro il simbolo NT predefinito Z
		# --
nosymb:		move $s1, $t1		# carica il codice ASCII del carattere Z nel registro $s1				
		move $v0, $s0		# valorizza il primo valore di ritorno
		move $v1, $s1		# valorizza il secondo valore di ritorno
		j    exitparseprod	# Salta a exitparseprod

		# --
		# -- Errore nella produzione, stampa il messaggio ed esce con errore
		# --
proderr:	la $a0, msgerr1		# mette in $a0 il puntatotr alla stringa msgerr1			
		li $v0, 4      		# codice per la stampa di una stringa		
		syscall 		# stampa il messaggio di errore parametro
		j  parseerr		# salta a parseerr

		# --
		# -- E' stato inserito il simbolo NT Z, stampa il messaggio ed esce con errore
		# --
zerr:		la $a0, msgerr2 	# mette in $a0 il puntatotr alla stringa msgerr2					
		li $v0, 4      		# codice per la stampa di una stringa			
		syscall 		# stampa il messaggio di errore inserimento simbolo Z

		# --
		# -- Errore ne parsing. Mettte zero nei valori di ritorno
		# --
parseerr:	move $v0, $zero		# imposta il primo valore di ritorno a zero
		move $v1, $zero		# imposta il secondo valore di ritorno a zero


		# --
		# -- ripristina i registri, libera lo stack ed esce dalla procedura
		# --
exitparseprod:	
		lw   $s0, 8($sp)	# ripristina il registro $s0
		lw   $s1, 4($sp)	# ripristina il registro $s1
		lw   $s2, 0($sp)	# ripristina il registro $s2		
		addi $sp, $sp, 12	# libera lo stack
		
		jr   $ra		# torna al chiamante
		
		

#=======================================================================================#
# procedura memorizzazione della produzione                                             #
# Parametri:                                                                            #
# $a0 - primo elemento della produzione (simbolo non terminale)                         #
# $a1 - secondo elemento della produzione (simbolo terminale)                           #
# $a2 - terzo elemento della produzione (simbolo non terminale)                         #
#=======================================================================================#
addprod:

		# --
		# -- salva i registri utilizzati nello stack
		# --	
		addi $sp, $sp, -12	# alloca 12 byte nello stack per salvare i registri
		sw   $s0, 8($sp)	# nei primi 4 byte memorizza il valore del registro $s0
		sw   $s1, 4($sp)	# nei secondi 4 byte il valore di $s1
		sw   $s2, 0($sp)	# nei restanti 4 byte il valore di $s2
		

		# --
		# -- Salva i parametri di input nei registri $s0, $s1, $s2
		# --
		move $s0, $a0		# primo parametro in $s0
		move $s1, $a1		# secondo parametro in $s1
		move $s2, $a2		# terzo parametro in $s2

		# --
		# -- Alloca dinamicamente 16 byte in memoria
		# --
		li $v0, 9		# codice per allocare memoria ($a0 = ammount, $v0 = address)
		li $a0, 16		# $a0 = numero di byte da allocare
		syscall                 # chiamata sbrk: restituisce un blocco di 16 byte, puntato da v0: il nuovo record

		# --
		# -- Se la variabile TESTA è zero, è la prima allocazione di memoria
		# --
		lw $t1, TESTA		 # carica in $t1 il valore contenuto nella variabile TESTA
		bne $t1, $zero, nonprimo # se non è il primo elemento salta a nonprimo
		
primo:		
		# --
		# -- Alla prima invocazione TESTA = CODA
		# --
		sw $v0, TESTA		# è il primo elemento, memorizza in TESTA l'indirizzo di partenza
		sw $v0, CODA		# è il primo elemento, CODA = TESTA
		j store


nonprimo:	
		# --
		# -- Successive invocazioni, collega l'elemento precedente con il successivo
		# --
		lw $t2, CODA		# carica in $t2 l'indirizzo di CODA
		sw $v0, 12($t2)		# collega l'elemento precedente con il successivo
		sw $v0, CODA		# sposta il puntatore della CODA sul nuovo indirizzo
		


store:		
		# --
		# -- Salva i valori nella lista
		# --
		sw $s0, 0($v0)		# salva il primo parametro nei primi 4 byte
		sw $s1, 4($v0)		# salva il secondo parametro nei 4 byte successivi
		sw $s2, 8($v0)		# salva il terzo parametro nei 4 byte successivi
		sw $zero, 12($v0)	# salva nil = 0 nei restanti 4 byte
		
							

exitaddprod:	
		# --
		# -- ripristina i registri, libera lo stack ed esce dalla procedura
		# --
		lw   $s0, 8($sp)	# ripristina il registro $s0
		lw   $s1, 4($sp)	# ripristina il registro $s1
		lw   $s2, 0($sp)	# ripristina il registro $s2	
		addi $sp, $sp, 12	# libera lo stack

		jr   $ra		# torna al chiamante
		
		
#=======================================================================================#
# controlla se la grammatica inserita è corretta                                        #
#                                                                                       #
# valoro di ritorno:                                                                    #
# $v0 = 0 grammatica OK, altrimenti 1                                                   # 
#=======================================================================================#
check:

		.data
msgcheckerr:	.asciiz " --> **** Errore: produzione mancante"

		.text

		# --
		# -- Verifica che la llista sia stata inizializzata, altrimenti esce.
		# --
		lw $t0, TESTA		# carica in $t0 il valore contenuto in TESTA (indirizzo della lista)
		move $t3, $zero		# $t3 = 0 Flag che indica se ci sono errori

		beq $t0, $zero, exitCheck # esce se la lista non è stata inizializzata

		# --
		# -- Ciclo di lettura della lista
		# --
loop1:		
		lw $a0, CHR_LF		# $a0 = CHR_LF (codice ascii del carattere "LINE FEED")
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console
					
		lw $a0, 0($t0)		# carica in $a0 il primo elemento della produzione
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console
		
		li $a0, 58		# $a0 = 58 (codice ascii del carattere ":")
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console

		lw $a0, 4($t0)		# carica in $a0 il secondo elemento della produzione
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console

		li $a0, 44		# $a0 = 44 (codice ascii del carattere ",")
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console

		lw $a0, 8($t0)		# carica in $a0 il terzo elemento della produzione
		li $v0, 11		# codice per la stampa di un carattere
		syscall			# stampa un carattere nella console

		lw $t1, CHR_Z
		beq $a0, $t1, next      # se lultimo elemento della tripla è Z passa alla successiva
		
		# --
		# -- verifica se per il terzo carattare della tripla (NT,t,NT) esiste una produzione
		# --
		
		lw  $t1, TESTA			
loop2:		lw  $t2, 0($t1)		# carica in $t2 il simbolo non terinale (primo elemento della tripla)
		
		beq $a0, $t2, next      # se $a0=$t2 la produzione è stata trovata passa al successivo elemento


		lw  $t1, 12($t1)	# puntatore all'elemento successivo			
		bne $t1, $zero, loop2	# itera fino a quando non trova nil (0)
		
		li  $t3, 1		# non è stata trovata la produzione. Alza il flag di errore

		la  $a0, msgcheckerr 			
		li  $v0, 4      				
		syscall 		# stampa il messaggio di errore 
		
		# --
		

next:		lw $t0, 12($t0)		# puntatore all'elemento successivo			
		bne $t0, $zero, loop1	# itera fino a quando non trova nil (0)

exitCheck:	
		# --
		# -- Imposta il valore di ritorno ed esce
		# --
		move $v0, $t3		# imposta il valore di ritorno
		jr   $ra		# torna al chiamante


#=======================================================================================#
# procedura prossimi stati. Restituisce il puntatore a una lista con tutti i possibili  #
# stati raggiungibili dalla coppia (NT, t) specificati                                  #
#                                                                                       #
# parametri:                                                                            #
# $a0 - stato di partenza (NT)                                                          #
# $a1 - simbolo terminale                                                               #
#                                                                                       #
# valoro di ritorno:                                                                    #
# $v0 = puntatore alla lista degli stati raggiungibili                                  #
# $v1 = coda della lista                                                                #
#=======================================================================================#
prossimi_stati:
		# --
		# -- salva i registri utilizzati nello stack
		# --	
		addi $sp, $sp, -12	# alloca 12 byte nello stack per salvare i registri
		sw   $s0, 8($sp)	# nei primi 4 byte il valore di $s0
		sw   $s1, 4($sp)	# nei secondi 4 byte il valore di $s1
		sw   $ra, 0($sp)	# nei restanti il registro $ra
		

		# --
		# -- salva i parametri di input nei registri $s0 e $s1
		# --		
		move $s0, $a0		# primo parametro in $s0
		move $s1, $a1		# secondo parametro in $s1

		# --
		# -- resetta i registri $t4 e $t5 utilizzati come puntatori della lista di stati raggiungibili
		# --		
		move $t4, $zero		# testa della lista degli stati raggiungibili
		move $t5, $zero		# coda della lista degli stati raggiungibili
		
		
		# --
		# -- Ciclo per leggere le produzioni dell'automa
		# --			
		lw  $t0, TESTA			
loop3:		lw  $t1, 0($t0)		# carica in $t1 il primo elemento della tripla
		lw  $t2, 4($t0)		# carica in $t2 il secondo elemento della tripla
		lw  $t3, 8($t0)		# carica in $t3 il terzo elemento della tripla

		# --
		# -- Se i dati letti dall'automa sono diversi da quelli passati alla procedura passa al successivo elemento
		# --			
		bne $s0, $t1, next3	# il primo carattere è diverso da quello passato, passa alla successiva tripla
		bne $s1, $t2, next3	# il secondo carattere è diverso da quello passato, passa alla successiva tripla
		
		# --
		# -- Stato raggiungibile. Memorizza lo stato nella lista di appoggio
		# --
		li $v0 9
		li $a0 8
		syscall                 # chiamata sbrk: restituisce un blocco di 8 byte, puntato da v0: il nuovo record
		
		bne $t4, $zero, _nonprimo # se non è il primo elemento salta a nonprimo
		
_primo:		move $t4, $v0		# è il primo elemento, memorizza in $t4 l'indirizzo di partenza (testo)
		move $t5, $v0		# è il primo elemento, $t4 = $t5 (coda = testa)
		j _store

_nonprimo:		
		sw   $v0, 4($t5)	# collega l'elemento precedente con il successivo
		move $t5, $v0		# sposta il puntatore della coda sul nuovo indirizzo

_store:		sw $t3, 0($v0)		# salva il valore inserito nei primi 4 byte
		sw $zero, 4($v0)	# salva nil = 0 nei restanti 4 byte	
		# --
	

next3:		lw  $t0, 12($t0)	# puntatore all'elemento successivo			
		bne $t0, $zero, loop3	# itera fino a quando non trova nil (0)
		

exitprossimi_stati:	
		# --
		# -- imposta i valori di ritorno
		# --
		move $v0, $t4		# mette in $v0 il puntatore alla lista di stati raggiungibili
		move $v1, $t5		# mette in $v1 l'indirizzo della coda della lista
		

		# --
		# -- ripristina i registri, libera lo stack ed esce dalla procedura
		# --	
		lw   $s0, 8($sp)	# ripristina il registro $s0
		lw   $s1, 4($sp)	# ripristina il registro $s1
		lw   $ra, 0($sp)	# ripristina il registro $ra
		addi $sp, $sp, 12	# libera lo stack
		
		jr   $ra		# torna al chiamante


#=======================================================================================#
# procedura riconoscimento di parole		                                        #
#=======================================================================================#

# $s0: assioma
# $s1: testa della lista
# $s2: coda  della lista
# $s3: puntatore al prossimo carattere della parola
# $s4: carattere della parola letto

riconoscimento:
		.data
msgtitle2:	.asciiz "\n\nriconoscimento di parole:\n-------------------------\n\n"
msginsert:	.asciiz "\nInserisci la parola: "
msgnogramm:	.asciiz "\nNessuna grammatica presente. Inserire una grammatica.\n"
msgricerr:	.asciiz "\n**** Errore: la parola inserita non appartiene alla grammatica.\n"
msgricok:	.asciiz "\nOK. La parola inserita appartiene alla grammatica.\n"
parola:		.space 64		#64 byte per la string di input (compresi i caratteri \n\0 finali)

		.text

		# --
		# -- Salva i registri nello stack
		# --
		addi $sp, $sp, -24	# alloca 24 byte nello stack per salvare i registri		
		sw   $s0, 20($sp)	# salva il registro $s0
		sw   $s1, 16($sp)	# salva il registro $s1
		sw   $s2, 12($sp)	# salva il registro $s2
		sw   $s3,  8($sp)	# salva il registro $s3
		sw   $s4,  4($sp)	# salva il registro $s4
		sw   $ra,  0($sp)	# salva il registro $ra


		# --
		# -- Stampa il titolo
		# --
		la $a0, msgtitle2	# metto nel registro $a0 il puntatore alla stringa msgtitle2
		li $v0, 4		# codice di stampa per le stringhe di caratteri
		syscall			# stampa il titolo della procedura (msgtitle2)
		

		# --
		# -- controlla se è stata inserita la grammatica
		# -- 
		lw  $t0, TESTA		# $t0 = TESTA
		bne $t0, $zero, insword	# se TESTA != 0, la  grammatica è stata inserita, prosegue.
		
		# --
		# -- non è stata inserita la grammatica. Stampa il messaggio ed esce
		# --		
		la $a0, msgnogramm 	# metto nel registro $a0 il puntatore alla stringa msgnogramm
		li $v0, 4      		# codice di stampa per le stringhe di caratteri
		syscall 		# stampa la stringa
		j exitriconoscimento	# esce dalla procedura poichè non è stata inserita alcuna grammatica
		

		# --
		# -- richiede l'inserimento di una parola
		# -- 
insword:	la $a0, msginsert 	# metto nel registro $a0 il puntatore alla stringa msginsert
		li $v0, 4      		# codice di stampa per le stringhe di caratteri
		syscall 		# stampa la stringa

		li $v0, 8      		# codice per leggere una stringa arguments: $a0=buffer, $a1=length
		la $a0, parola		# metto in $a0 il puntatore alla locazione di memoria di parola
		li $a1, 64		# $a1 = lunghezza della stringa di input (in questo caso 64 byte)
		syscall
		
		# --
		# -- recupera l'assioma (simbolo non terminale iniziale)
		# --
		lw $t0, TESTA		# mette in $t0 il puntatore della variabile  TESTA
		lw $s0, 0($t0)		# mette in $s0 il primo simbolo non terminale

		# --
		# -- ripulisce i registri $s0, $s1
		# --
		move $s1, $zero		# testa della lista degli stati raggiungibili
		move $s2, $zero		# coda  della lista degli stati raggiungibili

	
		# --
		# -- scorre la stringa carattere per carattere
		# --
		move $s4, $zero		# pulisce il registro $s4
		la   $s3, parola	# mette in $s3 l'indirizzo di base della parola
loopChar:		

		# --
		# -- Ignora gli spazi nella parola
		# --		
		lb  $s4, 0($s3)		# carica in $s4 un carattere della parola
		lw  $t3, CHR_SP		# $t2 = CHR_SP  (codice ascii del carattere SPACE)
		beq $s4, $t3, nextChar	# se il carattere è uno spazio passa al successivo		


		# --
		# -- questa porzione di codice viene eseguita solo per il primo carattere della parola, ovvero se $s1 = $zero
		# --
		bne  $s1, $zero, np	  # non è il primo carattere della parola, salta a nonprimo
		move $a0, $s0		  # $a0 = $s0 (parametro per la procedura prossimi_stati)
		move $a1, $s4		  # $a1 = $s4 (parametro per la procedura prossimi_stati)
		jal  prossimi_stati	  # richiama la procedura prossimi_stati
		beq  $v0, $zero, riconerr # se la procedura non ritorna alcun risultato esce con errore
		move $s1, $v0		  # $s1 = $v0 salva in $s1 l'indirizzo della TESTA della lista
		move $s2, $v1		  # $s2 = $v1 salva in $s2 l'indirizzo della CODA della lista	
		j nextChar
		# --
		

np:		# -- 
		# -- prepara i registri di appoggio
		# --		
		li   $t1, 0		# testa della lista temporanea di stati
		li   $t2, 0		# coda della lista temporanea di stati
		move $t0, $s1		# $t0 = $s1 puntatore all'elemento della lista  degli stati
		
loopStato:		

		# -- 
		# -- salva i registro $t0, $t1, $t2 nello stach frame
		# --
		addi $sp, $sp, -12	# alloca 12 byte nello stack per salvare i registri		
		sw   $t0, 0($sp)	# salva il registro $t0		
		sw   $t1, 4($sp)	# salva il registro $t1		
		sw   $t2, 8($sp)	# salva il registro $t2		

		# -- 
		# -- recupera gli stati raggiungibili dalla coppia (NT, t)
		# --		
		lw   $a0, 0($t0)	# carica in $a0 il simbolo non terinale (paramentro per la procedura prossimi_stati)
		move $a1, $s4		# $a1 = $s4 (parametro per la procedura prossimi_stati)
		jal  prossimi_stati	# richiama la procedura prossimi_stati

		# -- 
		# -- ripristina i registri salvati nello stack
		# --		
		lw   $t0,  0($sp)	# ripristina il registro $t0	
		lw   $t1,  4($sp)	# ripristina il registro $t1	
		lw   $t2,  8($sp)	# ripristina il registro $t2	
		addi $sp, $sp, 12	# libera lo stack
		
		# -- 
		# -- Non sono stati trovati stati raggiungibili dalla coppia (NT, t)
		# --		
		beq  $v0, $zero, nextStato  # se la procedura non ritorna alcun risultato passa all'elemento successivo
		

		# -- 
		# -- Sono stati trovati stati raggiungibili dalla coppia (NT, t)
		# -- 
		bne  $t1, $zero, np2	    # se la lista temporanea è vuota (primo elemento) salta a np2
		move $t1, $v0		    # $t1 = $v0 salva in $t1 l'indirizzo della TESTA della lista
		move $t2, $v1		    # $t2 = $v1 salva in $t2 l'indirizzo della CODA della lista	
		j    nextStato
		
		
np2:				
		# -- 
		# -- Collega la lista con la precedente
		# -- 
		sw   $v0, 4($t2)	# collega l'elemento precedente con il successivo				
		move $t2, $v1		# $t2 = $v1 salva in $t2 l'indirizzo della CODA della lista	


		# -- 
		# -- itera fino a quando non raggiunge la fine della lista
		# --			
nextStato:	lw   $t0, 4($t0)		# puntatore all'elemento successivo			
		bne  $t0, $zero, loopStato	# itera fino a quando non trova nil (0)


		beq  $t1, $zero, riconerr 	# la lista degli stati è vuota, esce con errore
		
		# --
		# -- la lista ottenuta dall'unione delle singole lista diventa la nuova lista degli stati
		# --
		move $s1, $t1			# $s1 = $t1 TESTA della lista
		move $s2, $t2			# $s2 = $t2 CODA della lista
		
		# --
		# -- passa al prossimo carattere della parola
		# --	
nextChar:	addi $s3, $s3, 1		# incrementa il puntatore della stringa
		lb   $s4, 0($s3)		# carica in $s4 il carattere successivo
		lw   $t3, CHR_LF		# carica in $t3 il codice ascii line_feed
		bne  $s4, $t3, loopChar    	# se non è stata raggiunta la fine della stringa itera
						

		# --
		# -- E' stata valutata tutta la parola, se la lista è vuota esce con errore
		# --
		beq  $s1, $zero, riconerr 	# la lista degli stati è vuota, esce con errore
			

		# --
		# -- controlla se la lista contiene il simbolo terminale Z
		# --
		move $t0, $s1			# $t0 = $s1 puntatore all'elemento della lista
		lw   $t2, CHR_Z			# $t2 = CHR_Z  (codice ascii Z)

loopCheck:		
		lw  $t1, 0($t0)			# carica in $t1 il simbolo non terminale
		beq $t1, $t2, riconok		# ha trovato il simbolo Z. La parola è stata riconosciuta

		lw  $t0, 4($t0)			# puntatore all'elemento successivo			
		bne $t0, $zero, loopCheck	# itera fino a quando non trova nil (0)
		j   riconerr			# non ha trovato Z, esce con errore

		
		# --
		# -- paraola riconosciuta. Stampa il messaggio ed esce
		# --
riconok:			
		la $a0, msgricok		# metto nel registro $a0 il puntatore alla stringa msgricok
		li $v0, 4			# codice di stampa per le stringhe di caratteri
		syscall				# stampa la stringa		
		j exitriconoscimento
		

		# --
		# -- paraola non riconosciuta. Stampa il messaggio ed esce
		# --
riconerr:			
		la $a0, msgricerr		# metto nel registro $a0 il puntatore alla stringa msgricerr
		li $v0, 4			# codice di stampa per le stringhe di caratteri
		syscall				# stampa la stringa


		# --
		# -- ripristina i registri e torna al chiamante
		# --
exitriconoscimento:	
		lw   $s0, 20($sp)	# ripristina il registro $s0
		lw   $s1, 16($sp)	# ripristina il registro $s1
		lw   $s2, 12($sp)	# ripristina il registro $s2
		lw   $s2,  8($sp)	# ripristina il registro $s3
		lw   $s2,  4($sp)	# ripristina il registro $s4		
		lw   $ra,  0($sp)	# ripristina il registro $ra
		
		addi $sp, $sp, 24	# libera lo stack
		jr   $ra		# torna al chiamante



