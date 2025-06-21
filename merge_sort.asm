.data
meu_array:       .space 200      # Reserva 200 bytes para até 50 inteiros (4 bytes cada)
array_temporario:  .space 200    # Buffer temporário do mesmo tamanho para o merge sort

# Strings para interação com o usuário
prompt_tamanho:  .asciiz "Quantos numeros voce deseja ordenar? "  # Pergunta quantidade de números
prompt_numero:   .asciiz "Digite o numero "                      # Pergunta valor de cada número
prompt_dois_pontos: .asciiz ": "                                 # Dois pontos para formatar entrada
label_antes:     .asciiz "\nArray Original: "                    # Label para imprimir array antes da ordenação
label_depois:    .asciiz "\nArray Ordenado: "                    # Label para imprimir array depois da ordenação
label_soma:      .asciiz "\nA soma dos valores do array e: "     # Label para imprimir soma dos valores
espaco:          .asciiz " "                                     # Espaço para separar números na impressão

.text
.globl main

# --- PONTO DE ENTRADA SEGURO ---
j main      # Salta para a função main (entrada principal do programa)
nop         # Delay slot, boa prática após um salto incondicional
# -----------------------------

# ---------------------------------------------------------------------
# Função: calcular_soma(array, tamanho) -> retorna a soma em $v0
# ---------------------------------------------------------------------
calcular_soma:
    li $v0, 0           # Inicializa soma em $v0 com 0
    li $t0, 0           # Inicializa índice i = 0

loop_soma:
    bge $t0, $a1, fim_loop_soma    # Se i >= tamanho, termina o loop
    sll $t1, $t0, 2                # t1 = i * 4 (offset em bytes), fazemos isso para ir pro endereço do proximo inteiro, já que cada inteiro tem 4 bytes
    add $t2, $a0, $t1              # t2 = endereço base + offset
    #Aqui embaixo podemos usar 0( ) pois $t2 já contém o endereço exato da array que está sendo passada como parametro
    lw  $t3, 0($t2)                # t3 = array[i]
    add $v0, $v0, $t3              # soma += array[i]
    addi $t0, $t0, 1               # i++
    j loop_soma                    # Volta para o início do loop

fim_loop_soma:
    jr $ra                         # Retorna para quem chamou

# ---------------------------------------------------------------------
# Função Principal
# ---------------------------------------------------------------------
main:
    # --- Bloco de Input do Usuário ---
    li $v0, 4                      # Código para imprimir string
    la $a0, prompt_tamanho         # Endereço da string
    syscall                        # Imprime "Quantos numeros voce deseja ordenar?"

    li $v0, 5                      # Código para ler inteiro
    syscall                        # Lê o número digitado
    move $s6, $v0                  # Salva o tamanho do array em $s6

    li $t0, 0                      # Inicializa índice i = 0
    la $t1, meu_array              # t1 = endereço base do array
loop_input:
    bge $t0, $s6, fim_loop_input   # Se i >= tamanho, termina o loop

    li $v0, 4                      # Imprime string
    la $a0, prompt_numero          # "Digite o numero "
    syscall
    li $v0, 1                      # Imprime inteiro
    move $a0, $t0                  # Passa índice i
    addi $a0, $a0, 1               # Mostra i+1 para o usuário
    syscall
    li $v0, 4                      # Imprime string
    la $a0, prompt_dois_pontos     # ": "
    syscall

    li $v0, 5                      # Lê inteiro do usuário
    syscall

    sll $t2, $t0, 2                # t2 = i * 4 (offset)
    add $t3, $t1, $t2              # t3 = endereço base + offset
    sw $v0, 0($t3)                 # Salva valor digitado no array

    addi $t0, $t0, 1               # i++
    j loop_input                   # Repete para o próximo número
fim_loop_input:

    # Imprime o estado inicial do array
    li $v0, 4
    la $a0, label_antes            # "\nArray Original: "
    syscall
    la $a0, meu_array              # Endereço do array
    move $a1, $s6                  # Tamanho do array
    jal imprimir_array             # Chama função para imprimir array

    # --- Prepara a chamada inicial para o Merge Sort ---
    la $a0, meu_array              # Endereço do array
    la $a1, array_temporario       # Endereço do buffer temporário
    li $a2, 0                      # Índice inicial (esquerda)
    move $a3, $s6                  # Índice final (direita)
    addi $a3, $a3, -1              # Ajusta para último índice válido
    jal merge_sort                 # Chama merge_sort

    # Imprime o estado final do array ordenado
    li $v0, 4
    la $a0, label_depois           # "\nArray Ordenado: "
    syscall
    la $a0, meu_array              # Endereço do array
    move $a1, $s6                  # Tamanho do array
    jal imprimir_array             # Chama função para imprimir array

    # Calcula a soma de todos os elementos da array e guarda em $t0
    la $a0, meu_array              # Endereço do array
    move $a1, $s6                  # Tamanho do array
    jal calcular_soma              # Chama calcular_soma

    move $t0, $v0                  # Salva o resultado da soma em $t0

    # Imprime o label "A soma é:"
    li $v0, 4
    la $a0, label_soma             # "\nA soma dos valores do array e: "
    syscall
    
    # Imprime o resultado da soma
    li $v0, 1
    move $a0, $t0
    syscall
    # --- Fim do Bloco Corrigido ---

    # Fim do programa
    li $v0, 10                     # Código para encerrar o programa
    syscall

