/**
 * Generates a PDF file of QR Codes, each containing a randomly generated UUID.
 *
 * npm install qrcode pdfkit svg-to-pdfkit uuidjs
 * node --experimental_modules ./generate-qrlabels.mjs
 **/
'use strict';

import QRCode from 'qrcode';
import PDFDocument from 'pdfkit';
import SVGtoPDF from 'svg-to-pdfkit';
import uuid from 'uuidjs';
import fs from 'fs';
import path from 'path';

(()=>{
    const QRCODE_SHEET_FILEPATH = './out/qrlabel-sheet.pdf';
    const SVG_WIDTH = 72;
    const SVG_HEIGHT = 72;
    const pdfdoc = new PDFDocument();
    let promises = [];

    for (let y = pdfdoc.page.margins.top; y < (pdfdoc.page.height - pdfdoc.page.margins.bottom); y+=SVG_HEIGHT) {
            for (let x = pdfdoc.page.margins.left; x < (pdfdoc.page.width - pdfdoc.page.margins.right); x+=SVG_WIDTH) {
                promises.push(addSVG(pdfdoc, x, y, SVG_WIDTH));
            }
    }
    
    Promise.all(promises).then(()=> {
        fs.mkdirSync(path.dirname(QRCODE_SHEET_FILEPATH), { recursive: true });
        pdfdoc.pipe(fs.createWriteStream(QRCODE_SHEET_FILEPATH));
        pdfdoc.end();
    });

})();

function addSVG(pdfdoc, x, y, width) {
    let promise = QRCode.toString(uuid.genV4().hexNoDelim, { type: 'svg', width: width, margin: 0 });
    return promise.then((svg) => {
        SVGtoPDF(pdfdoc, svg, x, y);
    });
};
