.data
	quebra_linha: .asciiz "\n"
	input_valor: .asciiz "Informe um número: "
	output_valor: .asciiz "o numero digitado foi: "
.text
.global main
main:
	li $t0, 0
	li $t1, 10
	
for_loop_start:
	bge $t0, $t1, for_loop_end #se t0 >= t1, sai do loop
	addi $t0,$t0, 1
	# pedir valor ao usuario
	li $v0, 4
	la $a0, input_valor
	syscall
	# salvando o valor em t2
	li $v0, 5
	syscall
	move $t2, $v0
	# imprimir o valor recebido
	li $v0, 4
	la $a0, output_valor
	syscall
	li $v0, 1
	move $a0, $t2
	syscall
	#quebra de linha
	li $v0, 4
	la $a0, quebra_linha
	syscall
	j for_loop_start
for_loop_end:
	li $v0, 10
	syscall 
