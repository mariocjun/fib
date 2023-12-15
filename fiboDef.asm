; ------------------------------------------
; Lista de palavras-chave e registradores em Assembly
; ------------------------------------------

; PALAVRAS-CHAVE
; --------------

; mov: Usada para mover dados entre registradores, da memória para um registrador ou de um registrador para a memória
; inc: Incrementa o valor de um registrador ou local de memória
; dec: Decrementa o valor de um registrador ou local de memória
; cmp: Compara dois valores
; jne: Salta para um label se o último "cmp" não for igual (jump not equal)
; jmp: Salta incondicionalmente para um label (jump)
; ret: Retorna de uma chamada de função
; syscall: Realiza uma chamada ao sistema

; REGISTRADORES
; -------------

; rax: Geralmente usado para armazenar o valor de retorno de uma função
; rcx: Comumente usado como um contador em loops
; rdi: Usado para passar o primeiro argumento a uma função
; rsi: Usado para passar o segundo argumento a uma função
; rdx: Usado para passar o terceiro argumento a uma função
; r8 - r15: Outros registradores gerais disponíveis para armazenar dados

; NOTA
; ----
; SYS_WRITE, SYS_EXIT, STDOUT, SUCCESS, FAILURE são normalmente definidos como constantes em algum lugar no código ou nas bibliotecas incluídas

; ------------------------------------------

;--------------------------------------------;
;             DADOS INICIALIZADOS            ;
;--------------------------------------------;

section .data			; Declara as macros e os dados inicializados

;--------------------------------------------;
;                 CONSTANTES                 ;
;--------------------------------------------;

	SYS_READ equ 0	    ; Sinal de leitura -> input
	SYS_WRITE equ 1	    ; Sinal de escrita -> output
	SYS_EXIT equ 60		; Sinal de saída
	STDOUT equ 0	    ; Sinal de saída pro monitor
	STDIN equ 1         ; Sinal de entrada do teclado
	SUCCESS equ 0	    ; Retorna 0 caso não tenha nenhum erro
	FAILURE equ 1	    ; Retorna 1 caso tenha erro
	NEW_LINE equ 10	    ; Quebra a linha -> ASCII -> '\n'
	EMPTY equ 0         ; Caractere vazio -> ASCII -> NULL

;------------------------------------------------;
;                   STRINGS                     ;
;------------------------------------------------;

    ; Declara uma variável de nome 'pergunta1' como uma sequência de bytes.
    ; Essa variável armazena a string "Digite um inteiro positivo: ".
    pergunta1 db "Digite um inteiro positivo: "

    ; Calcula o tamanho da string 'pergunta1'.
    ; O símbolo "$" representa a posição atual do contador de localização no montador.
    ; Uma subtração entre a posição atual e a posição onde 'pergunta1' começou resulta no comprimento da string.
	tamPergunta1 equ $-pergunta1

	; Outra variável de sequência de bytes é declarada, chamada 'pergunta2'.
	; Essa variável armazena a string "Imprimir os zeros antes dos termos? (1 - sim, 0 - nao): ".
	pergunta2 db "Imprimir os zeros antes dos termos? (1 - sim, 0 - nao): "

    ; De forma semelhante ao 'tamPergunta1', calculamos o tamanho da string 'pergunta2'.
	tamPergunta2 equ $-pergunta2

    ; 'lineP1' é uma variável que armazena a string "Numero " quando declarada como uma sequência de bytes.
	lineP1 db "Numero "

    ; Aqui, calculamos o tamanho da string 'lineP1'.
	tamLineP1 equ $-lineP1

    ; 'lineP2' é outra variável de sequência de bytes, que armazena a string " -> ".
	lineP2 db " -> "

    ; O tamanho da string 'lineP2' é calculado aqui.
	tamLineP2 equ $-lineP2

    ; 'lineP3' é uma variável que contém um caractere de nova linha (NEW_LINE).
	lineP3 db NEW_LINE

    ; O tamanho da string 'lineP3' (que é de 1 byte, o caractere de nova linha) é calculado aqui.
	tamLineP3 equ $-lineP3

    ; Aqui, declaramos uma variável chamada 'zeros' que armazena uma string de 19 zeros.
    ; Esta variável pode ser usada para preencher strings com zeros à esquerda, garantindo que elas possuam 20 dígitos (contando com o algarismo mais significativo que não seja zero).
	zeros db "0000000000000000000"

;--------------------------------------------;
;              VALORES NUMÉRICOS             ;
;--------------------------------------------;

	tamNumero dd 20 ; Tamanho do número do primeiro input
	tamBoolean dd 1	; Tamanho do número do segundo input
	ctrlCont dq 10	; Auxilia a impressão dos zeros antes do contador
	phi dd 1.618034
	raizDe5 dd 2.236068




