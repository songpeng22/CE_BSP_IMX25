;-----------------------------------------------------------------------------
;  Copyright (c) Microsoft Corporation.  All rights reserved.
;
;  Use of this source code is subject to the terms of the Microsoft end-user
;  license agreement (EULA) under which you licensed this SOFTWARE PRODUCT.
;  If you did not accept the terms of the EULA, you are not authorized to use
;  this source code. For a copy of the EULA, please see the LICENSE.RTF on
;  your install media.
;
;-----------------------------------------------------------------------------
;
;  Copyright (C) 2007-2009, Freescale Semiconductor, Inc. All Rights Reserved.
;  THIS SOURCE CODE, AND ITS USE AND DISTRIBUTION, IS SUBJECT TO THE TERMS
;  AND CONDITIONS OF THE APPLICABLE LICENSE AGREEMENT
;
;-----------------------------------------------------------------------------
; 
;   FILE:   xldr.s
;   
;   Provides support for booting from a NAND device connected to the 
;   NAND flash controller.
;
;------------------------------------------------------------------------------
    INCLUDE armmacros.s
    INCLUDE common_uart.inc
    INCLUDE mx25_base_regs.inc
    INCLUDE mx25_base_mem.inc
    INCLUDE mx25_esdramc.inc    
    INCLUDE mx25_nandfc.inc

    INCLUDE image_cfg.inc


NANDFC_MAIN_BUFF_SIZE             EQU     (512)
NANDFC_SPARE_BUFF_SIZE            EQU     (64)

NANDFC_NFC_ECC_MODE_8BIT            EQU     0
NANDFC_NFC_ECC_MODE_4BIT            EQU     1
    INCLUDE nandchip.inc
; Destination
DST_LOAD_ADDR                       EQU     0x78001B00
DST_BBI_MAIN_SECTION                EQU     (NANDFC_MAIN_BUFF0_OFFSET + (NANDFC_MAIN_BUFF_SIZE) * (NUM_SEGMENT_NAND_USED + 3))
DST_SPARE_SECTION_HIGH              EQU     (NANDFC_SPARE_BUFF0_OFFSET + (NANDFC_SPARE_BUFF_SIZE) * (NUM_SEGMENT_NAND_USED + 3))
DST_BBI_COL_ADDR                    EQU     (400)


    OPT 2                                       ; disable listing
    INCLUDE kxarm.h
    OPT 1                                       ; reenable listing
   
    TEXTAREA

; romimage needs pTOC. give it one.
pTOC    DCD -1
    EXPORT pTOC


;******************************************************************************
;*
;* FUNCTION:    StartUp
;*
;* DESCRIPTION: System bootstrap function
;*
;* PARAMETERS:  None
;*
;* RETURNS:     None
;*
;******************************************************************************
 
    STARTUPTEXT
    LEAF_ENTRY StartUp
    
    ; Endless-loop for emulator
endless
    ;hb b	endless
    nop

uart_init
    ldr     r0, =(0x01)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UCR1_OFFSET)
    str     r0, [r1]

    ldr     r0, =(0x2127)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UCR2_OFFSET)
    str     r0, [r1]

    ldr     r0, =(0x0704)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UCR3_OFFSET)
    str     r0, [r1]

    ldr     r0, =(0x7C)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UCR4_OFFSET)
    str     r0, [r1]

    ldr     r0, =(0x091E)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UFCR_OFFSET)
    str     r0, [r1]

    ;UBIR = (BAUDRATE / 100) - 1
    ;UBIR = (115200 / 100) - 1 = 1151
    ldr     r0, =(1151)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UBIR_OFFSET)
    str     r0, [r1]

    ;UBMR = (UART_REF_CLK / 1600) - 1
    ;suppose UART_REF_CLK is 64MHz
    ldr     r0, =(39999)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UBMR_OFFSET)
    str     r0, [r1]

    ;Enable the TRDY and RRDY interrupts
    ldr     r0, =(0x2201)
    ldr     r1, =(CSP_BASE_REG_PA_UART1 + UART_UCR1_OFFSET)
    str     r0, [r1]
    
    ; SWAP the BBI because nfc automatically read first page out without BBI swap.
    ; The swap must be done at very beginning of the XLDR to avoid code mismatch.
    ldr     r1, =(NAND_SPARE_SIZE)  
    cmp     r1, #218
    bne     STD_SPARE_SIZE_Code    
         
