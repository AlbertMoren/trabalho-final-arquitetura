.data
meu_array:       .space 200      # Espaço para até 50 inteiros
array_temporario:  .space 200      # Buffer temporário do mesmo tamanho máximo

# Strings para Interação com o Usuário
prompt_tamanho:  .asciiz "Quantos numeros voce deseja ordenar? "
prompt_numero:   .asciiz "Digite o numero "
prompt_dois_pontos: .asciiz ": "
label_antes:     .asciiz "\nArray Original: "
label_depois:    .asciiz "\nArray Ordenado: "
label_soma:      .asciiz "\nA soma dos valores do array e: "
espaco:          .asciiz " "

.text
.globl main

# --- PONTO DE ENTRADA SEGURO ---
j main      # Salta incondicionalmente para o início da 'main'.
nop         # Instrução de segurança (delay slot), boa prática após um salto.
# -----------------------------

# ---------------------------------------------------------------------
# Função: calcular_soma(array, tamanho) -> retorna a soma em $v0
# ---------------------------------------------------------------------
calcular_soma:
    li $v0, 0           # soma = 0
    li $t0, 0           # i = 0

loop_soma:
    bge $t0, $a1, fim_loop_soma
    sll $t1, $t0, 2
    add $t2, $a0, $t1
    lw  $t3, 0($t2)
    add $v0, $v0, $t3
    addi $t0, $t0, 1
    j loop_soma

fim_loop_soma:
    jr $ra

# ---------------------------------------------------------------------
# Função Principal
# ---------------------------------------------------------------------
main:
    # --- Bloco de Input do Usuário ---
    li $v0, 4
    la $a0, prompt_tamanho
    syscall

    li $v0, 5
    syscall
    move $s6, $v0  # Salva o tamanho do array em $s6

    li $t0, 0
    la $t1, meu_array
loop_input:
    bge $t0, $s6, fim_loop_input

    li $v0, 4
    la $a0, prompt_numero
    syscall
    li $v0, 1
    move $a0, $t0
    addi $a0, $a0, 1
    syscall
    li $v0, 4
    la $a0, prompt_dois_pontos
    syscall

    li $v0, 5
    syscall

    sll $t2, $t0, 2
    add $t3, $t1, $t2
    sw $v0, 0($t3)

    addi $t0, $t0, 1
    j loop_input
fim_loop_input:

    # Imprime o estado inicial
    li $v0, 4
    la $a0, label_antes
    syscall
    la $a0, meu_array
    move $a1, $s6
    jal imprimir_array

    # --- Prepara a chamada inicial para o Merge Sort ---
    la $a0, meu_array
    la $a1, array_temporario
    li $a2, 0
    move $a3, $s6
    addi $a3, $a3, -1
    jal merge_sort

    # Imprime o estado final
    li $v0, 4
    la $a0, label_depois
    syscall
    la $a0, meu_array
    move $a1, $s6
    jal imprimir_array

    # --- Chama função com retorno e imprime o resultado (VERSÃO CORRIGIDA) ---
    la $a0, meu_array
    move $a1, $s6
    jal calcular_soma

    # Salva o resultado de $v0 em um lugar seguro ($t0) IMEDIATAMENTE
    move $t0, $v0

    # Imprime o label "A soma é:"
    li $v0, 4
    la $a0, label_soma
    syscall
    
    # Imprime o resultado que foi salvo em $t0
    li $v0, 1
    move $a0, $t0
    syscall
    # --- Fim do Bloco Corrigido ---

    # Fim do programa
    li $v0, 10
    syscall

# ---------------------------------------------------------------------
# Função: merge_sort
# ---------------------------------------------------------------------
merge_sort:
    addi $sp, $sp, -24
    sw $ra, 20($sp)
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)

    move $s0, $a0
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    slt $t0, $s2, $s3
    beq $t0, $zero, fim_merge_sort

    add $t0, $s2, $s3
    sra $t0, $t0, 1
    sw $t0, 0($sp)

    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    jal merge_sort

    lw $t0, 0($sp)
    move $a0, $s0
    move $a1, $s1
    addi $a2, $t0, 1
    move $a3, $s3
    jal merge_sort

    lw $t0, 0($sp)
    move $a0, $s0
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    addi $sp, $sp, -4
    sw $s3, 0($sp)
    jal merge
    addi $sp, $sp, 4

fim_merge_sort:
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)
    addi $sp, $sp, 24
    jr $ra

# ---------------------------------------------------------------------
# Função: merge
# ---------------------------------------------------------------------
merge:
    addi $sp, $sp, -20
    sw $s0, 16($sp)
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    move $t0, $a0
    move $t1, $a1
    move $t2, $a2
    move $t3, $a3
    lw $t4, 20($sp)
    move $t5, $t2
loop_copia:
    bgt $t5, $t4, fim_copia
    sll $t6, $t5, 2
    add $t7, $t0, $t6
    lw  $t8, 0($t7)
    add $t7, $t1, $t6
    sw  $t8, 0($t7)
    addi $t5, $t5, 1
    j loop_copia
fim_copia:
    move $s0, $t2
    addi $s1, $t3, 1
    move $s2, $t2
loop_principal:
    bgt $s0, $t3, fim_loop_principal
    bgt $s1, $t4, fim_loop_principal
    sll $t5, $s0, 2
    add $t6, $t1, $t5
    lw  $s3, 0($t6)
    sll $t5, $s1, 2
    add $t6, $t1, $t5
    lw  $s4, 0($t6)
    bgt $s3, $s4, else_copia_j
    sll $t5, $s2, 2
    add $t6, $t0, $t5
    sw  $s3, 0($t6)
    addi $s0, $s0, 1
    j fim_if_merge
else_copia_j:
    sll $t5, $s2, 2
    add $t6, $t0, $t5
    sw  $s4, 0($t6)
    addi $s1, $s1, 1
fim_if_merge:
    addi $s2, $s2, 1
    j loop_principal
fim_loop_principal:
loop_limpeza_i:
    bgt $s0, $t3, fim_limpeza_i
    sll $t5, $s0, 2
    add $t6, $t1, $t5
    lw  $s3, 0($t6)
    sll $t5, $s2, 2
    add $t6, $t0, $t5
    sw  $s3, 0($t6)
    addi $s0, $s0, 1
    addi $s2, $s2, 1
    j loop_limpeza_i
fim_limpeza_i:
loop_limpeza_j:
    bgt $s1, $t4, fim_limpeza_j
    sll $t5, $s1, 2
    add $t6, $t1, $t5
    lw  $s4, 0($t6)
    sll $t5, $s2, 2
    add $t6, $t0, $t5
    sw  $s4, 0($t6)
    addi $s1, $s1, 1
    addi $s2, $s2, 1
    j loop_limpeza_j
fim_limpeza_j:
    lw $s4, 0($sp)
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    addi $sp, $sp, 20
    jr $ra

# ---------------------------------------------------------------------
# Função: imprimir_array
# ---------------------------------------------------------------------
imprimir_array:
    move $s0, $a0
    li $t0, 0
loop_imprimir:
    bge $t0, $a1, fim_loop_imprimir
    sll $t1, $t0, 2
    add $t2, $s0, $t1
    lw  $t3, 0($t2)
    li $v0, 1
    move $a0, $t3
    syscall
    li $v0, 4
    la $a0, espaco
    syscall
    addi $t0, $t0, 1
    j loop_imprimir
fim_loop_imprimir:
    jr $ra