
/**
 *
 * \file canod.h
 *
 * \brief Handle CAN object dictionary
 *
 * Copyright (c) 2014, Synapticon GmbH
 * All rights reserved.
 * Author: Frank Jeschke <jeschke@fjes.de>
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice, this
 *    list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Execution of this software or parts of it exclusively takes place on hardware
 *    produced by Synapticon GmbH.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 * ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * The views and conclusions contained in the software and documentation are those
 * of the authors and should not be interpreted as representing official policies,
 * either expressed or implied, of the Synapticon GmbH.
 *
 */

/* Roadmap: this object dictionary should be more dynamically and more general */

#ifndef CANOD_H
#define CANOD_H

/* SDO Information operation code */
#define CANOD_OP_

/* list of dictionary lists identifiers */
#define CANOD_GET_NUMBER_OF_OBJECTS   0x00
#define CANOD_ALL_OBJECTS             0x01
#define CANOD_RXPDO_MAPABLE           0x02
#define CANOD_TXPDO_MAPABLE           0x03
#define CANOD_DEVICE_REPLACEMENT      0x04
#define CANOD_STARTUP_PARAMETER       0x05

/* possible object types of dictionary objects */
#define CANOD_TYPE_DOMAIN     0x0
#define CANOD_TYPE_DEFTYPE    0x5
#define CANOD_TYPE_DEFSTRUCT  0x6
#define CANOD_TYPE_VAR        0x7
#define CANOD_TYPE_ARRAY      0x8
#define CANOD_TYPE_RECORD     0x9

/* value info values */
#define CANOD_VALUEINFO_UNIT      0x08
#define CANOD_VALUEINFO_DEFAULT   0x10
#define CANOD_VALUEINFO_MIN       0x20
#define CANOD_VALUEINFO_MAX       0x40

/* list types */
#define CANOD_LIST_ALL        0x01  ///< all objects
#define CANOD_LIST_RXPDO_MAP  0x02  ///< only objects which are mappable in a RxPDO
#define CANOD_LIST_TXPDO_MAP  0x03  ///< only objects which are mappable in a TxPDO
#define CANOD_LIST_REPLACE    0x04  ///< objects which has to stored for a device replacement ???
#define CANOD_LIST_STARTUP    0x05  ///< objects which can be used as startup parameter

/* object dictionary address defines for CIA 402 */
#define CIA402_CONTROLWORD              0x6040 /* RPDO */
#define CIA402_STATUSWORD               0x6041 /* TPDO */
#define CIA402_OP_MODES                 0x6060 /* RPDO */
#define CIA402_OP_MODES_DISP            0x6061 /* TPDO */

#define CIA402_POSITION_VALUE           0x6064 /* TPDO - used with csp and csv*/
#define CIA402_FOLLOWING_ERROR_WINDOW   0x6065 /* used with csp */
#define CIA402_FOLLOWING_ERROR_TIMEOUT  0x6066 /* used with csp */
#define CIA402_VELOCITY_VALUE           0x606C /* TPDO - recommended if csv is used */
#define CIA402_TARGET_TORQUE            0x6071 /* RPDO - used with cst */
#define CIA402_TORQUE_VALUE             0x6077 /* TPDO - used with csp and csv */

#define CIA402_TARGET_POSITION          0x607A /* RPDO - used with csp */
#define CIA402_POSITION_RANGELIMIT      0x607B /* used with csp */
#define CIA402_SOFTWARE_POSITION_LIMIT  0x607D /* recommended with csp */

#define CIA402_POSITION_OFFSET          0x60B0
#define CIA402_VELOCITY_OFFSET          0x60B1 /* recommended with csp */
#define CIA402_TORQUE_OFFSET            0x60B2 /* recommended with csp or csv */

#define CIA402_INTERPOL_TIME_PERIOD     0x60C2  /* recommended if csp, csv or cst is used */
#define CIA402_FOLLOWING_ERROR          0x60F4 /* TPDO - recommended if csp is used */

#define CIA402_TARGET_VELOCITY          0x60FF /* RPDO  - mandatory if csv is used */

#define CIA402_SENSOR_SELECTION_CODE    0x606A
#define CIA402_MAX_TORQUE               0x6072
#define CIA402_MAX_CURRENT              0x6073
#define CIA402_MOTOR_RATED_CURRENT      0x6075
#define CIA402_MOTOR_RATED_TORQUE       0x6076
#define CIA402_HOME_OFFSET              0x607C
#define CIA402_POLARITY                 0x607E
#define CIA402_MAX_PROFILE_VELOCITY     0x607F
#define CIA402_MAX_MOTOR_SPEED          0x6080
#define CIA402_PROFILE_VELOCITY         0x6081
#define CIA402_END_VELOCITY             0x6082
#define CIA402_PROFILE_ACCELERATION     0x6083
#define CIA402_PROFILE_DECELERATION     0x6084
#define CIA402_QUICK_STOP_DECELERATION  0x6085
#define CIA402_MOTION_PROFILE_TYPE      0x6086
#define CIA402_TORQUE_SLOPE             0x6087
#define CIA402_TORQUE_PROFILE_TYPE      0x6088
#define CIA402_POSITION_ENC_RESOLUTION  0x608F
#define CIA402_GEAR_RATIO               0x6091
#define CIA402_POSITIVE_TORQUE_LIMIT    0x60E0
#define CIA402_NEGATIVE_TORQUE_LIMIT    0x60E1
#define CIA402_MAX_ACCELERATION 		0x60C5

