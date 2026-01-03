# 💳 Quick Reference: Product IDs & Pricing

## App Store Connect Product Setup

### Copy-Paste Ready Product Information

---

## 1️⃣ ONE-TIME PURCHASE (Non-Consumable)

**Product ID:**
```
com.cocktailbar.pro.lifetime
```

**Reference Name:**
```
Cocktail Bar Pro - Lifetime
```

**Display Name (English):**
```
Cocktail Bar Pro
```

**Description (English):**
```
Unlock all premium features with lifetime access:

• Unlimited cabinet ingredients
• Unlimited favorites and collections
• Create and share custom recipes
• Track ingredient costs and budget
• Batch calculator for parties
• Access recipes offline
• Export recipes as PDFs
• Complete educational content library
• AI-powered ingredient substitutions
• Exclusive seasonal cocktail collections
• Smart shopping lists
• Ingredient expiration tracking

One-time purchase, yours forever. No subscriptions, no recurring charges.
```

**Price:**
```
Tier 20 ($19.99 USD)
Launch Price: Tier 15 ($14.99 USD) - First month only
```

**Availability:**
```
All territories
```

**Family Sharing:**
```
Enabled ✅
```

---

## 2️⃣ MONTHLY SUBSCRIPTION (Auto-Renewable)

**Subscription Group:**
```
Group Name: Premium Membership
```

**Product ID:**
```
com.cocktailbar.subscription.monthly
```

**Reference Name:**
```
Premium Monthly Subscription
```

**Subscription Duration:**
```
1 Month
```

**Display Name (English):**
```
Premium Monthly
```

**Description (English):**
```
Get unlimited access to all premium features:

• Unlimited storage for cocktails, ingredients, and collections
• Create unlimited custom recipes
• Professional cost tracking and budgeting
• Batch calculator for events and parties
• Download recipes for offline access
• Export and share as beautiful PDFs
• Complete bartending education library
• AI-powered ingredient substitutions
• Exclusive seasonal content
• Priority customer support

Auto-renews monthly. Cancel anytime from your account settings. No commitments.

Try free for 14 days!
```

**Price:**
```
$4.99/month USD (adjust per territory)
```

**Free Trial:**
```
14 days ✅
```

**Introductory Offer (Optional):**
```
$2.99 for first month
```

**Family Sharing:**
```
Enabled ✅
```

---

## 3️⃣ ANNUAL SUBSCRIPTION (Auto-Renewable)

**Subscription Group:**
```
Premium Membership (same as monthly)
```

**Product ID:**
```
com.cocktailbar.subscription.annual
```

**Reference Name:**
```
Premium Annual Subscription
```

**Subscription Duration:**
```
1 Year
```

**Display Name (English):**
```
Premium Annual - Best Value
```

**Description (English):**
```
Save 50% with our annual plan!

Everything included:
• All premium features unlocked
• Unlimited everything (storage, recipes, collections)
• Cost tracking and batch calculator
• Offline access to all recipes
• Export and sharing features
• Complete educational library
• AI-powered substitutions
• Seasonal exclusive content
• Priority support

Only $2.50/month when billed annually!

Auto-renews yearly. Cancel anytime. Try free for 14 days.
```

**Price:**
```
$29.99/year USD (50% savings vs monthly)
```

**Free Trial:**
```
14 days ✅
```

**Promotional Offer:**
```
$24.99 for first year (optional launch promotion)
```

**Family Sharing:**
```
Enabled ✅
```

**Badge:**
```
"Best Value" ⭐
```

---

## 4️⃣ ESSENTIAL PACK (Optional - Non-Consumable)

**Product ID:**
```
com.cocktailbar.pack.essential
```

**Display Name:**
```
Essential Pack
```

**Description:**
```
Get unlimited storage and offline access:

• Unlimited cabinet ingredients
• Unlimited saved favorites
• Unlimited collections
• Full offline mode
• Sync across devices

Perfect for serious cocktail enthusiasts!
```

**Price:**
```
$4.99 USD
```

---

## 5️⃣ CREATOR PACK (Optional - Non-Consumable)

**Product ID:**
```
com.cocktailbar.pack.creator
```

**Display Name:**
```
Creator Pack
```

**Description:**
```
Create and share your own cocktail recipes:

• Custom recipe creator
• Unlimited personal recipes
• Share with friends
• Export as PDFs
• QR code generation
• Recipe versioning

For mixologists who love to experiment!
```

**Price:**
```
$6.99 USD
```

---

## 6️⃣ PROFESSIONAL PACK (Optional - Non-Consumable)

**Product ID:**
```
com.cocktailbar.pack.professional
```

**Display Name:**
```
Professional Pack
```

**Description:**
```
Track costs and scale recipes like a pro:

• Ingredient cost tracking
• Budget management
• Batch calculator
• Shopping list manager
• Expense analytics
• Party planning tools

Perfect for event planners and bar managers!
```

**Price:**
```
$7.99 USD
```

---

## 📸 Screenshot Requirements

### For Each Product - Upload 1 Screenshot (1242x2688px)

**Screenshot Content:**
- Show the premium feature in action
- Clear, high-quality imagery
- Text overlay explaining benefit
- Use app's color scheme (warm amber/charcoal)

