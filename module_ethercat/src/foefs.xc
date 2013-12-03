
/**
 *
 * \file foefs.xc
 *
 * \brief API for simple and specialized filesystem for use within the EtherCAT
 *        module
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

#include <xs1.h>
#include <platform.h>
#include <string.h>

#include "foe.h"
#include "foefs.h"

/* FIXME currently only one file in the file system is allowed */
foefile_t filesystem;
unsigned freespace;

static int copy_fname(char src[], char dest[], unsigned size)
{
	int i;

	for (i=0; i<size; i++) {
		dest[i] = src[i];
	}

	return i;
}

/* application interface (public) */

/* FIXME check if file exists, than check mode */
int foefs_open(char filename[], int mode)
{
	if (freespace > 0) { /* new file */
		freespace--;
	}

	if ((mode == MODE_RO) && (strncmp(filename, filesystem.name, MAX_FNAME) != 0)) {
		return -FOE_ERR_NOTFOUND;
	}

	if ((mode == MODE_RW) && (strncmp(filename, filesystem.name, MAX_FNAME)) != 0) {
		copy_fname(filename, filesystem.name, MAX_FNAME);
	}

	/* is file already open, and/or currently in use */
	if (filesystem.fh != 0) {
		return -FOE_ERR_PERM;
	}

	filesystem.fh++;
	filesystem.currentpos = 0; /* rewind */
	filesystem.mode = mode;

	return filesystem.fh;
}

int foefs_close(int fh)
{
	filesystem.fh = 0;
	filesystem.currentpos = 0;
	return filesystem.fh;
}

int foefs_read(int fh, int size, char b[])
{
	int read=0;
	int readSize = 0;
	int i;

	if (fh != filesystem.fh) {
		return -FOE_ERR_NOACCESS;
	}

	if (size>(filesystem.size-filesystem.currentpos)) {
		readSize = filesystem.size-filesystem.currentpos;
	} else {
		readSize = size;
	}

	for (i=0, read=filesystem.currentpos; i<readSize; i++, read++) {
		b[i] = filesystem.bytes[read];
	}

	filesystem.currentpos += readSize;

	return readSize;
}

/*
FIXME: what happens if offset is larger than file.size at the beginning of write cycle?
*/
int foefs_write(int fh, int size, char b[])
{
	int writecount = 0;
	int i;

	if (fh != filesystem.fh) {
		return -FOE_ERR_NOACCESS;
	}

	if (filesystem.mode == MODE_RO) {
		return -FOE_ERR_PERM;
	}

	if (BLKSZ < filesystem.currentpos + size) {
		return -FOE_ERR_ILLEGAL;
	}

	for (writecount=0, i=filesystem.currentpos; writecount<size; i++, writecount++) {
		filesystem.bytes[i] = b[writecount];
	}

	filesystem.size += writecount;
	filesystem.currentpos += writecount;
	freespace = 0;

	return writecount;
}

int foefs_seek(int fh, int offset, int whence)
{
	if (fh != filesystem.fh) {
		return -FOE_ERR_NOACCESS;
	}

	/* FIXME add check if offset will be set after end of file */
	switch (whence) {
	case SEEK_SET:
		filesystem.currentpos = offset;
		break;
	case SEEK_CUR:
		filesystem.currentpos += offset;
		break;
	}

	return filesystem.currentpos;
}

/* intermodule interface (private) */

int foefs_init()
{
	filesystem.fh = 0;
	filesystem.name[0] = 0; /* empty name */
	filesystem.size = 0;
	freespace = 1;

	return 0;
}

/* placeholder */
int foefs_release()
{
	return 0;
}

int foefs_format()
{
	return foefs_init();
}

int foefs_remove(int fh)
{
	int i=0;

	filesystem.fh = 0;
	filesystem.size = 0;
	filesystem.currentpos = 0;
	freespace++;

	for (i=0; i<MAX_FNAME; i++) {
		filesystem.name[i] = 0;
	}

	return 0;
}

int foefs_free(void)
{
	return freespace;
}