;--------------------------------------------;
;           DADOS NÃO INICIALIZADOS          ;
;--------------------------------------------;

section .bss			; Declara os dados não inicializados

;--------------------------------------------;
;                   BYTES                    ;
;--------------------------------------------;

    numero resb 20      ; Tamanho máximo de bytes do número a ser salvo
    stringTemp resb 30	; Tamanho máximo de bytes da string a ser salva
    posDigitos resb 8   ; Tamanho de bytes dentro de um registrador, usado para saber qual dígito está usando
	boolean resb 1		; Booleano que decide se o usuário vai imprimir os zeros antes dos termos

;--------------------------------------------;
;                 QUAD-WORD                  ;
;--------------------------------------------;

	digCont resq 1		; Número de digitos do contador
	digTermo resq 1		; Número de digitos do n-ésimo termo




;--------------------------------------------;
;                   CÓDIGO                   ;
;--------------------------------------------;

section .text			; Onde vai o código do programa
    global _start

;--------------------------------------------;
;                   INÍCIO                   ;
;--------------------------------------------;

_start:
	call _perguntas 	 	; Imprime a string da primeira pergunta
    call _atoi            	; Converte o input pra inteiro
	cmp byte [boolean], 1	; Vê se o booleano é verdadeiro
	jne imprimeFibo			; Se não, imprime a sequência de Fibonacci direto
	call _calcDigitosFib	; Calcula o número de digitos do n-ésimo termo
	imprimeFibo:
    call _fibonacci       	; Calcula a sequência e a imprime
    call _sair            	; Sai com valor 0, pois deu certo

;--------------------------------------------;
;					PRINTS                   ;
;--------------------------------------------;

_perguntas:					; Imprime as perguntas e pega os inputs do usuário
	;Imprime a primeira pergunta
    mov rax, SYS_WRITE
    mov rdi, STDOUT
    mov rsi, pergunta1     	; Move a mensagem que deve ser escrita
    mov rdx, tamPergunta1	; Tamanho da mensagem a ser escrita
    syscall

	; Lê uma string do teclado
    mov rax, SYS_READ     	; Atribuindo o valor da constante SYS_READ para o registrador rax
    mov rdi, STDIN        	; Registra que a leitura deve ser do teclado
    mov rsi, numero       	; Move a leitura para a variavel numero
    mov rdx, tamNumero   	; Define o tamanho do input, definido nas constantes
    syscall

	mov r8, rsi				; Salva o endereço do primeiro caractere do número inserido pelo usuário

	; Imprime a segunda pergunta
    mov rax, SYS_WRITE	  
    mov rdi, STDOUT       
    mov rsi, pergunta2     	; Move a mensagem que deve ser escrita para rsi
    mov rdx, tamPergunta2	; Move o tamanho da mensagem para rdx
    syscall

	; Lê uma string do teclado
    mov rax, SYS_READ     	; Registra que queremos ler
    mov rdi, STDIN        	; Registra que a leitura deve ser do teclado
    mov rsi, boolean       	; Move a leitura para a variavel boolean
    mov rdx, tamBoolean   	; Define o tamanho do input, definido nas constantes
    syscall

	mov r9b, byte [rsi]		; Converte o caractere so segundo input do usuário para double-word
	cmp r9b, 48				; Verifica se o caractere inserido é '0'
	je skip					; Se sim, pula a próxima verificação
	cmp r9b, 49				; Verifica se o caractere inserido é '1'
	jne _erro				; Se não, o programa encerra e retorna erro
	skip:
	sub r9b, 48				; Converte de ASCII para decimal
	mov byte [boolean], r9b	; Salva o booleano em r9d na memória	

	mov rsi, r8				; Retorna o endereço do número digitado pelo usuário para rsi
	ret

_printLinha:              	; Vai imprimir a linha de cada um dos termos
	;Imprime "Numero "
	mov rax, SYS_WRITE  	; Registra que queremos escrever
	mov rdi, STDOUT     	; Registra que a escrita deve ser na tela
	mov rsi, lineP1     	; Move a string lineP1 para rsi e ser impressa na tela
	mov rdx, tamLineP1		; Move o tamanho da string lineP1 para rdx (número de caracteres a ser impresso)
	syscall					; Chama o kernel e executa as operações acima

	;Imprime o contador
	call _printZerosCont	; Imprime alguns '0' antes do contador
	mov rax, r12          	; Move r12 para rax, pois o valor em rax é impresso pelo itoa
	call _itoa				; Converte de int para string para depois ser impressa
	
	;Imprime " -> "
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, lineP2       	; Move a string lineP2 para rsi e ser impressa na tela
	mov rdx, tamLineP2    	; Move o tamanho da string lineP2 para rdx
	syscall

	;Imprime o termo atual
	cmp byte [boolean], 1	; Verifica se o booleano é verdadeiro
	jne continua			; Se não, pula a impressão dos zeros antes do termo
	call _printZerosTermo	; Imprime os zeros antes do termo
	continua:
	mov rax, r13			; Move r13 (termo) para rax e depois ser impresso
	call _itoa				; Converte de int para string para depois ser impressa

	;Quebra a linha
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, lineP3       	; Move a string lineP3 para rsi e ser impressa na tela
	mov rdx, tamLineP3    	; Move o tamanho da string lineP3 para rdx
	syscall
	ret

