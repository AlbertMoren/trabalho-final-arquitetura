#CODIGO AUXILIAR PARA APRESENTAR ESTRUTURA CONDICIONAL COMPOSTA
.data
	prompt: .asciiz "Cálculo do n-ésimo número de Lucas, insira n: "
	message: .asciiz "Resultado: "
	
.text

.globl main

# --- PONTO DE ENTRADA SEGURO ---
j main      # Salta para a função main (entrada principal do programa)
nop         # Delay slot, boa prática após um salto incondicional
# -----------------------------

#--- Número de Lucas ----------
# Calcula o n-ésimo número de Lucas em O(2^n)
# Serve somente para mostrar recursão e estrutura condicional composta.
# Parametros:
# $a0 = n

lucas:
	addi $sp, $sp, -8 #Reserva 8 bytes na pilha
	sw $ra, 4($sp) #Salva o endereço de retorno na pilha
	sw $a0, 0($sp) #Salva n
	slti $t0, $a0, 2 # Se n < 2, então $t0 = 1
	beq $t0, $zero, if_n_maior_que_2 #Se maior que 2, vai pro primeiro if
	addi $t0, $zero, 1
	beq $a0, $t0, else_if_n_igual_1 # Se menor que 2 e igual a 0, vai pro else_if
	beq $a0, $zero, else # Se não, vai pro else
	
if_n_maior_que_2:
	addi $a0, $a0, -1 # Calculando n-1
	jal lucas # Calculando L(n-1)
	addi $sp, $sp, -4 #Reserva 4 bytes na pilha para salvar Lucas(n-1)
	sw $v0, 0($sp) #Salvando L(n-1) em sp
	
	lw $a0, 4($sp) # Restaura $a0 original
	addi $a0, $a0, -2 # Calculando n-2
	jal lucas # Calculando L(n-2)
	move $t2, $v0 # Salvando L(n-2) em t2
	lw $t3, 0($sp) # Recuperando L(n-1) em sp
	addi $sp, $sp, 4 # Dando a pilha o tamanho original
	
	add $v0, $t2, $t3 # Calculando L(n) = L(n-1) + L(n-2)
	j fim
	
else_if_n_igual_1:

	li $v0, 1 # Calculando L(1) = 1
	j fim
	
else:
	li $v0, 2 # Calculando L(0) = 2
	j fim
fim:
	lw $ra, 4($sp) #Restaurando endereço de retorno
	lw $a0, 0($sp) #Restaurando n
	addi $sp, $sp, 8 
	jr $ra
	nop

main:
	# Apresentando mensagem do prompt
	li $v0, 4
	la $a0, prompt
	syscall
	
	# Pegando o número de entrada
	li $v0, 5
	syscall
	
	# Movendo o valor para parametro da função de Lucas
	move $a0, $v0
	jal lucas
	
	# Apresentando mensagem final
	move $t0, $v0
	li $v0, 4
	la $a0, message
	syscall	
	
	#Imprimindo n-esimo valor de Lucas
	li $v0, 1
	move $a0, $t0
	syscall
	
