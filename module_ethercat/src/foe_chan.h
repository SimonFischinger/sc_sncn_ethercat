
/**
 *
 * \file foe_chan.h
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

#ifndef FOE_CHAN_H
#define FOE_CHAN_H

/* defines for file access over channel */

/**
 * commands from the caller
 *
 * The following commands are recognized:
 * FOE_FILE_OPEN <filename>
 * open specified file for reading, replies FOE_FILE_OK on success or FOE_FILE_ERROR on error.
 *
 * FOE_FILE_CLOSE
 * Finish file access operation
 *
 * FOE_FILE_READ <size>
 * read <size> bytes from previously opened file
 *
 * FOE_WRITE <size> <data>
 *** currently unsupported ***
 *
 * FOE_FILE_SEEK <pos>
 * set filepointer to (absolute) position <pos>, the next read/write operation will start from there.
 * With FOE_FILE_SEEK 0 the file pointer is rewind to the beginning of the file.
 *
 * FOE_FILE_FREE
 * This command will erase the file (or files), so further file access is possible.
 */
#define FOE_FILE_OPEN      10
#define FOE_FILE_READ      11
#define FOE_FILE_WRITE     12
#define FOE_FILE_CLOSE     13
#define FOE_FILE_SEEK      14
#define FOE_FILE_FREE      15

/* replies to the caller */
#define FOE_FILE_ACK       20
#define FOE_FILE_ERROR     21
#define FOE_FILE_DATA      22

/* control commands */
#define FOE_FILE_READY     30

#endif /* FOE_CHAN_H */
