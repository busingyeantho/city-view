import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import got from 'got';
export * from './imageVariants';

export const sendContactEmail = functions.https.onCall(async (data, context) => {
  const name = (data.name || '').toString();
  const email = (data.email || '').toString();
  const subject = (data.subject || '').toString();
  const message = (data.message || '').toString();
  if (!name || !email || !message) {
    throw new functions.https.HttpsError('invalid-argument', 'Missing fields');
  }
  // Store in Firestore
  await admin.firestore().collection('contactMessages').add({
    name, email, subject, message, createdAt: admin.firestore.FieldValue.serverTimestamp()
  });
  // Email integration placeholder (e.g., SendGrid/Mailgun)
  return { ok: true };
});

admin.initializeApp();

export const prerender = functions.https.onRequest(async (req, res) => {
  // Simple prerender proxy placeholder. In production, point this to Rendertron or a prerender service.
  const userAgent = req.headers['user-agent'] || '';
  const isBot = /bot|crawler|spider|crawling/i.test(userAgent as string);
  if (!isBot) {
    res.status(404).send('Not a bot');
    return;
  }
  try {
    const target = `https://${req.hostname}${req.originalUrl}`;
    const rendertronUrl = `https://render-tron.appspot.com/render/${encodeURIComponent(target)}`;
    const html = await got(rendertronUrl, { timeout: { request: 10000 } }).text();
    res.set('Cache-Control', 'public, max-age=300');
    res.status(200).send(html);
  } catch (e) {
    res.status(500).send('Prerender failed');
  }
});

export const generateSitemap = functions.pubsub.schedule('every 24 hours').onRun(async () => {
  const db = admin.firestore();
  const postsSnap = await db.collection('blogPosts').where('status', '==', 'published').get();
  const urls: string[] = ['/'];
  postsSnap.forEach((d) => urls.push(`/blog/${d.get('slug')}`));
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${urls
    .map((u) => `<url><loc>https://city-view-8e128.web.app${u}</loc></url>`)
    .join('\n')}\n</urlset>`;
  await admin.storage().bucket().file('sitemap.xml').save(xml, { contentType: 'application/xml', resumable: false });
});


