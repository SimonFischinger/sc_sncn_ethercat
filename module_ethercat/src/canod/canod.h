/**
 * canod.h
 *
 * Handle CAN object dictionary.
 */

/* Roadmap: this object dictionary should be more dynamically and more general */

#ifndef CANOD_H
#define CANOD_H

/* SDO Information operation code */
#define CANOD_OP_

/* list of dictionary lists identifiers */
#define CANOD_GET_NUMBER_OF_OBJECTS   0x00
#define CANOD_ALL_OBJECTS             0x01
#define CANOD_RXPDO_MAPABLE           0x02
#define CANOD_TXPDO_MAPABLE           0x03
#define CANOD_DEVICE_REPLACEMENT      0x04
#define CANOD_STARTUP_PARAMETER       0x05

/* possible object types of dictionary objects */
#define CANOD_TYPE_DOMAIN     0x0
#define CANOD_TYPE_DEFTYPE    0x5
#define CANOD_TYPE_DEFSTRUCT  0x6
#define CANOD_TYPE_VAR        0x7
#define CANOD_TYPE_ARRAY      0x8
#define CANOD_TYPE_RECORD     0x9

struct _sdoinfo_service {
	unsigned opcode;                   ///< OD operation code
	unsigned incomplete;               ///< 0 - last fragment, 1 - more fragments follow
	unsigned fragments;                ///< number of fragments which follow
	unsigned char data[SDO_MAX_DATA];  ///< SDO data field
};


/* sdo information data structure - FIXME may move to canod.h */

/* FIXME: add objects which describe the mapped PDO data.
 * the best matching OD area would be at index 0x200-0x5fff (manufacturer specific profile area
 */

/** object description structure */
struct _sdoinfo_object_description {
	unsigned index; ///< 16 bit int should be sufficient
	unsigned dataType; ///< 16 bit int should be sufficient
	unsigned char maxSubindex;
	unsigned char objectCode;
	unsigned char name[COE_MAX_MSG_SIZE-12];
};

/** entry description structure */
struct _sdoinfo_entry_description {
	unsigned index; ///< 16 bit int should be sufficient
	unsigned subindex; ///< 16 bit int should be sufficient
	unsigned char valueInfo; /* depends on SDO Info: get entry description request */
	unsigned char dataType;
	unsigned char bitLength;
	unsigned objectAccess;
	unsigned value; ///< real data type is defined by .dataType
};

/* ad valueInfo (BYTE):
 * Bit 0 - 2: reserved
 * Bit 3: unit type
 * Bit 4: default value
 * Bit 5: minimum value
 * Bit 6: maximum value
 */

/* ad objectAccess (WORD):
 * Bit 0: read access in Pre-Operational state
 * Bit 1: read access in Safe-Operational state
 * Bit 2: read access in Operational state
 * Bit 3: write access in Pre-Operational state
 * Bit 4: write access in Safe-Operational state
 * Bit 5: write access in Operational state
 * Bit 6: object is mappable in a RxPDO
 * Bit 7: object is mappable in a TxPDO
 * Bit 8: object can be used for backup
 * Bit 9: object can be used for settings
 * Bit 10 - 15: reserved
 */

/* ad PDO Mapping value (at index 0x200[01]):
 * bit 0-7: length of the mapped objects in bits
 * bit 8-15: subindex of the mapped object
 * bit 16-32: index of the mapped object
 */


/**
 * Return the length of all five cathegories
 */
int canod_get_list_length(unsigned length[]);

/**
 * Get list of objects in the specified cathegory
 */
int canod_get_list(unsigned list[], unsigned cathegory);

/**
 * Get description of object at index and subindex.
 */
int canod_get_entry_description(struct _sdoinfo_service_data obj, unsigned index, unsigned subindex);

/**
 * Get/Set OD entry values
 *
 * @param index
 * @param subindex
 * @param vales[]     read/write the values from this array.
 * @return 0 on success
 */
/* FIXME how to handle these various data types a object dictionary entry could
 * become?
 */
int canod_get_entry(unsigned index, unsigned subindex, char values[]);
int canod_set_entry(unsigned index, unsigned subindex, char values[]);

#endif /* CANOD_H */