SPARE_SIZE_218B_Code   
    ; Get main data in spare buffer and store it to r0
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldrh    r0, [r1]    
    and     r0, r0, #(0xFF00)
    mov     r0, r0, lsl #8    

    ;restore main data   
    ldr     r1, =(DST_LOAD_ADDR+NFC_BBI_MAIN_SEGMENT+NAND_BBI_COL_ADDR)    
    ldr     r4, [r1]
    and     r4, r4, #(0xFF00FFFF)
    orr     r4, r4, r0
    str     r4, [r1]
    b       Exit_SwapBBI_Code
    
STD_SPARE_SIZE_Code    
    ; Get main data in spare buffer and store it to r0
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC + NFC_SPARE_SEGMENT_HIGH)
    ldrh    r0, [r1]    
    and     r0, r0, #(0xFF00)
    mov     r0, r0, lsr #8    

    ; Get BBI in main buffer
    ldr     r1, =(DST_LOAD_ADDR + NFC_BBI_MAIN_SEGMENT + NAND_BBI_COL_ADDR)
    ldr     r4, [r1]
    and     r4, r4, #(0xFFFFFF00)
    orr     r4, r4, r0
    str     r4, [r1]
    
    ;if the nand flash is 2K Page Size, then we should do second page bbi swapping.
    mov     r0, #(NAND_PAGE_SIZE)
    cmp     r0, #2048
    bne     Exit_SwapBBI_Code

    ; Get main data in spare buffer and store it to r0
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC + DST_SPARE_SECTION_HIGH)
    ldrh    r0, [r1]    
    and     r0, r0, #(0xFF00)
    mov     r0, r0, lsr #8    

    ;restore main data 
    ldr     r1, =(DST_LOAD_ADDR + DST_BBI_MAIN_SECTION + DST_BBI_COL_ADDR)
    ldr     r4, [r1]
    and     r4, r4, #(0xFFFFFF00)
    orr     r4, r4, r0
    str     r4, [r1]

Exit_SwapBBI_Code    
    
    ;; now we do the external RAM init. it's located in another file because it's shared among all the XLDRs
    INCLUDE xldr_sdram_init.inc
    
nfc_init
    ;
    ; Configure NFC Internal Buffer Lock Control
    ;
    ;   BLS - Unlocked (2 << 0)                         = 0x0002
    ;                                                   --------
    ;                                                     0x0002
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NFC_CONFIGURATION_OFFSET)
    ldr     r0, =0x0002
    strh    r0, [r1]
    
    ; Select NANDFC RAM buffer address
    ;
    ;   RBA - 1st internal RAM buffer (0 << 0)          = 0x0000
    ;                                                   --------
    ;                                                     0x0000
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_RAM_BUFFER_ADDRESS_OFFSET)
    ldr     r0, =0x0000
    strh    r0, [r1]
    
    ; Configure NANDFC operation
    ;   
    ;   FP_INT - Interrupt generated after whole page   = 0x0800
    ;   PPB - 128 pages per block                       = 0x0400
    ;   NF_CE - normal CE signal (0 << 7)               = 0x0000
    ;   NF_RST - no reset (0 << 6)                      = 0x0000
    ;   NF_BIG - little endian (0 << 5)                 = 0x0000
    ;   INT_MSK - mask interrupt (1 << 4)               = 0x0010
    ;   ECC_EN - enable ECC (1 << 3)                    = 0x0008
    ;   SP_EN - main and spare read/write (0 << 2)      = 0x0000
    ;   DMA_MODE - after page read                      = 0x0002
    ;   ECC_MODE - 4bit ecc                             = 0x0001  
    ;                                                   --------
    ;                                                     0x0C1A
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG1_OFFSET)
    ldr     r0, =(0x091A)
    
    ldr     r3, =(NAND_SPARE_SIZE)
    cmp     r3, #218
    bne     ECC_configure

    ; if 218B spare size
    mov     r3, #(NANDFC_NFC_ECC_MODE_8BIT)
    b       ECC_set_cfg    
    
ECC_configure
    mov     r3, #(NANDFC_NFC_ECC_MODE_4BIT)
ECC_set_cfg    
    add     r0, r0, r3        
    
    ; Page number per block
    ldr     r3, =(NAND_PAGE_CNT)
    cmp     r3, #256
    bne     page_size_configure

    ; if 256 pages per block
    mov     r3, #(0x11)
    b       page_size_set_cfg

