;Error Code              Condition

; TSS id + EXT            The limit in the TSS descriptor is less than 103
; LTD id + EXT            Invalid LDT selector or LDT not present
; SS id + EXT             Stack segment selector is outside table limit
; SS id + EXT             Stack segment is not a writable segment
; SS id + EXT             Stack segment DPL does not match new CPL
; SS id + EXT             Stack segment selector RPL < >  CPL
; CS id + EXT             Code segment selector is outside table limit
; CS id + EXT             Code segment selector does not refer to code segment
; CS id + EXT             DPL of non-conforming code segment < > new CPL
; CS id + EXT             DPL of conforming code segment > new CPL
; DS/ES/FS/GS id + EXT    DS, ES, FS, or GS segment selector is outside table limits
; DS/ES/FS/GS id + EXT    DS, ES, FS, or GS is not readable segment

