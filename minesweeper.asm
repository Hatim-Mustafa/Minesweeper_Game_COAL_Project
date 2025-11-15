INCLUDE Irvine32.inc

.data
    ; ===== Boards =====
    visibleBoard BYTE 26*13 DUP(?)   ; Visible board, initialized with '*'
    actualBoard  BYTE 26*13 DUP(?)   ; Actual board with mines

    rows dword ?
    cols dword ?
    mines BYTE ?

    ; ===== Board printing strings =====
    header1   BYTE 13 dup(' '),0
    header2   BYTE 13 dup(' '),0
    twoSpaces BYTE "  ",0
    indent    BYTE "                ",0
    newlines  BYTE 13,10,0

    ; ===== Difficulty messages =====
    diff1 BYTE "Choose difficulty (1: Easy, 2: Medium, 3: Hard): ",0
    diff2 BYTE "Invalid difficulty selected. Please try again: ",0

.code

; =================================
; DIFFICULTY SELECTION
; =================================
difficulty PROC
    mov edx, OFFSET diff1
    call WriteString

difficultyInput:
    call ReadInt

    cmp eax,1
    je easy
    cmp eax,2
    je medium
    cmp eax,3
    je hard
    jmp invalid

easy:
    mov rows, 12
    mov cols, 9
    mov mines, 10
    jmp done
medium:
    mov rows, 19
    mov cols, 10
    mov mines, 35
    jmp done
hard:
    mov rows, 26
    mov cols, 13
    mov mines, 75
    jmp done
invalid:
    mov edx, OFFSET diff2
    call WriteString
    jmp difficultyInput
done:
    ret
difficulty ENDP

; =================================
; PRINT BOARD
; =================================
printboard PROC
    push ebp
    mov ebp, esp

    mov ebx, edx           ; EBX = pointer to visibleBoard
    call Clrscr

    mov ecx, rows        ; total rows
    mov edi, cols        ; total columns

    ; ===============================
    ; Print column header - Tens
    ; ===============================
    xor esi, esi           ; column counter
    mov edx, OFFSET indent ; indent to align headers with board
    call WriteString

print_tens_loop:
    cmp esi, edi
    jge tens_done

    cmp esi, 9
    jle tens_space

    ; >=10, print tens digit + space
    mov eax, esi
    xor edx, edx
    mov ebp, 10
    div ebp           ; EAX=quotient (tens), DL=remainder (ones)
    add al,'0'
    call WriteChar
    mov al,' '
    call WriteChar
    jmp tens_continue

tens_space:
    mov edx, OFFSET twoSpaces
    call WriteString

tens_continue:
    inc esi
    jmp print_tens_loop
tens_done:
    call Crlf

    ; ===============================
    ; Print column header - Ones
    ; ===============================
    xor esi, esi           ; reset column counter
    ; <-- DO NOT add indent here, it should align under tens header

    mov edx, OFFSET indent
    call WriteString 
print_ones_loop:
    cmp esi, edi
    jge ones_done

    mov eax, esi
    xor edx, edx
    mov ebp, 10
    div ebp          ; EAX=quotient (tens), DL=ones
    add dl,'0'
    mov al, dl
    call WriteChar
    mov al,' '
    call WriteChar

    inc esi
    jmp print_ones_loop
ones_done:
    call Crlf

    ; ===============================
    ; Print board rows
    ; ===============================
    xor ecx, ecx       ; row index

row_loop:
    cmp ecx, rows
    jge end_print

    mov edx, OFFSET indent
    call WriteString   ; indent each row

    xor esi, esi       ; column index
col_loop:
    cmp esi, edi
    jge row_done

    mov eax, ecx
    mul edi
    add eax, esi       ; index = row*cols + col
    mov al, [ebx + eax]
    call WriteChar
    mov al,' '
    call WriteChar

    inc esi
    jmp col_loop

row_done:
    mov eax, ecx
    call WriteDec     ; print row number
    call Crlf

    inc ecx
    jmp row_loop

end_print:
    pop ebp
    ret
printboard ENDP

; =================================
; MAIN
; =================================
main PROC
    call difficulty

    ; Initialize visible board with '*'
    mov ecx, 26*13
    mov edi, OFFSET visibleBoard
    mov al, '*'
fill_board:
    stosb
    loop fill_board

    mov edx, OFFSET visibleBoard
    call printboard

    exit
main ENDP

END main
