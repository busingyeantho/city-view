# Setting Up Google Cloud Service Account for Firebase Deployment

This guide will help you set up a secure service account for automated Firebase deployments via GitHub Actions.

## Step 1: Create Service Account in Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project: `city-view-8e128`
3. Navigate to **IAM & Admin** → **Service Accounts**
4. Click **CREATE SERVICE ACCOUNT**
5. Fill in the details:
   - **Service account name**: `firebase-deploy-bot`
   - **Service account ID**: `firebase-deploy-bot` (auto-generated)
   - **Description**: `Service account for automated Firebase deployments`
6. Click **CREATE AND CONTINUE**

## Step 2: Assign Required Roles

1. In the **Grant this service account access to project** section, add these roles:
   - **Firebase Admin** (`roles/firebase.admin`)
   - **Cloud Functions Admin** (`roles/cloudfunctions.admin`)
   - **Service Account User** (`roles/iam.serviceAccountUser`)
   - **Storage Admin** (`roles/storage.admin`)
   - For Firestore, depending on what appears in your console, choose ONE of:
     - **Cloud Datastore Owner** (`roles/datastore.owner`) — broadest Firestore/Datastore control
     - **Cloud Datastore User** (`roles/datastore.user`) — sufficient for most app access; deployments that manage indexes/exports may require owner

2. Click **CONTINUE**

Note: **Firebase Admin already includes Firestore access** for typical deployments. Adding a specific Datastore/Firestore role is helpful when you want to be explicit or restrict Firebase Admin later.

## Step 3: Create and Download Service Account Key

1. Click **DONE** to complete service account creation
2. Find your new service account in the list and click on it
3. Go to the **KEYS** tab
4. Click **ADD KEY** → **Create new key**
5. Choose **JSON** format
6. Click **CREATE** - this will download a JSON file

## Step 4: Add GitHub Secret

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the secret:
   - **Name**: `GOOGLE_APPLICATION_CREDENTIALS_JSON`
   - **Value**: Copy the **entire content** of the downloaded JSON file
5. Click **Add secret**

## Step 5: Verify GitHub Secrets

Ensure you have these secrets in your repository:
- `GOOGLE_APPLICATION_CREDENTIALS_JSON` - The service account key JSON content
- `FIREBASE_PROJECT_ID` - `city-view-8e128`

## Security Benefits

Using a service account instead of `FIREBASE_TOKEN` provides:
- **Fine-grained permissions**: Only the specific roles needed
- **Audit trail**: All actions are logged with the service account
- **No expiration**: Service account keys don't expire like CI tokens
- **Principle of least privilege**: Minimal required permissions

## Troubleshooting

If deployment fails, check:
1. Service account has correct roles
2. JSON key is properly copied (no extra spaces/characters)
3. Project ID matches exactly
4. Service account is enabled

## Next Steps

After setting up the service account:
1. Push any change to the `main` branch
2. GitHub Actions will automatically build and deploy
3. Check the Actions tab to monitor deployment progress

## Important Notes

- **Never commit the service account JSON file** to your repository
- **Keep the downloaded JSON file secure** - it contains sensitive credentials
- **Rotate the key periodically** for security best practices
- **Monitor usage** in Google Cloud Console to ensure proper access
