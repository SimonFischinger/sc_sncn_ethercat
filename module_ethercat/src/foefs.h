
/**
 *
 * \file foefs.h
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

#ifndef FOEFS_H
#define FOEFS_H

#define BLKSZ      2400
#define MAX_FNAME  10
#define SEEK_SET   0
#define SEEK_CUR   1
#define MODE_RO    0
#define MODE_RW    1

#define REQUEST_FILE   1    ///< request file from ethercat master
#define COMMIT_FILE    2   ///< push file to ehtercat master

/**
 * @brief Filesystem entry
 *
 * This is a file representation for a single file within the
 * pseude filesystem.
 */
typedef struct {
	int fh;                ///< Filehandle to access the file
	char name[MAX_FNAME];  ///< filename
	unsigned int size;     ///< file size in bytes
	unsigned int type;     ///< file type
	char bytes[BLKSZ];     ///< File content itself
	int currentpos;        ///< Current position within the file where the next r/w access is done
	int mode;              ///< Access to file: MODE_RW, MODE_RO
	//int transmit_to_master???
} foefile_t;

/**
 * @brief open file
 *
 * @param filename  filename to open
 * @return file handle, <0 on error
 */
int foefs_open(char filename[], int mode);

/**
 * @brief close file handle
 *
 * @param fh  file handle to close
 * @return 0 on success, <0 otherwise
 */
int foefs_close(int fh);

/** 
 * @brief read from file handle
 *
 * @param fh  file handle to read from
 * @param size  number of byes to read
 * @param b[]   buffer to store read bytes
 * @return number of bytes read, <0 on error
 */
int foefs_read(int fh, int size, char b[]);

/**
 * @brief write bytes to file starting at offset
 *
 * @param fh    filehandle to write to
 * @param size  number of bytes to write
 * @param b[]   buffer holding bytes to write
 * @return number of bytes written, <0 on error
 */
int foefs_write(int fh, int size, char b[]);

/**
 * @brief set file position
 *
 * @param fh   filehandle to operate on
 * @param offset  new offset of filehandle
 * @param where   either SEEK_SET for absolute positioning or SEEK_CUR for relative positioning.
 * @param 0 on success
 */
int foefs_seek(int fh, int offset, int whence);

/*
    intermodule interface (private)
 */

/**
 * @brief init pseudo filesystem
 * 
 * @return 0 on success
 */
int foefs_init(void);

/**
 * @brief release pseude filesystem
 *
 * @return 0 on success
 */
int foefs_release(void);

/**
 * @brief format file system
 *
 * this is basically a reinitalize.
 *
 * @return 0 on success
 */
int foefs_format(void);

/**
 * @brief Request the number of free bytes.
 *
 * @return Number of available bytes.
 */
int foefs_free(void);

#endif /* FOEFS_H */
