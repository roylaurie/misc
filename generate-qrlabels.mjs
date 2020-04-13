/**
 * Generates a PDF file of QR Codes, each containing a randomly generated UUID.
 *
 * npm install qrcode pdfkit svg-to-pdfkit uuidjs sprintf
 * node --experimental_modules ./generate-qrlabels.mjs
 **/
'use strict';

import fs from 'fs';
import path from 'path';
import QRCode from 'qrcode';
import PDFDocument from 'pdfkit';
import SVGtoPDF from 'svg-to-pdfkit';
import uuid from 'uuidjs';
import sprintf from 'sprintf';

(()=>{
    const SVG_WIDTH = 72;
    const SVG_HEIGHT = 72;
    const SVG_MARGIN = 3;
    const QRCODE_SHEET_FILEPATH = './out/qrlabel-sheet.pdf';

    const pdfdoc = new PDFDocument();
    const pageWidth = pdfdoc.page.width;
    const pageHeight = pdfdoc.page.height;
    const marginLeft = pdfdoc.page.margins.left;
    const marginRight = pdfdoc.page.margins.right;
    const marginTop = pdfdoc.page.margins.top;
    const marginBottom = pdfdoc.page.margins.bottom;

    let promises = [];

    for (let y = marginTop; y < (pageHeight - marginBottom); y += SVG_HEIGHT) {
            for (let x = marginLeft; x < ( pageWidth - marginRight); x += SVG_WIDTH) {
                let promise = createSVG(SVG_WIDTH, SVG_MARGIN)
                .then((svg) => { SVGtoPDF(pdfdoc, svg, x, y); })
                .catch((err) => { throw err; });

                promises.push(promise);
            }
    }
    
    Promise.all(promises).then(()=>{
        fs.mkdirSync(path.dirname(QRCODE_SHEET_FILEPATH), { recursive: true });
        pdfdoc.pipe(fs.createWriteStream(QRCODE_SHEET_FILEPATH));
        pdfdoc.end();
    });

})();

function createSVG(width, margin) {
    const SVG_STYLE = '<style> .uuid { font: 2px monospace; } </style>';
    const SVG_TEXT_FORMAT = '<text x="%d" y="%d" class="uuid">%s</text>';
    const SVG_CLOSE = '</svg>';

    const qruuid = uuid.genV4();

    let promise = QRCode.toString(qruuid.hexNoDelim, { type: 'svg', width: width, margin: margin })
    .then((svg) => {
        // split the uuid in half
        let uuidTop = qruuid.hexString.substring(0, 17); // aaaaaaaa-bbbb-cccc 
        let uuidBottom = qruuid.hexString.substring(19); // dddd-eeeeeeeeeeee ; skips the first - char
            
        // add the uuid halves to the top and bottom margins of the svg
        svg = svg.substring(0, svg.length - 7) // trim </svg>
        + SVG_STYLE
        + sprintf(SVG_TEXT_FORMAT, 7, 2, uuidTop)
        + sprintf(SVG_TEXT_FORMAT, 7, 34, uuidBottom) 
        + SVG_CLOSE;

        return svg;
    });

    return promise;
};

