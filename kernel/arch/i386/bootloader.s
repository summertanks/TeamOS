; Team OS
; MIT License

; Copyright (c) 2022 Harkirat Singh Virk

; Permission is hereby granted, free of charge, to any person obtaining a copy
; of this software and associated documentation files (the "Software"), to deal
; in the Software without restriction, including without limitation the rights
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
; copies of the Software, and to permit persons to whom the Software is
; furnished to do so, subject to the following conditions:

; The above copyright notice and this permission notice shall be included in all
; copies or substantial portions of the Software.

; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
; SOFTWARE.

; Notes: Currently relying on Grub (Multiboot) to boot system.
; 	So not likely to find any code here, mostly some reference notes

; ENABLING A20
; When IBM designed the IBM PC AT machines, it used their newer Intel 80286 microprocessor, 
; which was not entirely compatible with previous x86 microprocessors when in real mode. 
; The older x86 processors did not have address lines A20 through A31. They did not have 
; an address bus that size yet. Any programs that go beyond the first  1 MB would appear 
; to wrap around. While it worked back then, the 80286's address space required 32 address lines. 
; However, if all 32 lines are accessable, we get the wrapping problem again. To fix this problem, 
; Intel put a logic gate on the 20th address line between the processor and system bus. 
; This logic gate got named Gate A20, as it can be enabled and disabled. For older programs, 
; it an be disabled for programs that rely on the wrap wround, and enabled for newer programs.
; When booting, the BIOS enables A20 when counting and testing memory, 
; and then disables it again before giving our operating system control.

; The Gate A20 is an electronic OR gate that was originally connected to the P21 electrical line 
; of the 8042 microcontroller (The keyboard controller). This gate is an output line that is treated 
; as Bit 1 of the output port data. We can send a command to recieve this data and even modify it. 
; By setting this bit, and writing the output line data we can have the microcontroller set the 
; OR gate thus enabling the A20 line.

; Enabling / Disabling - 
; Options are there using port 0x92, 0xEE or Int 15. These are system/botherboard/BIOS dependent
; Safer is to use Keyboard controller

enableA20:
; send read output port command
	mov     al,0xD0
	out     0x64,al
	call    wait_output
 
	; read input buffer and store on stack. This is the data read from the output port
	in      al,0x60
	push    eax
	call    wait_input
 
	; send write output port command
	mov     al,0xD1
	out     0x64,al
	call    wait_input
 
	; pop the output port data from stack and set bit 1 (A20) to enable
	pop     eax
	or      al,2		; 2 = 10 binary
	out     0x60,al		; write the data to the output port. This is done through the output buffer