# ---------------------------------------------------------------------
# Função: merge_sort
# $a0 = Endereço do array
# $a1 = Endereço do buffer temporário
# $a2 = Índice inicial (esquerda)
# $a3 = Índice final (direita)
# ---------------------------------------------------------------------
merge_sort:
    # O passo abaixo é necessário, pois precisamos salvar os parametros anteriores a recursão
    addi $sp, $sp, -24             # Reserva espaço na pilha para salvar registradores que vieram antes da recursão
    sw $ra, 20($sp)                # Salva endereço de retorno na pilha
    sw $s0, 16($sp)                # Salva $s0 na pilha
    sw $s1, 12($sp)                # Salva $s1 na pilha
    sw $s2, 8($sp)                 # Salva $s2 na pilha
    sw $s3, 4($sp)                 # Salva $s3 na pilha

    move $s0, $a0                  # Salva argumentos em registradores salvos
    move $s1, $a1
    move $s2, $a2
    move $s3, $a3

    slt $t0, $s2, $s3              # Calcula o booleano esquerda < direita e guarda o resultado em $t0
    beq $t0, $zero, fim_merge_sort # Se $t0 é 0, então o programa deve terminar
    #Se não
    add $t0, $s2, $s3              # t0 = esquerda + direita
    sra $t0, $t0, 1                # t0 = (esquerda + direita) / 2 (meio)
    sw $t0, 0($sp)                 # Salva meio na pilha em 0($sp)
	
    move $a0, $s0                  # Prepara chamada recursiva para metade esquerda
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    jal merge_sort

    lw $t0, 0($sp)                 # Recupera meio da pilha pelo 0($sp)
    move $a0, $s0                  # Prepara chamada recursiva para metade direita
    move $a1, $s1
    addi $a2, $t0, 1
    move $a3, $s3                  
    jal merge_sort	           # Chamada recursiva de função

    lw $t0, 0($sp)                 # Recupera meio da pilha pelo 0($sp)
    move $a0, $s0                  # Prepara chamada para merge
    move $a1, $s1
    move $a2, $s2
    move $a3, $t0
    addi $sp, $sp, -4              # Reserva espaço para salvar $s3
    sw $s3, 0($sp)
    jal merge
    addi $sp, $sp, 4               # Libera espaço da pilha

fim_merge_sort:
    lw $s3, 4($sp)                 # Restaura registradores salvos antes da chamada recursiva
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    lw $ra, 20($sp)                # Muito necessário restaurar o $ra passado, para que a camada anterior de recursão consiga voltar para o endereço correto
    addi $sp, $sp, 24              # Libera espaço da pilha
    jr $ra                         # Retorna

# ---------------------------------------------------------------------
# Função: merge
# ---------------------------------------------------------------------
merge:
    addi $sp, $sp, -20             # Reserva espaço na pilha
    sw $s0, 16($sp)                # Salva registradores usados
    sw $s1, 12($sp)
    sw $s2, 8($sp)
    sw $s3, 4($sp)
    sw $s4, 0($sp)

    move $t0, $a0                  # t0 = array original
    move $t1, $a1                  # t1 = array temporário
    move $t2, $a2                  # t2 = esquerda
    move $t3, $a3                  # t3 = meio
    lw $t4, 20($sp)                # t4 = direita
    move $t5, $t2                  # t5 = índice de cópia

loop_copia:
    bgt $t5, $t4, fim_copia        # Se t5 > direita, termina cópia
    sll $t6, $t5, 2                # t6 = t5 * 4 (offset)
    add $t7, $t0, $t6              # t7 = endereço original da array a ser ordenada
    lw  $t8, 0($t7)                # Está linha copia o valor que está em $t7 e coloca em t8
    add $t7, $t1, $t6              # t7 agora é o endereço temporário do local do elemento que está sendo copiado na array temporaria/auxiliar
    sw  $t8, 0($t7)                # Salva o valor copiado em $t8 para o endereço correta da array temporaria
    addi $t5, $t5, 1               # Próximo índice
    j loop_copia
