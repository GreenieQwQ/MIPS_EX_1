.data
intbuf: #读取的缓冲区
    .space 1
printbuf: #输出的缓冲区 共12字节
    .space 12
array: #开辟数组空间 10 * 4 
    .space 40    
newline:
    .asciiz "\n"
blank:
    .asciiz " "
    .set noreorder

.text
.global main
main:
    la  $s0, array  # $s0 = a
ini_loop_1:    
    add $s1, $zero, $zero # i = 0
    slti $t0, $s1, 10 
    beq $t0, $zero, done_1 # i >= 10 done
    nop
loop_1:
    sll $t0, $s1, 2 # $t0 = i * 4
    add $t1, $s0, $t0  # $t1 = &a[i]
    jal readint
    nop 
    sw  $v0, 0($t1) # a[i] = readint()
    addi $s1, $s1, 1 # i++
    slti $t0, $s1, 10 
    bne $t0, $zero, loop_1 # i < 10 loop
    nop
done_1:
ini_loop_2:
    add $s1, $zero, $zero # i = 0
    slti $t0, $s1, 9 
    beq $t0, $zero, done_2 # i >= 9 done
    nop
loop_2:
ini_loop_3:
    add $s2, $zero, $zero # j = 0
    nor $t3, $s1, $zero # i取反
    addiu $t3, $t3, 1   # $t3 = -i
    addi $t3, $t3, 9    # $t3 = 9 - i
    slt $t0, $s2, $t3   
    beq $t0, $zero, done_3 # j >= 9-i done
    nop
loop_3:
    sll $t4, $s2, 2 # $t4 = j * 4
    add $t4, $s0, $t4  # $t4 = &a[j]
    addi $t5, $s2, 1 # $t5 = j + 1
    sll $t5, $t5, 2 # $t5 = ( j + 1 ) * 4
    add $t5, $s0, $t5  # $t0 = &a[j]
    lw  $t0, 0($t4) # $t0 = a[j]
    lw  $t1, 0($t5) # $t1 = a[j+1] 
if:
    slt $t2, $t0, $t1
    beq $t2, $zero, done_if # a[j] >= a[j+1] done
    move $s3, $t0   # temp = $t0
    move $t0, $t1   # $t0 = $t1
    move $t1, $s3   # $t1 = temp

    sw  $t0, 0($t4) # a[j] = $t0
    sw  $t1, 0($t5) # a[j+1] = $t1
done_if:
    addi $s2, $s2, 1 # j++
    slt $t0, $s2, $t3 # $t3 = 9 - i  
    bne $t0, $zero, loop_3 # j < 9-i loop
    nop
done_3:
    addi $s1, $s1, 1 # i++
    slti $t0, $s1, 10 
    bne $t0, $zero, loop_2 # i < 9 loop
    nop
done_2:
    lw $a0, 0($s0) # $a0 = a[0]
    jal printint
    nop

ini_loop_4:    
    addi $s1, $zero, 1 # i = 1
    slti $t0, $s1, 10 
    beq $t0, $zero, done_4 # i >= 10 done
    nop
loop_4:
    jal printblank
    nop
    sll $t0, $s1, 2 # $t0 = i * 4
    add $t1, $s0, $t0  # $t1 = &a[i]
    lw  $a0, 0($t1) # $a0 = a[i]
    jal printint
    nop 
    addi $s1, $s1, 1 # i++
    slti $t0, $s1, 10 
    bne $t0, $zero, loop_4 # i < 10 loop
    nop
done_4:
    jal printline
    nop
    
    li $v0, 4001
    syscall
	nop




.global readint #用到 $s0/1、$t0 调用时需压栈保存
readint: #去除空格/换行后读取数字直到再次遇见空格换行为止 //仅无符号数字有效 若EOF返回-1
    addi $sp, $sp, -12 #保存 $s0/1、$t0 无递归调用不保存$ra
    sw  $t0, 8($sp)
    sw  $s1, 4($sp)
    sw  $s0, 0($sp) 
