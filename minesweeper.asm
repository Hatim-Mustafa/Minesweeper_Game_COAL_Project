INCLUDE Irvine32.inc

.data
	visibleBoard BYTE 26 * 13 DUP (?) ; Visible board representation
	actualBoard BYTE 26 * 13 DUP (?)  ; Actual board representation with mines
	rows BYTE ?
	cols BYTE ?
	mines BYTE ?

	; Messages
	; Difficulty Function
	diff1 BYTE "Choose difficulty (1: Easy, 2: Medium, 3: Hard): ", 0
	diff2 BYTE "Invalid difficulty selected. Please try again: ", 0

.code

	difficulty PROC
	; Set game parameters based on difficulty level
	; 1 - Easy, 2 - Medium, 3 - Hard

		mov edx, OFFSET diff1
		call WriteString
		difficultyInput:
		call ReadInt

		cmp eax, 1
		je easy
		cmp eax, 2
		je medium
		cmp eax, 3
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

	main PROC
	call difficulty
	movzx eax, cols
	call WriteDec
	exit
	main endp
	END main