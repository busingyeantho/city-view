"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onImageFinalize = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const sharp_1 = require("sharp");
const db = admin.firestore();
const bucket = admin.storage().bucket();
exports.onImageFinalize = functions.storage.object().onFinalize(async (object) => {
    const filePath = object.name || '';
    if (!filePath.startsWith('images/'))
        return;
    const contentType = object.contentType || '';
    if (!contentType.startsWith('image/'))
        return;
    const sizes = [480, 960, 1440];
    const file = bucket.file(filePath);
    const [buffer] = await file.download();
    const variants = {};
    await Promise.all(sizes.map(async (w) => {
        const out = await (0, sharp_1.default)(buffer).resize({ width: w, withoutEnlargement: true }).webp({ quality: 82 }).toBuffer();
        const variantPath = filePath.replace(/^images\//, `images/variants/${w}w_`).replace(/\.[^.]+$/, '.webp');
        const vFile = bucket.file(variantPath);
        await vFile.save(out, { contentType: 'image/webp', resumable: false });
        const [url] = await vFile.getSignedUrl({ action: 'read', expires: Date.now() + 1000 * 60 * 60 * 24 * 365 });
        variants[w.toString()] = url;
    }));
    const imagesCol = db.collection('images');
    await imagesCol.add({
        path: filePath,
        variants,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
});
//# sourceMappingURL=imageVariants.js.map