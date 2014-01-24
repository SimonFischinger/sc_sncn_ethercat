
/**
 *
 * \file canod_datatypes.h
 *
 * \brief definition of datatypes used in the object dictionary
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

#ifndef CANOD_DATATYPES_H
#define CANOD_DATATYPES_H

/* Basic Data Type Area */
#define DEFTYPE_BOOLEAN          0x0001
#define DEFTYPE_INTEGER8         0x0002
#define DEFTYPE_INTEGER16        0x0003
#define DEFTYPE_INTEGER32        0x0004
#define DEFTYPE_UNSIGNED8        0x0005
#define DEFTYPE_UNSIGNED16       0x0006
#define DEFTYPE_UNSIGNED32       0x0007
#define DEFTYPE_REAL32           0x0008
#define DEFTYPE_VISIBLE_STRING   0x0009
#define DEFTYPE_OCTET_STRING     0x000A
#define DEFTYPE_UNICODE_STRING   0x000B
#define DEFTYPE_TIME_OF_DAY      0x000C
#define DEFTYPE_TIME_DIFFERENCE  0x000D

#define DEFTYPE_DOMAIN           0x000F

#define DEFSTRUCT_PDO_MAPPING    0x0021
#define DEFSTRUCT_IDENTITY       0x0023
#define DEFSTRUCT_VENDOR_MOTOR   0x0040

#endif /* CANOD_DATATYPES_H */