_printZerosCont:					; Subrotina que imprime os zeros antes do contador
	cmp r12, qword [ctrlCont]		; Compara o n atual com o controlador
	jne pular						; Se não for igual a 10, 100, ..., pula o processo
	mov r10, qword [digCont]		; Copia o número de digitos faltando para r10
	mov r11, qword [ctrlCont]		; Copia o controlador para r11
	imul r11, 10					; Multiplica o controlador por 10 (Aumenta um digito)
	mov qword [ctrlCont], r11		; Salva o controlador de volta na memória
	dec r10							; Diminui o número de digitos faltando
	mov qword [digCont], r10		; Salva o número de digitos faltando de volta na memória

	pular:
	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, zeros				; String composta só por '0' para ser impressa
	mov rdx, qword [digCont]	; O número de '0' a serem impressos
	syscall

	ret

_printZerosTermo:				; Subrotina que imprime os zeros antes do termo
	mov rbx, 10					; Divisor = 10 (calcula n. de digitos)
	mov r10, qword [digTermo]	; Quantidade de '0' a serem impressos
	mov rax, r13				; Copia r13 para rax para conservar o termo atual

	calcularZeros:
	xor rdx, rdx				; Zera rdx 
	div rbx						; Divide o valor em rax por rbx (rax = rax / 10)
	dec r10						; Diminui a quantidade de '0' a serem impressos
	cmp rax, 0					; Vê se os digitos acabaram
	jg calcularZeros			; Se não, retorna para o começo do loop

	mov rax, SYS_WRITE
	mov rdi, STDOUT
	mov rsi, zeros				; String totalmente composta por '0'
	mov rdx, r10				; Número de caracteres a serem impressos
	syscall
	ret

;--------------------------------------------;
;                  CÁLCULOS                  ;
;--------------------------------------------;

_fibonacci:
	mov r8d, eax		; Backup -> copia eax para r8d
						; r12, r13, r14 e r15 foram usados pois são não-voláteis
	mov r12, 0         	; Contador  de 1 até n, ele vai ser impresso em cada linha
	mov r13, 0         	; Termo 1 -> É o termo que é impresso
	mov r14, 0         	; Termo 2 -> É o termo auxiliar
	mov r15, 1         	; Backup -> Auxilia no cálculo do próximo termo

	calcTermo2:
    cmp r8d, 0		    ; Compara r8d (iterador) com 0
    jle finalizar	    ; Se for menor ou igual a 0 encerra o programa
	dec r8d			    ; Decrementa o iterador
	inc r12             ; Incrementa o contador
	call _printLinha	; Imprime a linha do termo x
	add r13, r15        ; Calcula o próximo termo
    mov r15, r14        ; Troca os termos
    mov r14, r13		; Troca os termos
    jmp calcTermo2	    ; Volta para o começo do loop

	finalizar:
	ret

_calcDigitosFib:				; Calcula o número de digitos do n-ésimo termo
	mov r8d, eax		  		; r8d -> iterador 
	mov ecx, eax				; Salva o número digitado pelo usuário em ecx
	mov r13, 0            		; Termo 1 -> É o termo que é impresso
	mov r14, 0            		; Termo 2 -> É o termo auxiliar
	mov r15, 1           		; Backup -> Auxilia no cálculo do próximo termo

	calcTermo1:
    cmp r8d, 0		      		; Compara r8d (iterador) com 0
    jle parte2		      		; Se for menor ou igual a 0 encerra o programa
	dec r8d			      		; Decrementa o iterador
    add r13, r15          		; Calcula o próximo termo
    mov r15, r14          		; Troca os termos
    mov r14, r13		  		; Troca os termos
    jmp calcTermo1				; Volta para o começo do loop

	parte2:						; Segunda parte da subrotina
	mov rax, r15				; Copia o n-ésimo para rax
	mov rbx, 10					; Divisor = 10 ("pega" os digitos)
	mov r8, 0					; r8 conta o número de digitos

	loopCalc:					; Faz as divisões para calcular o número de digitos
	xor rdx, rdx				; Zera rdx pois o resto é concatenado nesse registrador
	div rbx						; rax = rax / rbx
	inc r8						; Incrementa r8
	cmp rax, 0					; Vê se a quantidade de digitos acabou (compara rax com 0)
	jg loopCalc					; Se não, volta para o início do loop

	mov qword [digTermo], r8	; Salva o número de digitos na memória
	mov eax, ecx				; Retorna o input do usuário ao eax
	ret

