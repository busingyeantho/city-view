import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import Sharp from 'sharp';

const db = admin.firestore();
const bucket = admin.storage().bucket();

export const onImageFinalize = functions.storage.object().onFinalize(async (object) => {
  const filePath = object.name || '';
  if (!filePath.startsWith('images/')) return;
  const contentType = object.contentType || '';
  if (!contentType.startsWith('image/')) return;

  const sizes = [480, 960, 1440];
  const file = bucket.file(filePath);
  const [buffer] = await file.download();

  const variants: Record<string, string> = {};
  await Promise.all(
    sizes.map(async (w) => {
      const out = await Sharp(buffer).resize({ width: w, withoutEnlargement: true }).webp({ quality: 82 }).toBuffer();
      const variantPath = filePath.replace(/^images\//, `images/variants/${w}w_`).replace(/\.[^.]+$/, '.webp');
      const vFile = bucket.file(variantPath);
      await vFile.save(out, { contentType: 'image/webp', resumable: false });
      const [url] = await vFile.getSignedUrl({ action: 'read', expires: Date.now() + 1000 * 60 * 60 * 24 * 365 });
      variants[w.toString()] = url;
    })
  );

  const imagesCol = db.collection('images');
  await imagesCol.add({
    path: filePath,
    variants,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});


