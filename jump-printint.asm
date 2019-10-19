.data
printbuf: #输出的缓冲区 共12字节
    .space 12
newline:
    .asciiz "\n"
    .set noreorder

.text
.global main
main:
    li $a0, 1234
    jal printint
    nop
    
    jal printline
    nop

    li $v0, 4001
    syscall
	nop


.global printint #only positive 用到$s0/1/2/3调用时压栈保存
printint:
    addi $sp, $sp, -16 #保存$s0/1/2/3 无递归调用不保存$ra
    sw  $s3, 12($sp)
    sw  $s2, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp) 

    la $s3, printbuf
    sw $zero, 0($s3)
    sw $zero, 4($s3)
    sw $zero, 8($s3)   #memset( buf, 0, sizeof(buf));

    li $s0, 0 # remainder
    li $s1, 1 # quotient
    li $s2, 0 # significant_bit

    beq $s1, $zero, done1 #if(quotient == 0) done
    nop
while1:  
    addi $t0, $zero, 10  # $t0 = 10
    div		$a0, $t0	# $a0 / 10 
    mflo	$s1		# $s1 = floor($a0 / 10) 
    mfhi	$s0		# $s0 = $a0 mod 10 
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    addi $s0, $s0, 48 # $s0 = remainder += '0'
    sb $s0, 0($t1) # buf[ significant_bit ] = remainder + '0'
    addi $s2, $s2, 1 # significant_bit ++
    move $a0, $s1 # a /= 10
    bne  $s1, $zero, while1
    nop
done1:
while2:
    addi $s2, $s2, -1  # significant_bit--
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    li $v0, 4004
    li $a0, 1
    move $a1, $t1 
    li $a2, 1
    syscall
    bne $s2, $zero, while2
    nop
done2:
    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    lw  $s2, 8($sp)
    lw  $s3, 12($sp)
    addi $sp, $sp, 16    #恢复现场
    jr $ra
    nop


.global printline #输出一个空行
printline:
    li $v0, 4004
    li $a0, 1
    la $a1, newline
    li $a2, 1
    syscall
    jr $ra
    nop
    