page_size_configure
    mov     r3, #(NAND_PAGE_CNT>>6)
page_size_set_cfg
    mov     r3, r3, lsl #9
    add     r0, r0, r3     
    strh    r0, [r1]

    ; Configure NANDFC unlock start block
    ;
    ;   USBA - block #0 (0 << 0)                        = 0x0000
    ;                                                   --------
    ;                                                     0x0000
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_UNLOCK_START_BLK_ADD0_OFFSET)
    ldr     r0, =0x0000
    strh    r0, [r1]

    ; Configure NANDFC unlock end block
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_UNLOCK_END_BLK_ADD0_OFFSET)
    ldr     r0, =(NAND_BLOCK_CNT-1)
    strh    r0, [r1]

    ; Configure NANDFC write protection status
    ;
    ;   WPC - unlock specified range (4 << 0)           = 0x0004
    ;                                                   --------
    ;                                                     0x0004
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NF_WR_PROT_OFFSET)
    ldr     r0, =0x0004
    strh    r0, [r1]

    ; Configure the Spare area size
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_SPAS_OFFSET)
    ldr     r0, =(NAND_SPARE_SIZE >> 1)
    strh    r0, [r1]

detect_nand
	; Read ID-Data from NAND to r0
	bl		NfcRdIdData
	; r2 = manufacturer, r3 = device
	mov		r2,r0
	mov		r3,r0,ror #8
	mov		r0,#0xFF
	and		r2,r2,r0
	and		r3,r3,r0
	
	cmp		r2,#CYP_S34ML01G200_MFG_ID
	bne		not_cypress
	; device is cypress
    ldr     r10,  =(flash_parameters_CYPRESS_S34ML01G200)
	cmp		r3,#CYP_S34ML01G200_DEV_ID
	beq		nand_detected	
	b		detect_nand
not_cypress
	cmp		r2,#NMX_N01_MFG_ID
	bne		not_numonix
	; device is numonix
    ldr     r10,  =(flash_parameters_numonix_nand01gw)
	cmp		r3,#NMX_N01_DEV_ID
	beq		nand_detected	
	b		detect_nand
not_numonix	
	cmp		r2,#MIC_MT29F1G_MFG_ID
	bne		not_micron
	; device is micron
    ldr     r10,  =(flash_parameters_micron_mt29f1g08)
	cmp		r3,#MIC_MT29F1G_DEV_ID
	beq		nand_detected
	b		detect_nand
not_micron
	cmp		r2,#SAM_K9F1G08_MFG_ID
	bne		not_samsung
	; device is samsung
    ldr     r10,  =(flash_parameters_samsung_k9f1g08)
	cmp		r3,#SAM_K9F1G08_DEV_ID
	beq		nand_detected
    ldr     r10,  =(flash_parameters_samsung_k9f2g08)
	cmp		r3,#SAM_K9F2G08_DEV_ID
	beq		nand_detected
	b		detect_nand
not_samsung
	cmp		r2,#TOS_TC58NVG0_MFG_ID
	bne		not_toshiba
	; device is toshiba
    ldr     r10,  =(flash_parameters_toshiba_tc58nvg0)
	cmp		r3,#TOS_TC58NVG0_DEV_ID
	beq		nand_detected
	b detect_nand
not_toshiba
	b detect_nand
	
nand_detected
	; relocate pointer to flash-parameters	
	;hb ldr	r0, =(LOAD_ADDR)
	bl	next
next
	ldr	r0,	=(next)
	sub	r0,	r14, r0	
	add	r10, r10, r0
	
	;-----------------------------
	; NAND-Controller reinit start
	;-----------------------------
