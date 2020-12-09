'use strict';

export default function(db, schema, data, modified, action) {
	if (typeof modified[schema.keys.status.name] !== 'undefined') {
		// create a research child task when initially assigned
		if (data.status === schema.keys.status.enum.assigned) {
			if (modified.status === schema.keys.status.enum.accepted) {
				db.create('task', {
					parentId: data.id,
					type: data.type,
					title: 'Research solution',
				});
			}
		}
	}
};

