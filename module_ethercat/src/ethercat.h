
/**
 *
 * \file ethercat.h
 *
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

#ifndef ETHERCAT_H
#define ETHERCAT_H

#include "foe_chan.h"

#include <stdint.h>

static const char ecat_version[] = "Version 1.0";

#define DATA_REQUEST     1

enum EC_MailboxProtocolTypes {
	ERROR_PACKET=0,            ///< Error Packet
	VENDOR_BECKHOFF_PACKET,    ///< Beckhoff vendor specific packet
	EOE_PACKET,                ///< Ethernet-over-EtherCAT packet
	COE_PACKET,                ///< CAN over EtherCAT packet
	FOE_PACKET,                ///< File over EtherCAT packet
	SOE_PACKET,                ///< SoE
	VOE_PACKET=0xf             ///< Vendor specific mailbox packet
};

struct _ec_mailbox_header {
	uint16_t length;           ///< length of data area
	uint16_t address;          ///< originator address
	uint8_t  channel;          ///< =0 reserved for future use
	uint8_t  priority;         ///< 0 (lowest) to 3 (highest)
	uint8_t  type;             ///< Protocol types -> enum EC_MailboxProtocolTypes
	uint8_t  control;          ///< sequence number to detect duplicates
};

/**
 * @brief Main ethercat handler function.
 *
 * This function should run in a separate thread on the XMOS core controlling the I/O pins for
 * EtherCAT communication.
 *
 * For every packet send or received from or to this EtherCAT handler, the
 * first word transmitted indicates the number of words to follow (the packet
 * itself).
 *
 * @param c_coe_r push received CAN packets
 * @param c_coe_s read packets to send as CAN
 * @param c_eoe_r push received Ethernet packets
 * @param c_eoe_s read packets to send as Ethernt
 * @param c_eoe_sig signals for ethernet handling
 * @param c_foe_r push received File packets
 * @param c_foe_s read packets to send as File
 * @param c_pdo_r push received File packets
 * @param c_pdo_s read packets to send as File
 */
void ecat_handler(chanend c_coe_r, chanend c_coe_s,
			chanend c_eoe_r, chanend c_eoe_s, chanend c_eoe_sig,
			chanend c_foe_r, chanend c_foe_s,
			chanend c_pdo_r, chanend c_pdo_s);

/**
 * @brief Init function for the EtcherCAT module
 *
 * This function must be called in the first place to enable ethercat service.
 *
 * @return  0 on success
 */
int ecat_init(void);

/**
 * @brief Reset ethercat handler and servicces
 *
 * @warning Currently this function is only a stub and doesn't perform any
 * functionality.
 */
int ecat_reset(void);

#endif /* ETHERCAT_H */