;nfc_init
    ;
    ; Configure NFC Internal Buffer Lock Control
    ;
    ;   BLS - Unlocked (2 << 0)                         = 0x0002
    ;                                                   --------
    ;                                                     0x0002
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NFC_CONFIGURATION_OFFSET)
    ldr     r0, =0x0002
    strh    r0, [r1]
    
    ; Select NANDFC RAM buffer address
    ;
    ;   RBA - 1st internal RAM buffer (0 << 0)          = 0x0000
    ;                                                   --------
    ;                                                     0x0000
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_RAM_BUFFER_ADDRESS_OFFSET)
    ldr     r0, =0x0000
    strh    r0, [r1]
    
    ; Configure NANDFC operation
    ;   
    ;   FP_INT - Interrupt generated after whole page   = 0x0800
    ;   PPB - 128 pages per block                       = 0x0400
    ;   NF_CE - normal CE signal (0 << 7)               = 0x0000
    ;   NF_RST - no reset (0 << 6)                      = 0x0000
    ;   NF_BIG - little endian (0 << 5)                 = 0x0000
    ;   INT_MSK - mask interrupt (1 << 4)               = 0x0010
    ;   ECC_EN - enable ECC (1 << 3)                    = 0x0008
    ;   SP_EN - main and spare read/write (0 << 2)      = 0x0000
    ;   DMA_MODE - after page read                      = 0x0002
    ;   ECC_MODE - 4bit ecc                             = 0x0001  
    ;                                                   --------
    ;                                                     0x0C1A
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG1_OFFSET)
    ldr     r0, =(0x091A)
    
    ldr     r3, =(NAND_SPARE_SIZE)
    cmp     r3, #218
    bne     ECC_configure_2

    ; if 218B spare size
    mov     r3, #(NANDFC_NFC_ECC_MODE_8BIT)
    b       ECC_set_cfg_2    
    
ECC_configure_2
    mov     r3, #(NANDFC_NFC_ECC_MODE_4BIT)
ECC_set_cfg_2    
    add     r0, r0, r3        
    
    ; Page number per block
    ;hb ldr		r3, =(NAND_PAGE_CNT)
    ldr     r3, [r10, #BIZ_NAND_PAGE_CNT]
    cmp     r3, #256
    bne     page_size_configure_2

    ; if 256 pages per block
    mov     r3, #(0x11)
    b       page_size_set_cfg_2

page_size_configure_2
    ;hb mov     r3, #(NAND_PAGE_CNT>>6)
    ldr     r3, [r10, #BIZ_NAND_PAGE_CNT]
    mov     r3, r3, lsr #6
page_size_set_cfg_2
    mov     r3, r3, lsl #9
    add     r0, r0, r3     
    strh    r0, [r1]

    ; Configure NANDFC unlock start block
    ;
    ;   USBA - block #0 (0 << 0)                        = 0x0000
    ;                                                   --------
    ;                                                     0x0000
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_UNLOCK_START_BLK_ADD0_OFFSET)
    ldr     r0, =0x0000
    strh    r0, [r1]

    ; Configure NANDFC unlock end block
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_UNLOCK_END_BLK_ADD0_OFFSET)
    ;hb ldr     r0, =(NAND_BLOCK_CNT-1)
    ldr		r0, [r10, #BIZ_NAND_BLOCK_CNT]
    sub     r0, r0, #1
    strh    r0, [r1]

    ; Configure NANDFC write protection status
    ;
    ;   WPC - unlock specified range (4 << 0)           = 0x0004
    ;                                                   --------
    ;                                                     0x0004
    ;
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NF_WR_PROT_OFFSET)
    ldr     r0, =0x0004
    strh    r0, [r1]

    ; Configure the Spare area size
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_SPAS_OFFSET)
    ldr     r0, =(NAND_SPARE_SIZE >> 1)
    strh    r0, [r1]
    
	;---------------------------
	; NAND-Controller reinit end
	;---------------------------
    
    ;We should find the physical block address according to logical block address. 
    ldr     r13, =0x0
    ldr     r8, =0x0
    ldr     r9, =(IMAGE_EBOOT_NAND_BLOCK_OFFSET+1)
    