fim_copia:
    move $s0, $t2                  # s0 = i = esquerda, indice do lado esquerdo a ser iterado
    addi $s1, $t3, 1               # s1 = j = meio + 1, indice do lado direito a ser iterado
    move $s2, $t2                  # s2 = k = esquerda, indice de todo array a ser iterado

loop_principal:
    bgt $s0, $t3, fim_loop_principal   # Se i > meio, termina
    bgt $s1, $t4, fim_loop_principal   # Se j > direita, termina
    sll $t5, $s0, 2                    # t5 = i * 4
    add $t6, $t1, $t5                  # t6 = endereço temporário[i]
    lw  $s3, 0($t6)                    # s3 = temp[i]
    sll $t5, $s1, 2                    # t5 = j * 4
    add $t6, $t1, $t5                  # t6 = endereço temporário[j]
    lw  $s4, 0($t6)                    # s4 = temp[j]
    bgt $s3, $s4, else_copia_j         # Se temp[i] > temp[j], vai para else
#Estrutura if_else simulada
#if_copia_i
    sll $t5, $s2, 2                    # t5 = k * 4
    add $t6, $t0, $t5                  # t6 = endereço array[k]
    sw  $s3, 0($t6)                    # array[k] = temp[i]
    addi $s0, $s0, 1                   # i++
    j fim_if_merge
else_copia_j:
    sll $t5, $s2, 2                    # t5 = k * 4
    add $t6, $t0, $t5                  # t6 = endereço array[k]
    sw  $s4, 0($t6)                    # array[k] = temp[j]
    addi $s1, $s1, 1                   # j++
fim_if_merge:
    addi $s2, $s2, 1                   # k++
    j loop_principal
fim_loop_principal:
# Aqui fazemos a limpeza do Merge, isto acontece quando um dos lados se esgota e então temos que jogar todos os valores restantes do lado não esgotada na array
loop_limpeza_i:
    bgt $s0, $t3, fim_limpeza_i        # Se i > meio, termina
    sll $t5, $s0, 2                    # t5 = i * 4
    add $t6, $t1, $t5                  # t6 = endereço temp[i]
    lw  $s3, 0($t6)                    # s3 = temp[i]
    sll $t5, $s2, 2                    # t5 = k * 4
    add $t6, $t0, $t5                  # t6 = endereço array[k]
    sw  $s3, 0($t6)                    # array[k] = temp[i]
    addi $s0, $s0, 1                   # i++
    addi $s2, $s2, 1                   # k++
    j loop_limpeza_i
fim_limpeza_i:

loop_limpeza_j:
    bgt $s1, $t4, fim_limpeza_j        # Se j > direita, termina
    sll $t5, $s1, 2                    # t5 = j * 4
    add $t6, $t1, $t5                  # t6 = endereço temp[j]
    lw  $s4, 0($t6)                    # s4 = temp[j]
    sll $t5, $s2, 2                    # t5 = k * 4
    add $t6, $t0, $t5                  # t6 = endereço array[k]
    sw  $s4, 0($t6)                    # array[k] = temp[j]
    addi $s1, $s1, 1                   # j++
    addi $s2, $s2, 1                   # k++
    j loop_limpeza_j
fim_limpeza_j:
    lw $s4, 0($sp)                     # Restaura registradores salvos
    lw $s3, 4($sp)
    lw $s2, 8($sp)
    lw $s1, 12($sp)
    lw $s0, 16($sp)
    addi $sp, $sp, 20                  # Libera espaço da pilha
    jr $ra                             # Retorna

# ---------------------------------------------------------------------
# Função: imprimir_array
# ---------------------------------------------------------------------
imprimir_array:
    move $s0, $a0                  # s0 = endereço do array
    li $t0, 0                      # i = 0
loop_imprimir:
    bge $t0, $a1, fim_loop_imprimir    # Se i >= tamanho, termina
    sll $t1, $t0, 2                    # t1 = i * 4
    add $t2, $s0, $t1                  # t2 = endereço array[i]
    lw  $t3, 0($t2)                    # t3 = array[i]
    li $v0, 1                          # Código para imprimir inteiro
    move $a0, $t3                      # Passa valor para imprimir
    syscall
    li $v0, 4                          # Código para imprimir string
    la $a0, espaco                     # Imprime espaço
    syscall
    addi $t0, $t0, 1                   # i++
    j loop_imprimir
fim_loop_imprimir:
    jr $ra                             # Retorna