;--------------------------------------------;
;                 CONVERSÕES                 ;
;--------------------------------------------;

_atoi:                   		; Converte uma string de inteiros para seu valor em inteiro
	xor edi, edi			 	; Zera edi
	mov rbx, -1					; rbx vai armazenar temporariamente o número de digitos

	atoiConverter:     			; Loop a ser executado até ter a string toda convertida
	movzx r8d, byte [rsi]		; Converte o primeiro caractere da string de byte pra double-word
	inc rsi				 		; Incrementa o índice, para avançar na string
	cmp r8d, 47			 		; Vê se um caractere é "menor" que '0'
	jle _erro			 		; Se sim, retorna erro
	cmp r8d, 58			 		; Vê se um caractere é "maior" que '9'
	jge _erro			 		; Se sim, retorna erro
	inc rbx						; Conta o número de digitos
	sub r8d, 48			 		; Converte o caractere da posição para seu correspondente ASCII [48,57] -> [0,9]
	imul edi, 10		 		; edi = edi * 10 ("Empurra" os algorismos para a esquerda)
	add edi, r8d		 		; edi = edi + r8d
	cmp byte [rsi], 10	  		; Compara o caractere atual com '\n', pois o último caractere capturado é o enter
	jne atoiConverter			; Se não forem iguais volta para loop1

	mov qword [digCont], rbx	; Salva o número de digitos na memória
	mov eax, edi		  		; Move edi para eax
	ret

_itoa:                    	; Converte um inteiro para stringg
    mov rcx, stringTemp		; Registra a string que vai guardar o inteiro convertido
	mov rbx, EMPTY        	; Move o ASCII de NULL (caractere vazio) para rbx
	mov [rcx], rbx        	; Atribui rbx (caractere vazio) ao final da string
	inc rcx               	; Incrementa rcx -> próximo caractere
    mov [posDigitos], rcx	; Define qual a próxima posição da string a ser verificada

	itoaConverter:			; Loop que calcula e converte a string, porém invertida
    xor rdx, rdx          	; Como rdx é concatenado na divisão, zeramos ele
    mov rbx, 10           	; Valor a dividir rax
    div rbx               	; Divide rax por rbx
    push rax              	; Salva o valor de rax
    add rdx, 48           	; Adiciona 48 para converter o último dígito para caractere
    mov rcx, [posDigitos] 	; Incrementa (altera) a posição da string a ser calculada
    mov [rcx], dl         	; Carrega o caractere novo
    inc rcx               	; Incrementa a posição
    mov [posDigitos], rcx	; Altera a posição da string a ser calculada
    pop rax               	; Obtém o valor de rax do push anterior
    cmp rax, 0            	; Compara rax com 0
    jne itoaConverter     	; Volta ao loop caso não seja igual a 0
    jmp itoaPrint        	; Caso seja, vá para o loop 2
 
	itoaPrint:              ; Loop que arruma a string para a ordem correta e a imprime
    mov rcx, [posDigitos] 	; Registra a posiçao da string para alterar 
    mov rax, SYS_WRITE    	; Registra que queremos escrever 
    mov rdi, STDOUT       	; Registra que a escrita deverá ser na tela
    mov rsi, rcx          	; Move a string para ser escrita
    mov rdx, 1            	; Tamanho 1 (Só 1 caractere)
    syscall               
    mov rcx, [posDigitos] 	; Registra a posição a ser alterada
    dec rcx               	; Decrementa a posição 
    mov [posDigitos], rcx	; Move ao contrário para imprimir os números
    cmp rcx, stringTemp   	; Compara a posição atual com o começo da string
    jge itoaPrint        	; Se não tiver terminado, repete o loop

    ret

;--------------------------------------------;
;                   SAÍDAS                   ;
;--------------------------------------------;

_sair:                    ; Executa os códigos de sucesso e finaliza o programa
    mov rax, SYS_EXIT     ; Registra que o programa deve ser encerrado
    mov rdi, SUCCESS      ; O código de retorno deve ser 0, pois houve sucesso
    syscall

_erro:                 	; Executa os códigos de erro e finaliza o programa
	mov rax, SYS_EXIT	; Registra que o programa deve ser encerrado
	mov rdi, FAILURE    ; O código de retorno deve ser 1, pois houve erro
	syscall