getgoodphyblock	
    ;hb mov     r12, r13, lsl #(NAND_PAGE_CNT_LSH)
    ldr     r12, [r10, #(BIZ_NAND_PAGE_CNT_LSH)]
    mov		r12, r13, lsl r12
    bl      GetBlockStatus
    cmp     r0,  #0xFF
    bne     nextphyblock
    
    add     r8,  r8, #0x01
    cmp     r8,  r9
    bne     nextphyblock
    b       preloadeboot  
    
nextphyblock    
    add     r13, r13, #0x01  
    b       getgoodphyblock

preloadeboot    
    ; Current external RAM load address is kept in R3
    ldr     r3,  =(IMAGE_BOOT_BOOTIMAGE_RAM_PA_START)

    ; Current page address is kept in R12
    ;hb mov     r12, r13, lsl #(NAND_PAGE_CNT_LSH)    
    ldr     r12, [r10, #(BIZ_NAND_PAGE_CNT_LSH)]
    mov		r12, r13, lsl r12

load_eboot
    ;skip bad block
    bl      GetBlockStatus
    cmp     r0, #0xFF
    bne     next_block
    ;hb mov     r12, r13, lsl #(NAND_PAGE_CNT_LSH)
    ldr     r12, [r10, #(BIZ_NAND_PAGE_CNT_LSH)]
    mov		r12, r13, lsl r12
    
    ; Read one physical page of data from the NAND device into NFC internal buffer
    bl      NfcRd1PhyPage
    
    ; Advance page pointer to next page
    add     r12, r12, #0x01 
    
    ; Copy one physical page of data in the NANDFC buffers to RAM
next_page
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_MAIN_BUFF0_OFFSET)
    mov     r2, #NAND_PAGE_SIZE

copy_eboot
    ldmia   r1!, {r4 - r7}
    stmia   r3!, {r4 - r7}
    subs    r2, r2, #16
    bne     copy_eboot

    ; Check if we are done
    ldr     r1, =(IMAGE_BOOT_BOOTIMAGE_RAM_PA_START)
    subs    r1, r3, r1
    cmp     r1, #IMAGE_BOOT_BOOTIMAGE_RAM_SIZE
    beq     jump2eboot

    ; Check if we have hit a block boundary
    ;hb ldr     r1, =(NAND_BLOCK_SIZE-1)
    ldr     r1, [r10, #(BIZ_NAND_BLOCK_SIZE)]
    sub		r1, r1, #1
    ands    r1, r1, r3
    beq     next_block
    
    ; Read another page
    bl      NfcRd1PhyPage
    
    ; Advance page pointer to next page
    add     r12, r12, #0x01 
       
    b       next_page    

next_block
    ; Advance to next NAND block
    add     r13, r13, #1

    b       load_eboot
    
jump2eboot

    ; Jump to EBOOT image copied to DRAM
    ldr     r1, =(IMAGE_BOOT_BOOTIMAGE_RAM_PA_START)
    mov     pc, r1
    nop
    nop
    nop
    nop

forever
    b       forever

;-------------------------------------------------------------------------------
;
;   Function:  GetBlockStatus
;
;   This function sends an address (single cycle) to the NAND device.  
;
;   Parameters:
;       None.
;
;   Returns:
;           [out] - r0: Bad block flag: 0x00 indicates bad block, 0xFF indicate good block
;-------------------------------------------------------------------------------
    LEAF_ENTRY GetBlockStatus
    
    ; Save return address
    mov     r7, r14    

    mov     r5, r12		
  
	mov		r6, #0		; second bbi not checked
CheckBadBlock	
    ; Check bad block indicator in first BBI page
    add     r12, r12, #BBI_PAGE_ADDR_1 
    
CheckBBIPage       	    
    bl	    NfcRd1PhyPage
    
    ; NANDFC_ECC_STATUS_RESULT_OFFSET
    ldr     r2, =(NAND_PAGE_SIZE)
    cmp     r2, #2048
    bne     PageSize4K    
    ldr     r1,  =(CSP_BASE_REG_PA_NANDFC+NANDFC_ECC_STATUS_RESULT1_OFFSET)
    b       ECCCheck     
       
PageSize4K
    ldr     r1,  =(CSP_BASE_REG_PA_NANDFC+NANDFC_ECC_STATUS_RESULT2_OFFSET)
    
ECCCheck
    ldrh    r0, [r1]

    ; NOSER1, 2, 3, 4, 
    ; r0 = 0, NOSER1, 0x000F
    ;      1, NOSER2, 0x00F0
    ;      2, NOSER3, 0x0F00
    ;      3, NOSER4, 0xF000

    ldr     r1, =(0xFFFF) 
    and     r0, r0, r1
    cmp     r0, #0x0
    beq     NoECCError

    ldr     r1, =(0x4) 
    
ECCCheck2
    and     r2, r0, #0xF
    cmp     r2, #0xF
    beq     BadBlockFound
    
    mov     r0, r0, lsr #4    
    sub     r1, r1, #1
    cmp     r1, #0x0
    bne     ECCCheck2
        
    ;Has the page been written before?
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_MAIN_BUFF0_OFFSET)
    add     r2, r1, #NAND_PAGE_SIZE 
       
CheckMainData    
    ldr     r0, [r1]
    cmp     r0, #0xFFFFFFFF
    bne     WrittenPage
        
    add     r1, r1, #4
    cmp     r1, r2
    bne     CheckMainData
    
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldr     r0, [r1]
    cmp     r0, #0xFFFFFFFF
    bne     WrittenPage    
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_LOW)
    ldr     r0, [r1]
    cmp     r0, #0xFFFFFFFF
    beq     Check2ndBBIPage 
     
WrittenPage
    ;Disable ECC
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG1_OFFSET)
    ldrh    r0, [r1]
    ands    r0, r0, #(~0x8)
    strh    r0, [r1] 
    
    bl	    NfcRd1PhyPage
    
    ;Enable ECC   
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG1_OFFSET)
    ldrh    r2, [r1]
    orr     r2, r2, #(0x8)
    strh    r2, [r1]

