/* eoe.h
 *
 * Copyright 2012, Synapticon GmbH. All rights reserved.
 * Author: Frank Jeschke <jeschke@fjes.de>
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
#define EOE_INIT_REQ                 0x02
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

#define MAX_EOE_DATA                 512 /* FIXME put correct value here */

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
int eoe_rx_handler(chanend eoe, uint16_t msg[], unsigned size);

int eoe_tx_handler(uint16_t msg[], unsigned size);

#endif /* EOE_H */