//
// Copyright (c) Microsoft Corporation.  All rights reserved.
//
//
// Use of this source code is subject to the terms of the Microsoft end-user
// license agreement (EULA) under which you licensed this SOFTWARE PRODUCT.
// If you did not accept the terms of the EULA, you are not authorized to use
// this source code. For a copy of the EULA, please see the LICENSE.RTF on your
// install media.
//
//------------------------------------------------------------------------------
//
//  Copyright (C) 2007-2009, Freescale Semiconductor, Inc. All Rights Reserved.
//  THIS SOURCE CODE, AND ITS USE AND DISTRIBUTION, IS SUBJECT TO THE TERMS
//  AND CONDITIONS OF THE APPLICABLE LICENSE AGREEMENT
//
//------------------------------------------------------------------------------
//
//  File:  NANDtypes.h
//
//  Contains definitions for FMD impletation of NAND flash memory device.
//
//------------------------------------------------------------------------------
#ifndef __NAND_TYPES_H__
#define __NAND_TYPES_H__

//If changing the array of structures ChipInfo please update ChipInfoBizAddon also
NandChipInfo ChipInfo[] = 
{
    //NAND01GW3B2C tested
    {
        {NAND, 1024, 2048 * 64, 64, 2048},          //FlashInfo   NAND/NOR, NumBlocks, BytesPerBlock, SectorsPerBlock, BytesPerSector
        {0x20, 0xF1, 0x00, 0x1D},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles	flash erase address cycle
        5,                                          //BYTE        ChipAddrCycleNum	flash access address cycle
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                         //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                            //NANDTiming  DataSetup=15ns, DataHold=5ns, AddressSetup=15ns, DataSample=20ns
    },
    //MT29F1G08ABADA tested
    {
        {NAND, 1024, 2048 * 64, 64, 2048},          //FlashInfo   NAND/NOR, NumBlocks, BytesPerBlock, SectorsPerBlock, BytesPerSector
        {0x2C, 0xF1, 0x80, 0x95},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles	flash erase address cycle soll 2 ???
        5,                                          //BYTE        ChipAddrCycleNum	flash access address cycle soll 4 ??? 
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                         //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                            //NANDTiming  DataSetup, DataHold, AddressSetup, DataSample ???
    },
    //K9F1G08U0D tested
    {
        {NAND, 1024, 2048 * 64, 64, 2048},          //FlashInfo   NAND/NOR, NumBlocks, BytesPerBlock, SectorsPerBlock, BytesPerSector
        {0xEC, 0xF1, 0x00, 0x15},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles; flash erase address cycle	soll 2 ???
        5,                                          //BYTE        ChipAddrCycleNum; flash access address cycle soll	4 ???
        8,                                          //BYTE        DataWidth
        2,                                          //BYTE        BBMarkNum
        {0,1},                                      //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                         //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                             //NANDTiming  DataSetup, DataHold, AddressSetup, DataSample ???
    },
    //TC58NVG0S3ETAI0 tested
    {
        {NAND, 1024, 2048 * 64, 64, 2048},          //FlashInfo   NAND/NOR, NumBlocks, BytesPerBlock, SectorsPerBlock, BytesPerSector
        {0x98, 0xD1, 0x00, 0x11},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles; flash erase address cycle	soll 2 ???
        5,                                          //BYTE        ChipAddrCycleNum; flash access address cycle soll	4 ???
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                         //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                             //NANDTiming  DataSetup, DataHold, AddressSetup, DataSample ???
    },
    //K9F2G08U0C tested
    {
        {NAND, 2048, 2048 * 64, 64, 2048},          //FlashInfo   NAND/NOR, NumBlocks, BytesPerBlock, SectorsPerBlock, BytesPerSector
        {0xEC, 0xDA, 0x10, 0x95},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles; flash erase address cycle	soll 2 ???
        5,                                          //BYTE        ChipAddrCycleNum; flash access address cycle soll	4 ???
        8,                                          //BYTE        DataWidth
        2,                                          //BYTE        BBMarkNum
        {0,1},                                      //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                         //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                             //NANDTiming  DataSetup, DataHold, AddressSetup, DataSample ???
    },
# if 0
    //MT29F16G08
    {
        {NAND, 4096, 4096 * 128, 128, 4096},        //FlashInfo   fi; 
        {0x2C, 0xD5, 0x94, 0x3e},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles
        5,                                          //BYTE        ChipAddrCycleNum
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        218,                                        //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                            //NANDTiming  timings
    },
    //MT29F8G08
    {
        {NAND, 4096, 2048 * 128, 128, 2048},        //FlashInfo   fi;     
        {0x2C, 0xD3, 0x94, 0x2d},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles
        5,                                          //BYTE        ChipAddrCycleNum
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        64,                                        //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {25, 16, 25, 20}                             //NANDTiming  timings
    },
    //MT29F16G08DAA
    {
        {NAND, 4096, 4096 * 64, 64, 4096},        //FlashInfo   fi;     
        {0x2C, 0xD3, 0x90, 0x2e},                   //BYTE        NANDCode[NANDID_LENGTH]
        3,                                          //BYTE        NumBlockCycles
        5,                                          //BYTE        ChipAddrCycleNum
        8,                                          //BYTE        DataWidth
        1,                                          //BYTE        BBMarkNum
        {0},                                        //BYTE        BBMarkPage
        6,                                          //BYTE        StatusBusyBit
        0,                                          //BYTE        StatusErrorBit
        218,                                        //WORD        SpareDataLength
        0x70,                                       //BYTE        CmdReadStatus
        0x00,                                       //BYTE        CmdRead1
        0x30,                                       //BYTE        CmdRead2
        0x90,                                       //BYTE        CmdReadId
        0xff,                                       //BYTE        CmdReset
        0x80,                                       //BYTE        CmdWrite1
        0x10,                                       //BYTE        CmdWrite2
        0x60,                                       //BYTE        CmdErase1
        0xD0,                                       //BYTE        CmdErase2
        {11, 8, 15, 20}                             //NANDTiming  timings
    },
#endif
};

// Bizerba Addon NAND-Flash Info 
NandChipInfoBizAddon ChipInfoBizAddon[] = 
{
    //NAND01GW3B2C tested
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //MT29F1G08ABADA tested
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //K9F1G08U0D tested
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //TC58NVG0S3ETAI0 tested
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //K9F2G08U0D tested
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
#if 0
    //MT29F16G08
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //MT29F8G08
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
    //MT29F16G08DAA
    {
        464,                                        //WORD        BBIMainAddr
        FALSE,                                      //BYTE        ILSupport
        1,                                          //BYTE        ClusterCount
    },
#endif
};

#endif    // __NAND_TYPES_H__

