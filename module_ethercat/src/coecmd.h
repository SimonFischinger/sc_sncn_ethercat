
/**
 *
 * \file coecmd.h
 *
 * \brief Defines and definitions for applications commands to handle object
 * 			dictionary entries.
 *
 * Copyright (c) 2013, Synapticon GmbH
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

#ifndef COECMD_H
#define COECMD_H

/* Communication via channel between application and EtherCAT module.
 *
 * Main purpose is the exchange of data objects, optionaly object description
 * resp. object type (at least).
 */

#define CAN_GET_OBJECT    0x1
#define CAN_SET_OBJECT    0x2
#define CAN_OBJECT_TYPE   0x3
#define CAN_MAX_SUBINDEX  0x4

/* command structure:
 * app -> ecat/coe:
 * CAN_GET_OBJECT index.subindex 
 * ecat -> app
 * value
 *
 * CAN_SET_OBJECT index.subindex value
 * ecat->app: value | errorcode
 *
 * CAN_MAX_SUBINDEX index.00=subindex 
 * ecat->app: max_subindex
 */

#define CAN_OBJ_ADR(i,s)   (((unsigned)i<<8) | s)

/* Error symbols */

#define CAN_ERROR           0xff01
#define CAN_ERROR_UNKNOWN   0xff02

#endif /* COECMD_H */