NoECCError              
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldrh    r0, [r1]
    mov     r0, r0, lsr #8
    and     r0, r0, #0xFF
    cmp     r0, #0xFF
    bne     BadBlockFound

Check2ndBBIPage    
    ; Check one page or two for BBI
    ;hb ldr     r2, =(BBI_PAGE_NUM)
    ldr     r2, [r10, #BIZ_BBI_PAGE_NUM]
    cmp     r2, #2
    bne     GoodBlockFound    

	; if 2nd bbi already checked then exit
	cmp		r6, #1
	beq	GoodBlockFound

    ; Check bad block indicator in second BBI page  
	mov		r6, #1		; second bbi checked
    mov     r12, r5        
    ;hb add     r12, r12, #BBI_PAGE_ADDR_2
    ldr     r0, [r10, #BIZ_BBI_PAGE_ADDR_2]
    add		r12, r12, r0
    b       CheckBBIPage

BadBlockFound
    ldr     r0,  =0x00
    b       Quit
	
GoodBlockFound
    ldr	    r0,  =0xFF
		
Quit    
    ; load return address
    mov     r14, r7 
    
    RETURN


;-------------------------------------------------------------------------------
;
;   Function:  NfcCmd
;
;   This function issues the specified command to the NAND device.
;
;   Parameters:
;       command (r0)
;           [in] - Command to issue to the NAND device.
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcCmd

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CMD_OFFSET)
    strh    r0, [r1]
    
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG2_OFFSET)
    ldr     r0, =(NANDFC_CONFIG2_FCMD)
    strh    r0, [r1]

    RETURN


;-------------------------------------------------------------------------------
;
;   Function:  NfcAddr
;
;   This function sends an address (single cycle) to the NAND device.  
;
;   Parameters:
;       address (r0)
;           [in] - Address to issue to the NAND device.
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcAddr

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_ADDR_OFFSET)
    strh    r0, [r1]
    
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG2_OFFSET)
    ldr     r0, =(NANDFC_CONFIG2_FADD)
    strh    r0, [r1]

    RETURN


;-------------------------------------------------------------------------------
;
;   Function:  NfcRead
;
;   This function reads a page of data from the NAND device.  
;
;   Parameters:
;       NFC buffer (r0)
;           [in] - NFC buffer (0-3) into which the page is read
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcRead
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_RAM_BUFFER_ADDRESS_OFFSET)
    strh    r0, [r1]

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG2_OFFSET)
    ldr     r0, =(NANDFC_CONFIG2_FDO_PAGE)
    strh    r0, [r1]

    RETURN

;-------------------------------------------------------------------------------
;
;   Function:  NfcReadID
;
;   This function reads the ID data from the NAND device.  
;
;   Parameters:
;       NFC buffer (r0)
;           [in] - NFC buffer (0-3) into which the ID data is read
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcReadID
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_RAM_BUFFER_ADDRESS_OFFSET)
    strh    r0, [r1]

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG2_OFFSET)
    ldr     r0, =(NANDFC_CONFIG2_FDO_ID)
    strh    r0, [r1]

    RETURN

;-------------------------------------------------------------------------------
;
;   Function:  NfcWait
;
;   This function waits for the current NAND device operation to complete.
;
;   Parameters:
;       None.
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcWait

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_NAND_FLASH_CONFIG2_OFFSET)
wait_loop
    ldrh    r0, [r1]
    ands    r0, r0, #NANDFC_CONFIG2_INT
    beq     wait_loop

    ; Clear INT status
    bic     r0, r0, #NANDFC_CONFIG2_INT
    strh    r0, [r1]

    RETURN

