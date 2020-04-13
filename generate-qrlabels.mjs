/**
 * Generates a PDF file of QR Codes, each containing a randomly generated UUID.
 *
 * npm install qrcode pdfkit svg-to-pdfkit uuidjs
 **/
'use strict';

import QRCode from 'qrcode';
import PDFDocument from 'pdfkit';
import SVGtoPDF from 'svg-to-pdfkit';
import uuid from 'uuidjs';
import fs from 'fs';

(()=>{
    const QRCODE_SHEET_FILEPATH = './qrcode-sheet-pdf';
    const pdfdoc = new PDFDocument();
    let promises = [];

    for (let y = pdfdoc.page.margins.top; y < (pdfdoc.page.height - pdfdoc.page.margins.bottom); y+=72) {
            for (let x = pdfdoc.page.margins.left; x < (pdfdoc.page.width - pdfdoc.page.margins.right); x+=72) {
                promises.push(addSVG(pdfdoc, x, y));
            }
    }
    
    Promise.all(promises).then(()=> {
        pdfdoc.pipe(fs.createWriteStream(QRCODE_SHEET_FILEPATH));
        pdfdoc.end();
    });

})();

function addSVG(pdfdoc, x, y) {
    let promise = QRCode.toString(uuid.genV4().hexNoDelim, { type: 'svg', width: 72, margin: 0 });
    return promise.then((svg) => {
        SVGtoPDF(pdfdoc, svg, x, y);
    });
};
