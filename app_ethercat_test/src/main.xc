/* app_ethercat_test
 *
 * Test appliction for module_ethercat.
 *
 * Copyright 2011, Synapticon GmbH. All rights reserved.
 * Author: Frank Jeschke <jeschke@fjes.de>
 */

#include <platform.h>
#include <print.h>
#include <xs1.h>

#include <ethercat.h>

#define MAX_BUFFER_SIZE   1024

on stdcore[1] : out port ledBlue = LED_BLUE;
on stdcore[1] : out port ledGreen = LED_GREEN;
on stdcore[1] : out port ledRed = LED_RED;

/* example consumer */
static void consumer(chanend coe_in, chanend coe_out, chanend eoe_in, chanend eoe_out,
			chanend foe_in, chanend foe_out/*, chanend pdo_in, chanend pdo_out*/)
{
	timer t;
	const unsigned int delay = 100000;
	unsigned int time = 0;

	unsigned int inBuffer[MAX_BUFFER_SIZE];
	unsigned int outBuffer[MAX_BUFFER_SIZE];
	unsigned int tmp = 0;
	unsigned int size = 0;
	unsigned count = 0;
	unsigned outSize;

	int i;

	for (i=0; i<MAX_BUFFER_SIZE; i++) {
		inBuffer[i] = 0;
		outBuffer[i] = 0;
	}

	while (1) {
		/* Receive data */
		select {
		case coe_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			printstr("[APP] Received COE packet\n");
			count=0;

			while (count < inBuffer[0]) {
				coe_in :> tmp;
				inBuffer[count+1] = tmp&0xffff;
				count++;
			}

			outSize = 8;

			/* Test packet, reply to init download SDO */
			printstr("[APP DEBUG] construction of dummy answer\n");
			outBuffer[0] = COE_PACKET;
			outBuffer[1] = outSize;
			outBuffer[2] = 0x60; /* initial download sdo answer */
			outBuffer[3] = 0x1c;
			outBuffer[4] = 0x00;
			outBuffer[5] = 0x00;
			outBuffer[6] = 0x00;
			outBuffer[7] = 0x00;
			outBuffer[8] = 0x00;
			outBuffer[9] = 0x00;

			break;

		case eoe_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			printstr("[APP] Received EOE packet\n");
			count=0;
			while (count < inBuffer[0]) {
				eoe_in :> tmp;
				inBuffer[count+1] = tmp&0xffff;
				count++;
			}
			break;

		case foe_in :> tmp :
			size = (uint16_t)(tmp&0xffff);
			count=0;

			while (count < size) {
				tmp = 0;
				foe_in :> tmp;
				inBuffer[count] = (tmp&0xffff);
				count++;
			}

#if 1
			/* check packet content */
			tmp = (inBuffer[0]>>8)&0xff;
			printstr("DEBUG FOE primitive: ");
			printhexln(tmp);

			switch (tmp) {
			case 0x01: /* FoE read */
				printstr("DEBUG main FoE read request\n");
				break;
			case 0x02: /* FoE write */
				printstr("DEBUG main FoE write request\n");
				break;
			case 0x03: /* data request */
				printstr("DEBUG main FoE data request\n");
				break;
			case 0x04: /* ack request */
				printstr("DEBUG main FoE ack request\n");
				break;
			case 0x05: /* error request */
				printstr("DEBUG main FoE error request\n");
				break;
			case 0x06: /* busy request */
				printstr("DEBUG main FoE busy request\n");
				break;
			}

			/* Here comes the code to handle the package content! */
			printstr("[APP] Received FOE packet (echoing)\n");
			printhexln(size);
			count = 0;
			outBuffer[count++] = FOE_PACKET;
			outBuffer[count++] = size; /* FIXME simple echo test */
			for (i=0;i<size;i++) {
				printstr("Received: ");
				printhexln(inBuffer[i]);
				outBuffer[i+1] = tmp&0xffff; /* FIXME simple echo test */
			}
			/* end example */
#endif
			break;

#if 0
		case pdo_out :> tmp :
			inBuffer[0] = tmp&0xffff;
			printstr("[APP] Received PDO packet: \n");

			count = 0;
			while (count<inBuffer[0]) {
				tmp = 0;
				pdo_out :> tmp;
				inBuffer[count+1] = (tmp&0xffff);
				count++;
			}

			if (inBuffer[1] == 0xde || inBuffer[1] == 0xad) {
				ledGreen <: 0;
			} else {
				ledGreen <: 1;
			}

			if (inBuffer[1] == 0xaa || inBuffer[1] == 0x66) {
				ledGreen <: 0;
			} else {
				ledRed <: 1;
			}

			/* DEBUG output of received packet: */
			for (i=1;i<count+1;i++) {
				printhex(inBuffer[i]);
				printstr(";");
			}
			printstr(".\n");
			// */

			break;
#endif
		}
/* send data */
		switch (outBuffer[0]) {
		case COE_PACKET:
			count=1;
			printstr("[APP DEBUG] send CoE packet\n");
			while (count<(outSize+2)) {
				coe_out <: outBuffer[count];
				count++;
			}
			outBuffer[0] = 0;
			break;

		case EOE_PACKET:
			count=1;
			printstr("DEBUG send EoE packet\n");
			while (count<outSize) {
				eoe_out <: outBuffer[count];
				count++;
			}
			outBuffer[0] = 0;
			break;

		case FOE_PACKET:
			count=1;
			printstr("DEBUG send FoE packet\n");
			while (count<outSize) {
				foe_out <: outBuffer[count];
				count++;
			}
			outBuffer[0] = 0;
			break;

		default:
			break;
		}

		t :> time;
		t when timerafter(time+delay) :> void;
	}
}