;-------------------------------------------------------------------------------
;
;   Function:  SwapBBI
;
;   This function swap BBI between main buffer and spare buffer.
;
;   Parameters:
;       None
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY SwapBBI


    ldr     r1, =(NAND_SPARE_SIZE)  
    CMP     r1, #218
    bne     STD_SPARE_SIZE    
         
SPARE_SIZE_218B
    ;Get main data in spare buffer and store it to r0
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldr     r0, [r1]    
    and     r0, r0, #(0xFF00)
    mov     r0, r0, lsl #8    

    ;Get BBI in main buffer
    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NFC_BBI_MAIN_SEGMENT+NAND_BBI_COL_ADDR)
    ldr     r2, [r1]
    and     r2, r2, #(0xFF0000)
    mov     r2, r2, lsr #8
	
    ;swap data
    ;restore main data
    ldr     r4, [r1]
    and     r4, r4, #(0xFF00FFFF)
    orr     r4, r4, r0
    str     r4, [r1]

    b       Exit_SwapBBI
    
STD_SPARE_SIZE    
    ;Get main data in spare buffer and store it to r0
    ldr	    r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldrh    r0, [r1]    
    and	    r0, r0, #(0xFF00)
    mov	    r0, r0, lsr #8    

    ;Get BBI in main buffer
    ldr	    r1, =(CSP_BASE_REG_PA_NANDFC+NFC_BBI_MAIN_SEGMENT+NAND_BBI_COL_ADDR)
    ldrh    r2, [r1]
    and	    r2, r2, #(0xFF)
    mov	    r2, r2, lsl #8
	
    ;swap data
    ;restore main data
    ldr     r4, [r1]
    and     r4, r4, #(0xFFFFFF00)
    orr     r4, r4, r0
    str     r4, [r1]


Exit_SwapBBI

    ;restore spare data
    ldr	    r1, =(CSP_BASE_REG_PA_NANDFC+NFC_SPARE_SEGMENT_HIGH)
    ldr	    r4, [r1]
    and	    r4, r4, #(0xFFFF00FF)
    orr	    r4, r4, r2
    str     r4, [r1]


    RETURN
    
;-------------------------------------------------------------------------------
;
;   Function:  NfcRd1PhyPage
;
;   This function reads one physical page from Nand Flash device.
;
;   Parameters:
;       address (r12)
;           [in/out] - page address for NAND device.
;
;   Returns:
;       None.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcRd1PhyPage

    ; Save return address
    mov     r11, r14

    ; Send page read command
    ldr     r0, =(CMD_READ)
    bl      NfcCmd
    bl      NfcWait

    ; Send column address (cycle 1)
    mov     r0, #0
    and     r0, r0, #(0xFF)
    bl      NfcAddr
    bl      NfcWait

    ; Send column address (cycle 2)
    mov     r0, #0
    and     r0, r0, #(0xFF)
    bl      NfcAddr
    bl      NfcWait

    ; Send row address (cycle 3)
    mov     r0, r12
    and     r0, r0, #(0xFF)
    bl      NfcAddr
    bl      NfcWait

    ; Send row address (cycle 4)
    mov     r0, r12, lsr #8
    and     r0, r0, #(0xFF)
    bl      NfcAddr
    bl      NfcWait

    ; Send row address (cycle 5)
    mov     r0, r12, lsr #16
    and     r0, r0, #(0xFF)
    bl      NfcAddr
    bl      NfcWait

    ; Send the second cycle of page read command
    ldr     r0, =(CMD_READ2CYCLE)
    bl      NfcCmd
    bl      NfcWait

    ; Read the page, and start from buffer 0
    mov     r0, #0 
    bl      NfcRead
    bl      NfcWait

    bl      SwapBBI
 
    ; Restore return address
    mov     r14, r11

    RETURN


;-------------------------------------------------------------------------------
;
;   Function:  NfcRdIdData
;
;   This function reads ID-Data from Nand Flash device.
;
;   Parameters:
;
;   Returns:
;       r0 = ID.
;-------------------------------------------------------------------------------
    LEAF_ENTRY NfcRdIdData

    ; Save return address
    mov     r11, r14

    ; Send read ID command
    ldr     r0, =(CMD_READID)
    bl      NfcCmd
    bl      NfcWait

    ; Send address cycle 1 (0x00)
    mov     r0, #0
    bl      NfcAddr
    bl      NfcWait

    ; Read the ID-Data
    mov     r0, #0 
    bl      NfcReadID
    bl      NfcWait

    ldr     r1, =(CSP_BASE_REG_PA_NANDFC+NANDFC_MAIN_BUFF0_OFFSET)
	ldr		r0,[r1]
	
    ; Restore return address
    mov     r14, r11

    RETURN
    
