
/**
 *
 * \file canod.xc
 *
 * \brief managing object dictionary
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

#include "canod.h"
#include "canod_datatypes.h"
#include "ethercat_config.h"
#include <xs1.h>

/* static object dictionary */

/*
 * supported object dictionary indexes:
 * - 0x0000 .. 0x0037                        - default data types
 * - 0x1000, 0x1018,                         - device identity
 * - 0x1600, 0x1601,                         - PDO Mapping rx
 * - 0x1A00, 0x1A01,                         - PDO Mapping tx
 * - 0x1C00, 0x1C10, 0x1C11, 0x1C12, 0x1C13, - SyncManager settings
 * - 0x1C30, 0x1C31, 0x1C32, 0x1C33          - SyncManager synchronisation
 *
 * A future version of this module will support device profiles like EDS or similar.
 */

/* object descriptions */
static struct _sdoinfo_object_description SDO_Info_Objects[] =  {
	{ 0x1000, DEFTYPE_UNSIGNED32, 0, CANOD_TYPE_VAR , "Device Type" },
	{ 0x1018, DEFSTRUCT_IDENTITY, 4, CANOD_TYPE_RECORD, "Identity" },
	{ 0x1C00, DEFTYPE_UNSIGNED8,  4, CANOD_TYPE_ARRAY, "Sync Manager Communication Type" },
#if CIA402
	{ 0x1600, DEFSTRUCT_PDO_MAPPING, 5, CANOD_TYPE_RECORD, "Rx PDO Mapping" },
	{ 0x1A00, DEFSTRUCT_PDO_MAPPING, 5, CANOD_TYPE_RECORD, "Tx PDO Mapping" },
#else
	{ 0x1600, DEFSTRUCT_PDO_MAPPING, 2, CANOD_TYPE_RECORD, "Rx PDO Mapping" },
	{ 0x1A00, DEFSTRUCT_PDO_MAPPING, 2, CANOD_TYPE_RECORD, "Tx PDO Mapping" },
#endif
	/* FIXME add 0x1C1x Syncmanager x PDO Assignment */
	{ 0x1C10, DEFTYPE_UNSIGNED16, 0, CANOD_TYPE_ARRAY, "SM0 PDO Assing" },
	{ 0x1C11, DEFTYPE_UNSIGNED16, 0, CANOD_TYPE_ARRAY, "SM1 PDO Assing" },
	{ 0x1C12, DEFTYPE_UNSIGNED16, 1, CANOD_TYPE_ARRAY, "SM2 PDO Assing" },
	{ 0x1C13, DEFTYPE_UNSIGNED16, 1, CANOD_TYPE_ARRAY, "SM3 PDO Assing" },
	/* assigned PDO objects */
#ifndef CIA402
	{ 0x6000, DEFTYPE_UNSIGNED16, 2, CANOD_TYPE_ARRAY, "Rx PDO Assingnment" },
	{ 0x7000, DEFTYPE_UNSIGNED16, 2, CANOD_TYPE_ARRAY, "Tx PDO Assingnment" },
#endif
#ifdef CIA402
	{ CIA402_CONTROLWORD, DEFTYPE_UNSIGNED16, 0, CANOD_TYPE_VAR, "Controlword" },
	{ CIA402_STATUSWORD, DEFTYPE_UNSIGNED16, 0, CANOD_TYPE_VAR, "Statusword" },
	{ CIA402_OP_MODES, DEFTYPE_INTEGER8, 0, CANOD_TYPE_VAR, "Modes of Operation" }, /* ??? correct type? */
	{ CIA402_OP_MODES_DISP, DEFTYPE_INTEGER8, 0, CANOD_TYPE_VAR, "Modes of Operation Display" }, /* ??? correct type? */
	{ CIA402_POSITION_VALUE, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Position Value"},
	{ CIA402_FOLLOWING_ERROR_WINDOW,   DEFTYPE_UNSIGNED32, 0, CANOD_TYPE_VAR, "Following Error Window"},
	{ CIA402_FOLLOWING_ERROR_TIMEOUT,  DEFTYPE_UNSIGNED16, 0, CANOD_TYPE_VAR, "Following Error Timeout"},
	{ CIA402_VELOCITY_VALUE, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Position Value"},
	{ CIA402_TARGET_TORQUE, DEFTYPE_INTEGER16, 0, CANOD_TYPE_VAR, "Target Torque"},
	{ CIA402_TORQUE_VALUE, DEFTYPE_INTEGER16, 0, CANOD_TYPE_VAR, "Torque actual Value"},
	{ CIA402_TARGET_POSITION, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Target Position" },
	{ CIA402_POSITION_RANGELIMIT,       DEFTYPE_INTEGER32, 2, CANOD_TYPE_ARRAY, "Postition Range Limits"},
	{ CIA402_SOFTWARE_POSITION_LIMIT, DEFTYPE_INTEGER32, 2, CANOD_TYPE_ARRAY, "Software Postition Range Limits"},
	{ CIA402_VELOCITY_OFFSET, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Velocity Offset" },
	{ CIA402_TORQUE_OFFSET, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Torque Offset" },
	{ CIA402_INTERPOL_TIME_PERIOD, 0x80/*???*/, 2, CANOD_TYPE_RECORD, "Interpolation Time Period"},
	{ CIA402_FOLLOWING_ERROR,           DEFTYPE_UNSIGNED32, 0, CANOD_TYPE_VAR , "Following Error"}, /* no object description available but recommendet in csp, csv, cst mode*/
	{ CIA402_TARGET_VELOCITY, DEFTYPE_INTEGER32, 0, CANOD_TYPE_VAR, "Target Velocity" },
	{ CIA402_SUPPORTED_DRIVE_MODES, DEFTYPE_UNSIGNED32, 0, CANOD_TYPE_VAR, "Supported drive modes" },
	/* FIXME new objects, add to object description index */
	{ CIA402_SENSOR_SELECTION_CODE,     DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Sensor Selection Mode" },
	{ CIA402_MAX_TORQUE,                DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Max Torque" },
	{ CIA402_MAX_CURRENT,               DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Max Current" },
	{ CIA402_MOTOR_RATED_CURRENT,       DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "Motor Rated Current" },
	{ CIA402_MOTOR_RATED_TORQUE,        DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "Motor Rated Torque" },
	{ CIA402_HOME_OFFSET,               DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Home Offset" },
	{ CIA402_POLARITY,                  DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Polarity" },
	{ CIA402_MAX_PROFILE_VELOCITY,      DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Max Profile Velocity" },
	{ CIA402_MAX_MOTOR_SPEED,           DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "Max Profile Speed" },
	{ CIA402_PROFILE_VELOCITY,          DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Profile Velocity" },
	{ CIA402_END_VELOCITY,              DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "End Velocity" },
	{ CIA402_PROFILE_ACCELERATION,      DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Profile Acceleration" },
	{ CIA402_PROFILE_DECELERATION,      DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Profile Deceleration" },
	{ CIA402_QUICK_STOP_DECELERATION,   DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Quick Stop Deceleration" },
	{ CIA402_MOTION_PROFILE_TYPE,       DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Motion Profile Type" },
	{ CIA402_TORQUE_SLOPE,              DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "Torque Slope" },
	{ CIA402_TORQUE_PROFILE_TYPE,       DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Torque Profile Type" },
	{ CIA402_POSITION_ENC_RESOLUTION,   DEFTYPE_UNSIGNED16,  0, CANOD_TYPE_VAR,   "Position Encoder Resolution" },
	{ CIA402_GEAR_RATIO,                DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Gear Ratio" },
	{ CIA402_MAX_ACCELERATION,      	DEFTYPE_INTEGER32,   0, CANOD_TYPE_VAR,   "Max Acceleration" },
	{ CIA402_POSITIVE_TORQUE_LIMIT,     DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Positive Torque Limit" },
	{ CIA402_NEGATIVE_TORQUE_LIMIT,     DEFTYPE_INTEGER16,   0, CANOD_TYPE_VAR,   "Negative Torque Limit" },

	{ CIA402_MOTOR_TYPE,                DEFTYPE_UNSIGNED16,  0, CANOD_TYPE_VAR, "Motor Type" },
	/* the following objects are vendor specific and defined by CiA402_Objects.xlsx */
	{ CIA402_MOTOR_SPECIFIC,            DEFSTRUCT_VENDOR_MOTOR, 6, CANOD_TYPE_RECORD, "Motor Specific Settings" }, /* Sub 01 = nominal current
	                                          Sub 02 = ???
						  Sub 03 = pole pair number
						  Sub 04 = max motor speed
						  sub 05 = motor thermal constant
						  sub 06 = motor torque constant */
	{ CIA402_CURRENT_GAIN,              DEFTYPE_INTEGER32,   3, CANOD_TYPE_ARRAY, "Current Gain" }, /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */
	{ CIA402_VELOCITY_GAIN,             DEFTYPE_INTEGER32,   3, CANOD_TYPE_ARRAY, "Velocity Gain" }, /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */
	{ CIA402_POSITION_GAIN,             DEFTYPE_INTEGER32,   3, CANOD_TYPE_ARRAY, "Position Gain" }, /* sub 1 = p-gain; sub 2 = i-gain; sub 3 = d-gain */
	{ CIA402_POSITION_OFFSET,           DEFTYPE_UNSIGNED32,  0, CANOD_TYPE_VAR,   "Postion Offset" }, /* FIXME add this to OD */
#endif
	{ 0, 0, 0, 0, {0}}
};

#define PDOMAPING(idx,sub,bit)    ( ((unsigned)idx<<16) | ((unsigned)sub<<8) | bit )

/* Note on object access:
 * Bit 0: read in pre op state
 * Bit 1: read in safe op state
 * bit 2: read in op state
 * bit 3: write in pre op state
 * bit 4: write in safe op state
 * bit 5: write in op state
 * bit 6: mapable in rx pdo
 * bit 7: mapable in tx pdo
 * bit 8: obj can be used for backup
 * bit 9: obj can be used for setting
 * bit 10-15: reserved
 */

/* static list of od entries description and value */
struct _sdoinfo_entry_description SDO_Info_Entries[] = {
#ifndef CIA402
	{ 0x1000, 0, 0, DEFTYPE_UNSIGNED32, 32, 0x0203, 0x00000001, "Device Type" },
#else
	/* device type value: Mode bits (8bits) | type (8bits) | device profile number (16bits)
	 *                    *                 | 0x02 (Servo) | 0x0192
	 *
	 * Mode Bits: csp, csv, cst
	 */
	{ 0x1000, 0, 0, DEFTYPE_UNSIGNED32, 32, 0x0203, 0x70020192, "Device Type" },
#endif
	/* identity object */
	{ 0x1018, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 4, "Identity" },
	{ 0x1018, 1, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x000022d2, "Vendor ID" }, /* Vendor ID (by ETG) */
	{ 0x1018, 2, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x00000201, "Product Code" }, /* Product Code */
	{ 0x1018, 3, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x0a000002, "Revision Number" }, /* Revision Number */
	{ 0x1018, 4, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x000000dd, "Serial Number" }, /* Serial Number */
	/* FIXME special index 0xff: { 0x1018, 0xff, 0, DEFTYPE_UNSIGNED32, ..., ..., ...} */
#ifdef CIA402
	/* RxPDO Mapping */
	{ 0x1600, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 5, "Rx PDO Mapping" }, /* input */
	{ 0x1600, 1, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_CONTROLWORD,0,16), "Rx PDO Mapping Controlword" },
	{ 0x1600, 2, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_OP_MODES,0,8), "Rx PDO Mapping Opmode" },
	{ 0x1600, 3, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_TARGET_TORQUE,0,16), "Rx PDO Mapping Target Torque" },
	{ 0x1600, 4, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_TARGET_POSITION,0,32), "Rx PDO Mapping Target Position" },
	{ 0x1600, 5, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_TARGET_VELOCITY,0,32), "Rx PDO Mapping Target Velocity" },
	/* TxPDO Mapping */
	{ 0x1A00, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 5, "Tx PDO Mapping" }, /* output */
	{ 0x1A00, 1, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_STATUSWORD,0,16), "Tx PDO Mapping Statusword" },
	{ 0x1A00, 2, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_OP_MODES_DISP,0,8), "Tx PDO Mapping Modes Display" },
	{ 0x1A00, 3, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_POSITION_VALUE,0,32), "Tx PDO Mapping Position Value" },
	{ 0x1A00, 4, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_VELOCITY_VALUE,0,32), "Tx PDO Mapping Velocity Value" },
	{ 0x1A00, 5, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, PDOMAPING(CIA402_TORQUE_VALUE,0,16), "Tx PDO Mapping Torque Value" },
#else
	/* RxPDO Mapping */
	{ 0x1600, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 2, "Rx PDO Mapping" }, /* input */
	{ 0x1600, 1, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x60000120, "Rx PDO Mapping" }, /* see comment on PDO Mapping value below */
	{ 0x1600, 2, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x60000220, "Rx PDO Mapping" }, /* see comment on PDO Mapping value below */
	/* TxPDO Mapping */
	{ 0x1A00, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 2, "Tx PDO Mapping" }, /* output */
	{ 0x1A00, 1, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x70000120, "Tx PDO Mapping" }, /* see comment on PDO Mapping value below */
	{ 0x1A00, 2, 0, DEFTYPE_UNSIGNED32, 32, 0x0207, 0x70000220, "Tx PDO Mapping" }, /* see comment on PDO Mapping value below */
#endif
	/* SyncManager Communication Type */
	{ 0x1C00, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 4, "SyncManager Comm" },
	{ 0x1C00, 1, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0x01, "SyncManager Comm" }, /* mailbox receive */
	{ 0x1C00, 2, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0x02, "SyncManager Comm" }, /* mailbox send */
	{ 0x1C00, 3, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0x03, "SyncManager Comm" }, /* PDO in (bufferd mode) */
	{ 0x1C00, 4, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0x04, "SyncManager Comm" }, /* PDO output (bufferd mode) */
	/* Tx PDO and Rx PDO assignments */
	{ 0x1C10, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0, "SyncMan 0 assignment"}, /* assignment of SyncMan 0 */
	{ 0x1C11, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 0, "SyncMan 1 assignment"}, /* assignment of SyncMan 1 */
	{ 0x1C12, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 1, "SyncMan 2 assignment"}, /* assignment of SyncMan 2 */
	{ 0x1C12, 1, 0, DEFTYPE_UNSIGNED16, 16, 0x0207, 0x1600, "SyncMan 2 assignment" },
	{ 0x1C13, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 1, "SyncMan 3 assignment"}, /* assignment of SyncMan 3 */
	{ 0x1C13, 1, 0, DEFTYPE_UNSIGNED16, 16, 0x0207, 0x1A00, "SyncMan 3 assignment" },
#ifndef CIA402
	/* objects describing RxPDOs */
	{ 0x6000, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 2, "Rx PDOs" },
	{ 0x6000, 1, 0, DEFTYPE_UNSIGNED16, 16, 0x0247, 0x0001, "Rx PDOs" }, /* the values are stored in application */
	{ 0x6000, 2, 0, DEFTYPE_UNSIGNED16, 16, 0x0247, 0x0002, "Rx PDOs" }, /* the values are stored in application */
	/* objects describing TxPDOs */
	{ 0x7000, 0, 0, DEFTYPE_UNSIGNED8, 8, 0x0207, 2, "Tx PDOs" },
	{ 0x7000, 1, 0, DEFTYPE_UNSIGNED16, 16, 0x0287, 0x0010, "Tx PDOs" }, /* the values are stored in application */
	{ 0x7000, 2, 0, DEFTYPE_UNSIGNED16, 16, 0x0287, 0x0020, "Tx PDOs" }, /* the values are stored in application */
#endif
	/* CiA objects */
	/* index, sub, value info, datatype, bitlength, object access, value, name */
	{ CIA402_CONTROLWORD, 0, 0, DEFTYPE_UNSIGNED16, 16, 0x023f |COD_RXPDO_MAPABLE|COD_WR_OP_STATE, 0, "CiA402 Control Word" }, /* map to PDO */
	{ CIA402_STATUSWORD, 0, 0, DEFTYPE_UNSIGNED16, 16, 0x023f|COD_TXPDO_MAPABLE, 0, "CiA402 Status Word" },  /* map to PDO */
	{ CIA402_SUPPORTED_DRIVE_MODES, 0, 0, DEFTYPE_UNSIGNED32, 32, 0x023f, 0x0280 /* csv, csp, cst */, "Supported drive modes" },
	{ CIA402_OP_MODES, 0, 0, DEFTYPE_INTEGER8, 8, 0x023f|COD_RXPDO_MAPABLE|COD_WR_OP_STATE/* writeable? */, CIA402_OP_MODE_CSP, "Operating mode" },
	{ CIA402_OP_MODES_DISP, 0, 0, DEFTYPE_INTEGER8, 8, 0x023f|COD_TXPDO_MAPABLE, CIA402_OP_MODE_CSP, "Operating mode" },
	{ CIA402_POSITION_VALUE, 0, 0,  DEFTYPE_INTEGER32, 32, 0x023f|COD_TXPDO_MAPABLE, 0, "Position Value" }, /* csv, csp */
	{ CIA402_FOLLOWING_ERROR_WINDOW, 0, 0, DEFTYPE_UNSIGNED32, 32, 0x023f, 0, "Following Error Window"}, /* csp */
	{ CIA402_FOLLOWING_ERROR_TIMEOUT, 0, 0, DEFTYPE_UNSIGNED16, 16, 0x2037, 0, "Following Error Timeout"}, /* csp */
	{ CIA402_VELOCITY_VALUE, 0, 0, DEFTYPE_INTEGER32, 32, 0x023f|COD_TXPDO_MAPABLE, 0, "Velocity Value"}, /* csv */
	{ CIA402_TARGET_TORQUE, 0, 0, DEFTYPE_INTEGER16, 16, 0x023f|COD_RXPDO_MAPABLE|COD_WR_OP_STATE, 0, "Target Torque"}, /* cst */
	{ CIA402_TORQUE_VALUE, 0, 0, DEFTYPE_INTEGER16, 16, 0x023f|COD_TXPDO_MAPABLE, 0, "Torque actual Value"}, /* csv, cst */
	{ CIA402_TARGET_POSITION, 0, 0, DEFTYPE_INTEGER32, 32, 0x023f|COD_RXPDO_MAPABLE|COD_WR_OP_STATE, 0, "Target Position" }, /* csp */
	{ CIA402_POSITION_RANGELIMIT, 0, 0, DEFTYPE_INTEGER32, 32, 0x0207, 2, "Postition Range Limits"}, /* csp */
	{ CIA402_POSITION_RANGELIMIT, 1, 0, DEFTYPE_INTEGER32, 32, 0x023f, 0, "Min Postition Range Limit"},
	{ CIA402_POSITION_RANGELIMIT, 2, 0, DEFTYPE_INTEGER32, 32, 0x023f, 0, "Max Postition Range Limit"},
	{ CIA402_SOFTWARE_POSITION_LIMIT, 0, 0,  DEFTYPE_INTEGER32, 32, 0x0207, 2, "Software Postition Range Limits"}, /* csp */
	{ CIA402_SOFTWARE_POSITION_LIMIT, 1, 0,  DEFTYPE_INTEGER32, 32, 0x023f, 0, "Min Software Postition Range Limit"},
	{ CIA402_SOFTWARE_POSITION_LIMIT, 2, 0,  DEFTYPE_INTEGER32, 32, 0x023f, 0, "Max Software Postition Range Limit"},
	{ CIA402_VELOCITY_OFFSET, 0, 0, DEFTYPE_INTEGER32, 32, 0x023f, 0, "Velocity Offset" }, /* csp */
	{ CIA402_TORQUE_OFFSET, 0, 0, DEFTYPE_INTEGER32, 32, 0x023f, 0, "Torque Offset" }, /* csv, csp */
	{ CIA402_INTERPOL_TIME_PERIOD, 0, 0, DEFTYPE_INTEGER32, 32, 0x0207, 2, "Interpolation Time Period"}, /* csv, csp, cst */
	{ CIA402_INTERPOL_TIME_PERIOD, 1, 0, DEFTYPE_INTEGER32, 32, 0x023f, 1, "Interpolation Time Unit"}, /* value range: 1..255msec */
	{ CIA402_INTERPOL_TIME_PERIOD, 2, 0, DEFTYPE_INTEGER32, 32, 0x023f, -3, "Interpolation Time Index"}, /* value range: -3, -4 (check!)*/
	{ CIA402_FOLLOWING_ERROR,         0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Following Error" },
	{ CIA402_TARGET_VELOCITY, 0, 0,  DEFTYPE_INTEGER32, 32, 0x022f|COD_RXPDO_MAPABLE|COD_WR_OP_STATE, 0, "Target Velocity" }, /* csv */
	/* FIXME new objects, change description accordingly */
	{ CIA402_SENSOR_SELECTION_CODE,   0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Sensor Selection Mode" },
	{ CIA402_MAX_TORQUE,              0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Max Torque" },
	{ CIA402_MAX_CURRENT,             0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Max Current" },
	{ CIA402_MOTOR_RATED_CURRENT,     0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "Motor Rated Current" },
	{ CIA402_MOTOR_RATED_TORQUE,      0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "Motor Rated Torque" },
	{ CIA402_HOME_OFFSET,             0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Home Offset" },
	{ CIA402_POLARITY,                0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Polarity" },
	{ CIA402_MAX_PROFILE_VELOCITY,    0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Max Profile Velocity" },
	{ CIA402_MAX_MOTOR_SPEED,         0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "Max Profile Speed" },
	{ CIA402_PROFILE_VELOCITY,        0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Profile Velocity" },
	{ CIA402_END_VELOCITY,            0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "End Velocity" },
	{ CIA402_PROFILE_ACCELERATION,    0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Profile Acceleration" },
	{ CIA402_PROFILE_DECELERATION,    0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Profile Deceleration" },
	{ CIA402_QUICK_STOP_DECELERATION, 0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Quick Stop Deceleration" },
	{ CIA402_MOTION_PROFILE_TYPE,     0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Motion Profile Type" },
	{ CIA402_TORQUE_SLOPE,            0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "Torque Slope" },
	{ CIA402_TORQUE_PROFILE_TYPE,     0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Torque Profile Type" },
	{ CIA402_POSITION_ENC_RESOLUTION, 0, 0, DEFTYPE_UNSIGNED16,  16, 0x023f, 0,   "Position Encoder Resolution" },
	{ CIA402_GEAR_RATIO,              0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Gear Ratio" },
	{ CIA402_MAX_ACCELERATION,    	  0, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Max Acceleration" },
	{ CIA402_POSITIVE_TORQUE_LIMIT,   0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Positive Torque Limit" },
	{ CIA402_NEGATIVE_TORQUE_LIMIT,   0, 0, DEFTYPE_INTEGER16,   16, 0x023f, 0,   "Negative Torque Limit" },
	{ CIA402_MOTOR_TYPE,              0, 0, DEFTYPE_UNSIGNED16,  16, 0x023f, 0,   "Motor Type" },
	/* the following objects are vendor specific and defined by CiA402_Objects.xlsx */
	{ CIA402_MOTOR_SPECIFIC,          0, 0, DEFTYPE_UNSIGNED8,    8, 0x0207, 6,   "Motor Specific Settings" },
	{ CIA402_MOTOR_SPECIFIC,          1, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific Nominal Current" },
	{ CIA402_MOTOR_SPECIFIC,          2, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific Setting" }, /* ??? */
	{ CIA402_MOTOR_SPECIFIC,          3, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific pole pair number" },
	{ CIA402_MOTOR_SPECIFIC,          4, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific Max Speed" },
	{ CIA402_MOTOR_SPECIFIC,          5, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific Thermal Time Constant" },
	{ CIA402_MOTOR_SPECIFIC,          6, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Motor Specific Torque Constant" },
	{ CIA402_CURRENT_GAIN,            0, 0, DEFTYPE_INTEGER8,     8, 0x0207, 3,   "Current Gain" },
	{ CIA402_CURRENT_GAIN,            1, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Current P-Gain" },
	{ CIA402_CURRENT_GAIN,            2, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Current I-Gain" },
	{ CIA402_CURRENT_GAIN,            3, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Current D-Gain" },
	{ CIA402_VELOCITY_GAIN,           0, 0, DEFTYPE_INTEGER8,     8, 0x0207, 3,   "Velocity Gain" },
	{ CIA402_VELOCITY_GAIN,           1, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Velocity P-Gain" },
	{ CIA402_VELOCITY_GAIN,           2, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Velocity I-Gain" },
	{ CIA402_VELOCITY_GAIN,           3, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Velocity D-Gain" },
	{ CIA402_POSITION_GAIN,           0, 0, DEFTYPE_INTEGER8,     8, 0x0207, 3,   "Position Gain" },
	{ CIA402_POSITION_GAIN,           1, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Position P-Gain" },
	{ CIA402_POSITION_GAIN,           2, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Position I-Gain" },
	{ CIA402_POSITION_GAIN,           3, 0, DEFTYPE_INTEGER32,   32, 0x023f, 0,   "Position D-Gain" },
	{ CIA402_POSITION_OFFSET,         0, 0, DEFTYPE_UNSIGNED32,  32, 0x023f, 0,   "Postion Offset" },
	{ 0, 0, 0, 0, 0, 0, 0, "\0" }
};

/* local */

static int get_minvalue(unsigned datatype)
{
	switch (datatype) {
	case DEFTYPE_BOOLEAN:
		return 0;
	case DEFTYPE_INTEGER8:
		return 0xff;
	case DEFTYPE_INTEGER16:
		return 0xffff;
	case DEFTYPE_INTEGER32:
		return 0xffffffff;
	case DEFTYPE_UNSIGNED8:
		return 0;
	case DEFTYPE_UNSIGNED16:
		return 0;
	case DEFTYPE_UNSIGNED32:
		return 0;
	default:
		return 0;
	}

	return 0;
}

static int get_maxvalue(unsigned datatype)
{
	switch (datatype) {
	case DEFTYPE_BOOLEAN:
		return 1;
	case DEFTYPE_INTEGER8:
		return 0x7f;
	case DEFTYPE_INTEGER16:
		return 0x7fff;
	case DEFTYPE_INTEGER32:
		return 0x7fffffff;
	case DEFTYPE_UNSIGNED8:
		return 0xff;
	case DEFTYPE_UNSIGNED16:
		return 0xffff;
	case DEFTYPE_UNSIGNED32:
		return 0xffffffff;
	default:
		return 0;
	}

	return 0;
}



/* API implementation */

int canod_get_all_list_length(unsigned length[])
{
	/* FIXME correct length of all subsections */
	length[0] = sizeof(SDO_Info_Objects)/sizeof(SDO_Info_Objects[0]);
	length[1] = 0;
	length[2] = 0;
	length[3] = 0;
	length[4] = 0;

	return 0;
}

/* FIXME except for all the list length returns length 0 */
int canod_get_list_length(unsigned listtype)
{
	int length = 0;

	switch (listtype) {
	case CANOD_LIST_ALL:
		length = sizeof(SDO_Info_Objects)/sizeof(SDO_Info_Objects[0]);
		break;

	case CANOD_LIST_RXPDO_MAP:
		break;

	case CANOD_LIST_TXPDO_MAP:
		break;

	case CANOD_LIST_REPLACE:
		break;

	case CANOD_LIST_STARTUP:
		break;
	
	default:
		return 0;
	};

	return length;
}

/* FIXME implement and check other list lengths. */
int canod_get_list(unsigned list[], unsigned size, unsigned listtype)
{
	int length, i;

	switch (listtype) {
	case CANOD_LIST_ALL:
		length = sizeof(SDO_Info_Objects)/sizeof(SDO_Info_Objects[0])-1;

		for (i=0; i<length && i<size; i++) {
			list[i] = SDO_Info_Objects[i].index;
		}

		break;

	case CANOD_LIST_RXPDO_MAP:
		break;

	case CANOD_LIST_TXPDO_MAP:
		break;

	case CANOD_LIST_REPLACE:
		break;

	case CANOD_LIST_STARTUP:
		break;
	
	default:
		return 0;
	};

	return length;
}

int canod_get_object_description(struct _sdoinfo_object_description &obj, unsigned index)
{
	int i = 0, k;

	for (i=0; i<sizeof(SDO_Info_Objects)/sizeof(SDO_Info_Objects[0]); i++) {
		if (SDO_Info_Objects[i].index == index) {
			obj.index = SDO_Info_Objects[i].index;
			obj.dataType = SDO_Info_Objects[i].dataType;
			obj.maxSubindex = SDO_Info_Objects[i].maxSubindex;
			obj.objectCode = SDO_Info_Objects[i].objectCode;
			for (k=0; k<50; k++) { /* FIXME set a define for max string length */
				obj.name[k] = SDO_Info_Objects[i].name[k];
			}
			break;
		}

		if (SDO_Info_Objects[i].index == 0x0) {
			return 1; /* object not found */
		}
	}

	return 0;
}

int canod_get_entry_description(unsigned index, unsigned subindex, unsigned valueinfo, struct _sdoinfo_entry_description &desc)
{
	struct _sdoinfo_entry_description entry;
	int i,k;

	for (i=0; i<SDO_Info_Entries[i].index != 0x0; i++) {
		if ((SDO_Info_Entries[i].index == index) && (SDO_Info_Entries[i].subindex == subindex))
			break;
	}

	if (SDO_Info_Entries[i].index == 0x0)
		return -1; /* Entry object not found */

	/* FIXME implement entry_description */
	desc.index = index;
	desc.subindex = subindex;
	desc.valueInfo = valueinfo;

	desc.dataType = SDO_Info_Entries[i].dataType;
	desc.bitLength = SDO_Info_Entries[i].bitLength;
	desc.objectAccess = SDO_Info_Entries[i].objectAccess;

#if 1
	desc.value = SDO_Info_Entries[i].value;
#else /* wrong assumption of packet content? */
	switch (valueinfo) {
	case CANOD_VALUEINFO_UNIT:
		desc.value = 0; /* unit type currently unsupported */
		break;

	case CANOD_VALUEINFO_DEFAULT:
		desc.value = SDO_Info_Entries[i].value;
		break;
	case CANOD_VALUEINFO_MIN:
		desc.value = get_minvalue(desc.dataType);
		break;

	case CANOD_VALUEINFO_MAX:
		desc.value = get_maxvalue(desc.dataType);
		break;
	default:
		/* empty response */
		desc.value = 0;
		break;
	}
#endif

	/* copy name */
	for (k=0; k<50 && SDO_Info_Entries[i].name[k] != '\0'; k++) {
		desc.name[k] = SDO_Info_Entries[i].name[k];
	}
	return 0;
}

int canod_get_entry(unsigned index, unsigned subindex, unsigned &value, unsigned &bitlength)
{
	int i;
	unsigned mask = 0xffffffff;

	/* FIXME handle special subindex 0xff to request object type -> see also CiA 301 */

	for (i=0; SDO_Info_Entries[i].index != 0x0; i++) {
		if (SDO_Info_Entries[i].index == index
		    && SDO_Info_Entries[i].subindex == subindex) {
			switch (SDO_Info_Entries[i].bitLength) {
			case 8:
				mask = 0xff;
				break;
			case 16:
				mask = 0xffff;
				break;
			case 32:
				mask = 0xffffffff;
				break;
			default:
				break;
			}
			value = SDO_Info_Entries[i].value & mask;
			bitlength = SDO_Info_Entries[i].bitLength; /* alternative bitLength */

			return 0;
		}
	}

	return 1; /* not found */
}

int canod_set_entry(unsigned index, unsigned subindex, unsigned value, unsigned type)
{
	unsigned mask = 0xffffffff;

	for (int i=0; SDO_Info_Entries[i].index != 0x0; i++) {
		if (SDO_Info_Entries[i].index == index
				&& SDO_Info_Entries[i].subindex == subindex) {
			switch (SDO_Info_Entries[i].bitLength) {
			case 8:
				mask = 0xff;
				break;
			case 16:
				mask = 0xffff;
				break;
			case 32:
				mask = 0xffffffff;
				break;
			default:
				break;
			}
			SDO_Info_Entries[i].value = value & mask;
			return 0;
		}
	}

	return 1; /* cannot set value */
}