#define CIA402_MOTOR_TYPE               0x6402
#define CIA402_MOTOR_SPECIFIC           0x6410 /* Sub 01 = nominal current
	                                          Sub 02 = ???
						  Sub 03 = pole pair number
						  Sub 04 = max motor speed
						  sub 05 = motor torque constant */
#define CIA402_CURRENT_GAIN             0x60F6 /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */
#define CIA402_VELOCITY_GAIN            0x60F9 /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */
#define CIA402_POSITION_GAIN            0x60FB /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */



/* only if touch probe is supported */
//#define CIA402_MAX_TORQUE        0x6072 /* RPDO */
//#define CIA402_TOUCHPROBE_FUNC   0x60B8 /* RPDO */
//#define CIA402_TOUCHPROBE_STAT   0x60B9 /* TPDO */
//#define CIA402_TOUCHPROBE_VALUE  0x60BA /* TPDO - depends on touchprobe conf! */
//#define CIA402_TOUCHPROBE_VALUE  0x60BB /* TPDO - depends on touchprobe conf! */
//#define CIA402_TOUCHPROBE_VALUE  0x60BC /* TPDO - depends on touchprobe conf! */
//#define CIA402_TOUCHPROBE_VALUE  0x60BD /* TPDO - depends on touchprobe conf! */

#define CIA402_SUPPORTED_DRIVE_MODES  0x6502 /* recommendet */

/* Operating modes for use in objects CIA402_OP_MODES and CIA402_OP_MODES_DISPLAY */
#define CIA402_OP_MODE_CSP    8
#define CIA402_OP_MODE_CSV    9
#define CIA402_OP_MODE_CST   10

#ifdef __XC__
#if 0
struct _sdoinfo_service {
	unsigned opcode;                   ///< OD operation code
	unsigned incomplete;               ///< 0 - last fragment, 1 - more fragments follow
	unsigned fragments;                ///< number of fragments which follow
	unsigned char data[COE_MAX_DATA_SIZE];  ///< SDO data field
};
#endif

/* sdo information data structure - FIXME may move to canod.h */

/* FIXME: add objects which describe the mapped PDO data.
 * the best matching OD area would be at index 0x200-0x5fff (manufacturer specific profile area
 */

/** object description structure */
struct _sdoinfo_object_description {
	unsigned index; ///< 16 bit int should be sufficient
	unsigned dataType; ///< 16 bit int should be sufficient
	unsigned char maxSubindex;
	unsigned char objectCode;
	unsigned char name[50]; /* FIXME shouldn't exceed COE data section */
};

/** entry description structure */
struct _sdoinfo_entry_description {
	unsigned index; ///< 16 bit int should be sufficient
	unsigned subindex; ///< 16 bit int should be sufficient
	unsigned char valueInfo; /* depends on SDO Info: get entry description request */
	unsigned dataType;
	unsigned bitLength;
	unsigned objectAccess;
	unsigned value; ///< real data type is defined by .dataType
	unsigned char name[50];
};

/* ad valueInfo (BYTE):
 * Bit 0 - 2: reserved
 * Bit 3: unit type
 * Bit 4: default value
 * Bit 5: minimum value
 * Bit 6: maximum value
 */

/* ad objectAccess (WORD):
 * Bit 0: read access in Pre-Operational state
 * Bit 1: read access in Safe-Operational state
 * Bit 2: read access in Operational state
 * Bit 3: write access in Pre-Operational state
 * Bit 4: write access in Safe-Operational state
 * Bit 5: write access in Operational state
 * Bit 6: object is mappable in a RxPDO
 * Bit 7: object is mappable in a TxPDO
 * Bit 8: object can be used for backup
 * Bit 9: object can be used for settings
 * Bit 10 - 15: reserved
 */
#define COD_RD_PO_STATE         0x0001
#define COD_RD_SO_STATE         0x0002
#define COD_RD_OP_STATE         0x0004
#define COD_WR_PO_STATE         0x0008
#define COD_WR_SO_STATE         0x0010
#define COD_WR_OP_STATE         0x0020
#define COD_RXPDO_MAPABLE       0x0040
#define COD_TXPDO_MAPABLE       0x0080
#define COD_USED_BACKUP         0x0100
#define COD_USED_SETTINGS       0x0200

/* ad PDO Mapping value (at index 0x200[01]):
 * bit 0-7: length of the mapped objects in bits
 * bit 8-15: subindex of the mapped object
 * bit 16-32: index of the mapped object
 */


/**
 * Return the length of all five cathegories
 */
int canod_get_all_list_length(unsigned length[]);

/**
 * return the length of list of type listtype
 */
int canod_get_list_length(unsigned listtype);

/**
 * Get list of objects in the specified cathegory
 */
int canod_get_list(unsigned list[], unsigned size, unsigned listtype);

/**
 * Get description of object at index and subindex.
 */
int canod_get_object_description(struct _sdoinfo_object_description &obj, unsigned index);

/**
 * Get description of specified entry
 */
int canod_get_entry_description(unsigned index, unsigned subindex, unsigned valueinfo, struct _sdoinfo_entry_description &desc);

/**
 * Get OD entry values
 *
 * @param index
 * @param subindex
 * @param &value     read the values from this array from the object dictionary.
 * @param &type      the type of &value
 * @return 0 on success
 */
int canod_get_entry(unsigned index, unsigned subindex, unsigned &value, unsigned &type);

/**
 * Set OD entry values
 *
 * @note This function is currently unused.
 *
 * @param index
 * @param subindex
 * @param value     write the values from this array to the object dictionary.
 * @param type      the type of &value
 * @return 0 on success
 */
int canod_set_entry(unsigned index, unsigned subindex, unsigned value, unsigned type);

#endif /* __XC__*/
#endif /* CANOD_H */