/* FIXME check channels! */
static void pdo_handler(chanend pdo_out, chanend pdo_in)
{
	unsigned int inBuffer[64];
	unsigned int count=0;
	unsigned int outCount=0;
	unsigned int tmp;

	timer t;
	const unsigned int delay = 100000;
	unsigned int time = 0;

	while (1){
		count = 0;

		select {
		case pdo_in :> tmp :
			inBuffer[0] = tmp&0xffff;
			printstr("[APP DEBUG] Received PDO packet: \n");

			while (count<inBuffer[0]) {
				tmp = 0;
				pdo_in :> tmp;
				inBuffer[count+1] = (tmp&0xffff);
				printhex(tmp&0xffff);
				count++;
			}
			printstr("\n");

			if (inBuffer[1] == 0xdead || inBuffer[1] == 0xadde || inBuffer[1] == 0xbeef || inBuffer[1] == 0xefbe) {
				ledGreen <: 0;
			} else {
				ledGreen <: 1;
			}

			if (inBuffer[1] == 0xaaaa || inBuffer[1] == 0x6666) {
				ledRed <: 0;
			} else {
				ledRed <: 1;
			}
			break;
		default:
			break;
		}

		if (count>0) {
			/* echo pdo input */
			printstr("[APP DEBUG] echo pdo input\n");
			outCount=0;
			while (outCount >= count) {
				pdo_out <: inBuffer[outCount++];
			}
		}
		//t :> time;
		//t when timerafter(time+delay) :> void;
	}
}

static void led_handler(void)
{
	timer t;
	const unsigned int delay = 50000000;
	unsigned int time = 0;
	int blueOn = 0;

	while (1) {
		t :> time;
		t when timerafter(time+delay) :> void;

		ledBlue <: blueOn;
		blueOn = ~blueOn & 0x1;
	}
}

int main(void) {
	chan coe_in;   ///< CAN from module_ethercat to consumer
	chan coe_out;  ///< CAN from consumer to module_ethercat
	chan eoe_in;   ///< Ethernet from module_ethercat to consumer
	chan eoe_out;  ///< Ethernet from consumer to module_ethercat
	chan foe_in;   ///< File from module_ethercat to consumer
	chan foe_out;  ///< File from consumer to module_ethercat
	chan pdo_in;
	chan pdo_out;

	par {
		on stdcore[0] : {
			ecat_init();
			ecat_handler(coe_out, coe_in, eoe_out, eoe_in, foe_out, foe_in, pdo_out, pdo_in);
		}

		on stdcore[0] : {
			consumer(coe_in, coe_out, eoe_in, eoe_out, foe_in, foe_out/*, pdo_in, pdo_out*/);
		}

		/*
		on stdcore[1] : {
			led_handler();
		}
		*/

		on stdcore[1] : {
			pdo_handler(pdo_out, pdo_in);
		}
	}

	return 0;
}