**Suggested Screenshots:**
1. **Lifetime Pro:** Dashboard showing all premium features unlocked
2. **Monthly/Annual:** Feature comparison table (Free vs Premium)
3. **Essential Pack:** Cabinet view with unlimited ingredients
4. **Creator Pack:** Custom recipe editor interface
5. **Professional Pack:** Cost tracking analytics screen

---

## 🌍 Localization (Optional)

If supporting multiple languages, translate:
- Display Names
- Descriptions
- Screenshot text

**Recommended first localizations:**
- Spanish (es-MX, es-ES)
- French (fr-FR)
- German (de-DE)
- Japanese (ja-JP)

---

## 📝 Review Notes Template

**For App Review Submission:**

```
IAP TESTING INSTRUCTIONS:

This app includes the following in-app purchases:

1. Cocktail Bar Pro ($19.99) - One-time lifetime purchase
2. Premium Monthly ($4.99/month) - Auto-renewable subscription
3. Premium Annual ($29.99/year) - Auto-renewable subscription (best value)

FEATURES:
- Free users can browse unlimited recipes but have storage limits
- Premium unlocks: unlimited storage, custom recipes, cost tracking, batch calculator, offline mode, and more
- All purchases include 14-day free trial for subscriptions

TESTING:
1. Open app → Menu → "Upgrade to Premium"
2. View available plans and features
3. Use your sandbox account to test purchases
4. Verify premium features unlock immediately
5. Test "Restore Purchases" from Premium Status page

NO DEMO ACCOUNT NEEDED:
All functionality is testable with sandbox accounts.
Free tier is fully functional for basic use.

SUBSCRIPTION MANAGEMENT:
Users can manage/cancel subscriptions via iOS Settings → [Apple ID] → Subscriptions
Direct link also available in-app: Menu → Premium Status → Manage Subscription

IMPORTANT:
Subscriptions auto-renew but users can cancel anytime without penalty.
No charges until trial ends.
Clear pricing and terms displayed before purchase.
```

---

## 🔗 Required URLs

### Privacy Policy URL:
```
https://yourwebsite.com/privacy
```

**Must mention:**
- Purchase history stored locally
- No personal data sold to third parties
- Apple handles payment processing
- Subscription terms clearly stated

### Terms of Service URL:
```
https://yourwebsite.com/terms
```

**Must include:**
- Subscription terms
- Cancellation policy
- Refund policy (refer to Apple's terms)
- Feature descriptions

### Support URL:
```
https://yourwebsite.com/support
```

**Or email:**
```
support@yourappname.com
```

---

## ⚡ Fast Setup Checklist

```
Step 1: Create Products in App Store Connect
□ com.cocktailbar.pro.lifetime ($19.99)
□ com.cocktailbar.subscription.monthly ($4.99/month)
□ com.cocktailbar.subscription.annual ($29.99/year)

Step 2: Configure Each Product
□ Add display names
□ Add descriptions
□ Set prices
□ Upload screenshots
□ Enable family sharing
□ Add free trial (subscriptions)

Step 3: Submit for Review
□ Status shows "Ready to Submit"
□ All required fields filled
□ Screenshots uploaded
□ Click "Submit for Review"

Step 4: Wait for Approval
□ Usually 24-48 hours
□ Check email for updates
□ Products approved separately from app

Step 5: Test in Production
□ Products appear in app
□ Purchases work correctly
□ Restore purchases works
□ Subscriptions renew properly
```

---

## 💰 Pricing Strategy

### Recommended Starting Prices:

**Lifetime Purchase:**
- Launch: $14.99 (first 2 weeks)
- Regular: $19.99
- Premium: $24.99 (after established user base)

**Subscriptions:**
- Monthly: $4.99 (standard)
- Annual: $29.99 (50% savings to incentivize)

### Regional Pricing:
App Store Connect auto-adjusts for each territory.
Review and manually adjust if needed for:
- High-value markets (US, UK, AU, CA)
- Price-sensitive markets (emerging markets)

### Promotions:
- Launch: 25% off lifetime for first month
- Holidays: Limited-time offers
- Winback: Special offers for lapsed subscribers

---

## 📊 Success Metrics to Track

**After Launch:**
```
Week 1:
□ Product impressions
□ Paywall views
□ Purchase conversions
□ Free trial starts

Month 1:
□ Overall conversion rate
□ Trial-to-paid rate
□ Revenue per user
□ Most popular product

Month 3:
□ Subscriber retention
□ Churn rate
□ LTV (Lifetime Value)
□ Feature usage rates
```

**Target Metrics:**
- Conversion: 3-5% (good), 5-8% (great), 8%+ (excellent)
- Trial conversion: 40-60%
- Monthly churn: <10%
- Annual renewal: >70%

---

**This is your complete product setup reference!**

Keep this handy while setting up App Store Connect.
Copy-paste directly to save time.

✅ All product IDs match your code
✅ Descriptions optimized for conversion
✅ Pricing competitive and strategic
✅ Ready for App Store submission

---

*Last Updated: January 2, 2026*
*All product IDs tested and verified in code ✅*