ri_while_1:    
    li $v0, 4003 #系统调用read    
    li $a0, 0 #从stdin读取
    la $a1, intbuf
    li $a2, 1
    syscall

    addi $t0, $v0, -1 # $t0 = $v0 - 1
    bne $t0, $zero, ri_EOF #返回值$v0 != 1——非有效输入跳出循环
    nop

    move $t0, $a1 # $t0 = intbuf
    lbu $s0, 0($t0) #$s0 = 读取到的字符
    addi $t0, $zero, 32 #$t0 = ' '
    beq $s0, $t0, ri_while_1
    nop
    addi $t0, $zero, 10 #$t0 = '\n'
    beq $s0, $t0, ri_while_1
    nop
    addi $t0, $zero, 13 #$t0 = '\r'
    beq $s0, $t0, ri_while_1
    nop
    
    add $s1, $zero, $zero # result = 0
ri_while_2:
    addi    $t0, $zero, 10  # $t0 = 10
    mult	$s1, $t0			# $s1 * 10 = Hi and Lo registers
    mflo	$s1				# copy Lo to $s1, result *= 10
    addi    $s0, $s0, -48   # c -= '0'
    add $s1, $s1, $s0   # $s1 += c - '0' 

    li $v0, 4003 #系统调用read    
    li $a0, 0 #从stdin读取
    la $a1, intbuf
    li $a2, 1
    syscall

    addi $t0, $v0, -1 # $t0 = $v0 - 1
    bne $t0, $zero, ri_done #返回值$v0 != 1——EOF跳出循环
    nop

    move $t0, $a1 # $t0 = intbuf
    lbu $s0, 0($t0) #$s0 = 读取到的字符
    addi $t0, $zero, 32 #$t0 = ' '
    beq $s0, $t0, ri_done
    nop
    addi $t0, $zero, 10 #$t0 = '\n'
    beq $s0, $t0, ri_done
    nop
    addi $t0, $zero, 13 #$t0 = '\r'
    beq $s0, $t0, ri_done
    nop
    j   ri_while_2
    nop

ri_done:
    move $v0, $s1   # return result
    j   readint_exit
    nop
ri_EOF:    
    addi $v0, $zero, -1 # $v0 = -1 
readint_exit:       
    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    lw  $t0, 8($sp)
    addi $sp, $sp, 12    #恢复现场
    jr $ra
    nop

.global printint #only positive 用到$s0/1/2/3、$t0/1调用时压栈保存
printint:
    addi $sp, $sp, -24 #保存$s0/1/2/3 无递归调用不保存$ra
    sw  $t1, 20($sp)
    sw  $t0, 16($sp)
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

    beq $s1, $zero, pi_done1 #if(quotient == 0) done
    nop
pi_while1:  
    addi $t0, $zero, 10  # $t0 = 10
    div		$a0, $t0	# $a0 / 10 
    mflo	$s1		# $s1 = floor($a0 / 10) 
    mfhi	$s0		# $s0 = $a0 mod 10 
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    addi $s0, $s0, 48 # $s0 = remainder += '0'
    sb $s0, 0($t1) # buf[ significant_bit ] = remainder + '0'
    addi $s2, $s2, 1 # significant_bit ++
    move $a0, $s1 # a /= 10
    bne  $s1, $zero, pi_while1
    nop
pi_done1:
pi_while2:
    addi $s2, $s2, -1  # significant_bit--
    add $t1, $s3, $s2 # $t1 = &buf[ significant_bit ]
    li $v0, 4004
    li $a0, 1
    move $a1, $t1 
    li $a2, 1
    syscall
    bne $s2, $zero, pi_while2
    nop
pi_done2:
    lw  $s0, 0($sp)
    lw  $s1, 4($sp)
    lw  $s2, 8($sp)
    lw  $s3, 12($sp)
    lw  $t0, 16($sp)
    lw  $t1, 20($sp)
    addi $sp, $sp, 24    #恢复现场
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


.global printblank #输出一个空格
printblank:
    li $v0, 4004
    li $a0, 1
    la $a1, blank
    li $a2, 1
    syscall
    jr $ra
    nop
    