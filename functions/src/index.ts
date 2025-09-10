import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import got from 'got';
import * as crypto from 'crypto';
// Initialize Admin SDK BEFORE exporting or importing triggers that use it
admin.initializeApp();

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

// ==== Payments (Paystack) ====
// Secret from functions config (firebase functions:config:set paystack.secret_key="...")
// falls back to env PAYSTACK_SECRET_KEY if needed
const PAYSTACK_SECRET = (functions.config()?.paystack?.secret_key as string | undefined) || process.env.PAYSTACK_SECRET_KEY || '';
const PAYSTACK_BASE = 'https://api.paystack.co';

export const initiateAdmissionPayment = functions.https.onCall(async (data, context) => {
  if (!data || typeof data !== 'object') {
    throw new functions.https.HttpsError('invalid-argument', 'Missing payload');
  }
  const admissionId = (data.admissionId || '').toString();
  const email = (data.email || '').toString();
  const amount = Number(data.amount || 0); // in NGN Naira; Paystack expects kobo
  if (!admissionId || !email || !amount || amount <= 0) {
    throw new functions.https.HttpsError('invalid-argument', 'admissionId, email, amount required');
  }
  if (!PAYSTACK_SECRET) {
    throw new functions.https.HttpsError('failed-precondition', 'PAYSTACK_SECRET_KEY not configured');
  }
  const db = admin.firestore();
  const ref = `admissions_${admissionId}_${Date.now()}`;
  // Initialize transaction
  const resp = await got.post(`${PAYSTACK_BASE}/transaction/initialize`, {
    headers: { Authorization: `Bearer ${PAYSTACK_SECRET}` },
    json: {
      email,
      amount: Math.round(amount * 100),
      reference: ref,
      metadata: { admissionId },
      // callback_url could be added if you want a redirect page
    },
  }).json<any>();

  if (!resp.status || !resp.data) {
    throw new functions.https.HttpsError('internal', 'Failed to initialize payment');
  }

  await db.collection('admissions').doc(admissionId).set({
    paymentStatus: 'pending',
    amount,
    paymentReference: ref,
    paymentProvider: 'paystack',
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });

  return {
    authorization_url: resp.data.authorization_url,
    access_code: resp.data.access_code,
    reference: ref,
  };
});

export const paystackWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).send('Method not allowed');
    return;
  }
  const signature = req.headers['x-paystack-signature'] as string | undefined;
  if (!signature || !PAYSTACK_SECRET) {
    res.status(401).send('Unauthorized');
    return;
  }
  const hash = crypto.createHmac('sha512', PAYSTACK_SECRET).update(req.rawBody).digest('hex');
  if (hash !== signature) {
    res.status(401).send('Invalid signature');
    return;
  }
  const event = req.body;
  try {
    const reference: string = event?.data?.reference || '';
    const status: string = event?.data?.status || '';
    const admissionId: string = event?.data?.metadata?.admissionId || (reference.startsWith('admissions_') ? reference.split('_')[1] : '');
    if (!reference || !admissionId) {
      res.status(200).send('ok');
      return;
    }
    const db = admin.firestore();
    if (status === 'success') {
      await db.collection('admissions').doc(admissionId).set({
        paymentStatus: 'paid',
        paymentReference: reference,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    } else if (status === 'failed') {
      await db.collection('admissions').doc(admissionId).set({
        paymentStatus: 'failed',
        paymentReference: reference,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
  } catch (e) {
    // swallow errors to avoid retries if desired
  }
  res.status(200).send('ok');
});

