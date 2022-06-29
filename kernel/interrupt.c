/* Team OS
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
*/

#include "include/types.h"
#include "include/printk.h"

typedef struct registers
{
	uint16_t gs, fs, es, ds;				// Data segment selector
	uint16_t edi, esi, ebp, esp, ebx, edx, ecx, eax;	// Pushed by pusha.
	uint16_t int_no, err_code;    				// Interrupt number and error code
	uint16_t eip, cs, eflags, useresp, ss; 			// Pushed by the processor automatically.
} registers_t;

void isr_handler(registers_t reg)
{
	printk("Interrupt called:\n");
	printk("gs: %x fs: %x es: %x ds: %x\n", reg.gs, reg.fs, reg.es, reg.ds);
	printk("eax: %x ebx: %x ecx: %x edx: %x\n", reg.eax, reg.ebx,reg.ecx, reg.edx);
	printk("esp: %x ebp: %x esi: %x edi: %x\n", reg.esp, reg.ebp, reg.esi, reg.edi);
	printk("cs:eip %x:%x eflags %x user ss:esp %x:%x\n", reg.cs, reg.eip, reg.eflags, reg.ss, reg.useresp);
	printk("Interrupt No %x | Error Code %x\n", reg.int_no, reg.err_code);
}

