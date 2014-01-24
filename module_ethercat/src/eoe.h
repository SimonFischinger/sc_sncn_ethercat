
/**
 *
 * \file eoe.h
 *
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

/* What to do here:
 * - get EoE header and check package
 * - forward ethernet resp. tcp/ip packet to application resp. module to handle
 *   these.
 *
 * Note:
 * The header parameter port isn't supported (currently). As far as I get it
 * this would requiere a total of 15 different ports which lead to 15 distinct
 * ethernet package buffers. This would lead in a severe memory consumption.
 */

#ifndef EOE_H
#define EOE_H

#include <stdint.h>

/* FIXME check ETG for packet type numbers */
#define EOE_INIT_REQ                 0x02 /* FIXME similar to EOE_IP_PARAM_REQ !!! */
#define EOE_INIT_RSP                 0x03
#define EOE_FRAGMENT_REQ             0x00

#define EOE_IP_PARAM_REQ             0x02
#define EOE_IP_PARAM_RSP             0x03
#define EOE_ADDR_FILTER_REQ          0x04
#define EOE_ADDR_FILTER_RSP          0x05

/* EoE Error codes */
#define EOE_RESULT_SUCCESS           0x0000
#define EOE_RESULT_UNSPECIFIED       0x0001
#define EOE_RESULT_UNSUPPORTED       0x0000
#define EOE_RESULT_NOIPSUPPORT       0x0000
#define EOE_RESULT_NOFILTERSUPPORT   0x0000

#define MAX_ETHERNET_FRAME   1518  /* Max. number of bytes within a ethernet frame. FIXME with VLAN field it's 1522 */
#define MAX_ETHERNET_BUFFER  1

#define EOE_MAX_HEADER_SIZE  4
#define EOE_MAX_MSG_SIZE     122
#define EOE_MAX_DATA_SIZE    (EOE_MAX_MSG_SIZE-EOE_MAX_HEADER_SIZE)

#define MAX_EOE_DATA         EOE_MAX_DATA_SIZE /* FIXME refactor and remove this define! */

#define EOE_STATE_IDLE               0
#define EOE_STATE_RX_FRAGMENT        1
#define EOE_STATE_RX_LAST_FRAGMENT   2
#define EOE_STATE_TX_FRAGMENT        3

/* another try/test with bit field sizes: */

struct _eoe_data {
	unsigned char dst_mac[6];
	unsigned char src_mac[6];
	unsigned char vlan_tag[4];               /* optional could be omitted! */
	uint16_t ether_type;
	unsigned char data[MAX_EOE_DATA-18];     /* 18 byte data head */
	unsigned char padding[MAX_EOE_DATA-18];
};

struct _eoe_param_filter {
	char mac_filter_count;
	char eac_filter_mask;
	char reservedb;
	char inhibit_bcast;
	char reserved; /* 8 bit reserved data, necessary? */
	unsigned char maclist[6*16];       /* each entry is 6 bytes long, and max 2^4=16 entries */
	unsigned char listfilter[6*16];
};

struct _eoe_parameter {
	char mac_included;
	char ip_included;
	char subnetmasq_included;
	char gateway_included;
	char dns_server_included;
	char dns_name_included;
	char reserved[26]; /* really needed here? */
	unsigned char mac[6];
	unsigned char ip[4];
	unsigned char subnet[4];
	unsigned char gateway[4];
	unsigned char dnsip[4];
	char dns_name[32];
};

struct _eoe_packet {
	/* eoe header FIXME option: merge chuncks of 16 bits into this as header, make makros to check individual fields */
	char type;            /* 4 */
	char eport;           /* 4 0x00 (no spec. port) - 0x0f */
	char lastFragment;    /* 1 0 - at least one frame follows, 1 - last packet */
	char timeAppended;    /* 1 0 no time appended 1 - timestamp appended after data section */
	char timeRequest;     /* 1 0 no timestamp request, 1 timestamp request */
	char reserved;        /* 5 reseverved 0x00 */
	char fragmentNumber;  /* 6 0 if type = INIT_REQ, 0x01 - 0x2f  for type FRAGMET_REQ */
	union {
		char complete;
		char offset;
	} a;
	char frameNumber; /* 4-bit - number of the ethernet frame */
	/* data section */
	union {
		unsigned char data[MAX_EOE_DATA];
		struct _eoe_data sdata;
		struct _eoe_parameter param;
		struct _eoe_param_filter param_filter;
	} b;                         /* ommited if, type is EOE_INIT_RSP */
	uint32_t timestamp;          /* optional */
};


void eoe_init(void);

/* convention channels:
 * - eoe_rx: everything from master
 * - eoe_tx: everything to master
 */
int eoe_rx_handler(chanend eoe, chanend sig, uint16_t msg[], unsigned size);

/**
 * @brief  Get tx packet from mii handler
 *
 * @return 0 if packet is not ready, 1 if tx packet is ready
 */
int eoe_tx_handler(chanend eoe,  unsigned size);

/**
 * @brief check if a tx packet is ready for transmission.
 *
 * @return 0 if packet is not ready, 1 if it is.
 */
int eoe_tx_ready(void);

/**
 * @brief Get reply package, with max size for ethercat data.
 *
 * @param msg[] array to store packet payload
 * @return Number of bytes to send.
 */
unsigned eoe_get_reply(uint16_t msg[]);

/**
 * @brief Check if more chunks are present for transfere.
 *
 * @return 0 if no more chunks to transfere, 1 otherwise
 */
int eoe_check_chunks(void);

#endif /* EOE_H */
