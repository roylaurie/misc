'use strict';

export default function(db, schema, entry, action) {
	if (entry.createdTimestamp === null) {
		entry.createdTimestamp = Date.now();
	}
};