flash_parameters
fp_nand_page_cnt		dcd	NAND_PAGE_CNT
fp_nand_page_cnt_lsh	dcd	NAND_PAGE_CNT_LSH
fp_nand_block_size		dcd	NAND_BLOCK_SIZE
fp_nand_block_cnt		dcd	NAND_BLOCK_CNT
fp_bbi_page_num			dcd	BBI_PAGE_NUM
fp_bbi_page_addr_2		dcd	BBI_PAGE_ADDR_2

BIZ_NAND_PAGE_CNT		EQU (fp_nand_page_cnt - flash_parameters)
BIZ_NAND_PAGE_CNT_LSH	EQU (fp_nand_page_cnt_lsh - flash_parameters)
BIZ_NAND_BLOCK_SIZE		EQU	(fp_nand_block_size - flash_parameters)
BIZ_NAND_BLOCK_CNT		EQU	(fp_nand_block_cnt - flash_parameters)
BIZ_BBI_PAGE_NUM		EQU	(fp_bbi_page_num - flash_parameters)
BIZ_BBI_PAGE_ADDR_2		EQU (fp_bbi_page_addr_2 - flash_parameters)

flash_parameters_CYPRESS_S34ML01G200
						dcd	CYP_S34ML01G200_NAND_PAGE_CNT
						dcd	CYP_S34ML01G200_NAND_PAGE_CNT_LSH
						dcd	CYP_S34ML01G200_NAND_BLOCK_SIZE
						dcd	CYP_S34ML01G200_NAND_BLOCK_CNT
						dcd	CYP_S34ML01G200_BBI_PAGE_NUM
						dcd	CYP_S34ML01G200_BBI_PAGE_ADDR_2

flash_parameters_numonix_nand01gw
						dcd	NMX_N01_NAND_PAGE_CNT
						dcd	NMX_N01_NAND_PAGE_CNT_LSH
						dcd	NMX_N01_NAND_BLOCK_SIZE
						dcd	NMX_N01_NAND_BLOCK_CNT
						dcd	NMX_N01_BBI_PAGE_NUM
						dcd	NMX_N01_BBI_PAGE_ADDR_2

flash_parameters_micron_mt29f1g08
						dcd	MIC_MT29F1G_NAND_PAGE_CNT
						dcd	MIC_MT29F1G_NAND_PAGE_CNT_LSH
						dcd	MIC_MT29F1G_NAND_BLOCK_SIZE
						dcd	MIC_MT29F1G_NAND_BLOCK_CNT
						dcd	MIC_MT29F1G_BBI_PAGE_NUM
						dcd	MIC_MT29F1G_BBI_PAGE_ADDR_2

flash_parameters_samsung_k9f1g08
						dcd	SAM_K9F1G08_NAND_PAGE_CNT
						dcd	SAM_K9F1G08_NAND_PAGE_CNT_LSH
						dcd	SAM_K9F1G08_NAND_BLOCK_SIZE
						dcd	SAM_K9F1G08_NAND_BLOCK_CNT
						dcd	SAM_K9F1G08_BBI_PAGE_NUM
						dcd	SAM_K9F1G08_BBI_PAGE_ADDR_2

flash_parameters_toshiba_tc58nvg0
						dcd	TOS_TC58NVG0_NAND_PAGE_CNT
						dcd	TOS_TC58NVG0_NAND_PAGE_CNT_LSH
						dcd	TOS_TC58NVG0_NAND_BLOCK_SIZE
						dcd	TOS_TC58NVG0_NAND_BLOCK_CNT
						dcd	TOS_TC58NVG0_BBI_PAGE_NUM
						dcd	TOS_TC58NVG0_BBI_PAGE_ADDR_2

flash_parameters_samsung_k9f2g08
						dcd	SAM_K9F2G08_NAND_PAGE_CNT
						dcd	SAM_K9F2G08_NAND_PAGE_CNT_LSH
						dcd	SAM_K9F2G08_NAND_BLOCK_SIZE
						dcd	SAM_K9F2G08_NAND_BLOCK_CNT
						dcd	SAM_K9F2G08_BBI_PAGE_NUM
						dcd	SAM_K9F2G08_BBI_PAGE_ADDR_2

    END

