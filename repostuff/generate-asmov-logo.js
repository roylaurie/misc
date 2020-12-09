'use strict';

class Shape {
	constructor(points) {
		this.points = points;
		this.width = width;
		this.height = height;
	};
}

class Polygon extends Shape {
}

class Triangle extends Polygon {
	constructor(points) {
		super()
	};
}

class Parallelogram extends Polygon {
	constructor(points) {
		super();
	};
}

export default function(width, height) {
	// draw outer parallelogram
	let outerParallelogram = Parallelogram.create({ width: width, height: height, theta: 45});

	// draw triangle for A
	let triangleA = Triangle.create({
		width: outerParallelogram.points[0].x - outerParallelogram.points[4].x;
		height: outerParallelogram.height,
	});
	
	
	// draw inner parallelogram
	// draw triangle for S
	// draw triangular polygon for M
	// draw parallelogram for O
};
