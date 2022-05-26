ENTRY(_start)			/* Defining the entry point to the file */
OUTPUT_FORMAT(elf32-i386)	/* File format - elf 32 bits */
OUTPUT_ARCH(i386:i386)		/* Platform - i386: 32 Bit Intel Architecture */

SECTIONS
{
	/* Put sections at 1 MiB, Kernel to be loaded here by Boot Loader */
	. = 1M;

	/* Sections in 4K blocks aligned to 4K boundaries */
	.text BLOCK(4K) : ALIGN(4K)
	{
		*(.multiboot)	/* Required within the first 8Kb */
		*(.text*)	/* all text sextion */
	}

	/* Read-Only Data */
	.rodata BLOCK(4K) : ALIGN(4K)
	{
		*(.rodata)
	}

	/* Data Section, Initialised 
	 * Contains Constructors & Destructors */
	.data BLOCK(4K) : ALIGN(4K)
	{
		start_ctors = .;
		KEEP(*( .init_array ));
		KEEP(*(SORT_BY_INIT_PRIORITY( .init_array.* )));
		end_ctors = .;

		*(.data)
	}

	/* Uninitialised Data */
	.bss BLOCK(4K) : ALIGN(4K)
	{
		__BSS_START = .;
		*(COMMON)
		*(.bss)
		__BSS_END = .;
	}

	/DISCARD/ : { *(.fini_array*) *(.comment) }
}

