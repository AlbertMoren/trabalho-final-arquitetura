.data
  msg_pedir_int: .asciiz "Digite um número inteiro: "   
  msg_exibir_int: .asciiz "Voce digitou: "
  espaco: .asciiz " "
  ArrayInt: .space 8
.text
.global main

main:
  li $v0, 4 # codigo de serviço para imprimir string
  la $a0, msg_pedir_int
  syscall
  li $v0, 5 #codigo de serviço para ler inteiro
  syscall
  move $t0, $v0
  
  li $v0, 4 # codigo de serviço para imprimir string
  la $a0, msg_pedir_int
  syscall
  li $v0, 5 #codigo de serviço para ler inteiro
  syscall
  move $t1, $v0
  
  #exibir o valor recebido
  li $v0, 4
  la $a0, msg_exibir_int
  
  li $v0, 1
  move $a0, $t0
  syscall
  
   #exibir o valor recebido
  li $v0, 4
  la $a0, msg_exibir_int
  
  li $v0, 4 # espaço entre as variaveis
  la $a0, espaco
  
  syscall
  li $v0, 1
  move $a0, $t1
  syscall
  
  li $v0, 10
  syscall