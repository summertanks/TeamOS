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

#include <stdarg.h>	// for va_list, va_start & va_end
#include <stddef.h>	// for size_t
#include <limits.h>	// for INT_MAX
#include "../include/terminal.h"

int _print(const char* string, size_t length)
{
	return terminal_write_chars (string, length);
}

int printk(const char* restrict string, ...) 
{
	va_list parameters;
	va_start(parameters, string);

	int written = 0;

	while(*string != '\0') 
	{
		size_t max = INT_MAX - written;
		size_t offset = 1;
		if (string[0] != '%')
		{
			while(string[offset] != '%' || string[offset] != '\0')
				offset++;
			if (max < offset)
				return -1;
			if (!_print(string,offset))
				return -1;
			string += offset;
			written += offset;
			continue;
		} else {
			string++;
		}
	}

	va_end(parameters);
	return written;
}
