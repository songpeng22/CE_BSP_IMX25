;;------------------------------------------------------------------------------
;;      PA - physical address
;;      UA - uncached virtual address
;;      CA - cached virtual address
;;-----------------------------------------------------------------------------


;;------------------------------------------------------------------------------
;; REGISTER OFFSETS
;;------------------------------------------------------------------------------
UART_URXD_OFFSET     EQU       0x0000
UART_UTXD_OFFSET     EQU       0x0040
UART_UCR1_OFFSET     EQU       0x0080
UART_UCR2_OFFSET     EQU       0x0084
UART_UCR3_OFFSET     EQU       0x0088
UART_UCR4_OFFSET     EQU       0x008C
UART_UFCR_OFFSET     EQU       0x0090
UART_USR1_OFFSET     EQU       0x0094
UART_USR2_OFFSET     EQU       0x0098
UART_UESC_OFFSET     EQU       0x009C
UART_UTIM_OFFSET     EQU       0x00A0
UART_UBIR_OFFSET     EQU       0x00A4
UART_UBMR_OFFSET     EQU       0x00A8
UART_UBRC_OFFSET     EQU       0x00AC
UART_ONEMS_OFFSET    EQU       0x00B0
UART_UTS_OFFSET      EQU       0x00B4


    END
