# 🧪 Monetization Testing Guide

## Quick Test Checklist

### ✅ Before App Store Submission

Use this checklist to verify all monetization features work correctly:

---

## 1️⃣ Product Loading Test

**Steps:**
1. Launch app
2. Navigate to Menu → "Upgrade to Premium"
3. Wait for products to load

**Expected:**
- ✅ Products load within 2-3 seconds
- ✅ Prices display correctly
- ✅ Product descriptions show
- ✅ "Best Value" badge shows on annual subscription
- ✅ No loading spinner stuck indefinitely

**If products don't load:**
- Check internet connection
- Verify products created in App Store Connect
- Check product IDs match code exactly
- Wait 2-4 hours after creating products

---

## 2️⃣ Purchase Flow Test

**Test Each Product:**

### A. One-Time Purchase ($19.99)
1. Tap "Cocktail Bar Pro"
2. Tap "Subscribe Now"
3. Complete purchase with sandbox account
4. **Expected:** Purchase succeeds, features unlock immediately
5. Navigate to Premium Status
6. **Expected:** Shows "Premium Active"

### B. Monthly Subscription ($4.99)
1. Tap "Premium Monthly"
2. Tap "Subscribe Now"
3. Complete purchase
4. **Expected:** 14-day free trial starts (if configured)
5. **Expected:** Features unlock immediately
6. **Expected:** Can see subscription in Premium Status

### C. Annual Subscription ($29.99)
1. Tap "Premium Annual"
2. Tap "Subscribe Now"
3. Complete purchase
4. **Expected:** Shows "Best Value" badge
5. **Expected:** Subscription activates
6. **Expected:** Premium Status shows active subscription

---

## 3️⃣ Feature Access Test

### Test Free Tier Limits

**Cabinet Limit (20 items):**
1. Open Cabinet
2. Try to add 21st ingredient
3. **Expected:** Shows upgrade prompt or limit warning
4. **If premium:** Can add unlimited items

**Favorites Limit (10 items):**
1. Try to save 11th favorite
2. **Expected:** Shows "Upgrade to Premium" message
3. **If premium:** Can save unlimited

**Collections Limit (1 collection):**
1. Try to create 2nd collection
2. **Expected:** Paywall appears
3. **If premium:** Can create unlimited

### Test Premium Features

**After purchasing premium, verify access to:**
- ✅ Custom Recipe Creator
- ✅ Cost Tracking
- ✅ Batch Calculator  
- ✅ Offline Mode settings
- ✅ Export features
- ✅ Advanced search filters
- ✅ Educational content
- ✅ Ingredient substitutions

---

## 4️⃣ Restore Purchases Test

**Critical: Test on multiple devices**

### Device 1 (Purchase):
1. Make purchase
2. Verify premium active
3. Note which product purchased

### Device 2 (Restore):
1. Install app (same Apple ID)
2. Navigate to Premium Status
3. Tap "Restore Purchases"
4. **Expected:** Premium features unlock
5. **Expected:** Premium Status shows "Premium Active"

### Test Restore After Deletion:
1. Delete app from Device 1
2. Reinstall app
3. Open Premium Status
4. Tap "Restore Purchases"
5. **Expected:** Premium restored without repurchase

---

## 5️⃣ Subscription Management Test

**For Active Subscription:**

1. Navigate to Premium Status
2. Tap "Manage Subscription"
3. **Expected:** Opens iOS Subscription Settings
4. Verify can see:
   - Current plan
   - Next billing date
   - Cancellation option
   - Upgrade/downgrade options

**Test Cancellation:**
1. Cancel subscription in iOS Settings
2. Return to app
3. **Expected:** Premium still active until end of period
4. **Expected:** Premium Status shows expiration date

**Test After Expiration:**
1. Wait for subscription to expire (or use sandbox fast-forward)
2. Open app
3. **Expected:** Premium features locked
4. **Expected:** Premium Status shows "Expired"
5. **Expected:** Upgrade prompts appear

---

## 6️⃣ Error Handling Test

### No Internet Connection:
1. Turn off WiFi and cellular
2. Try to make purchase
3. **Expected:** Shows error message
4. **Expected:** "Unable to connect" or similar
5. **Expected:** Can dismiss and try again

### Purchase Cancellation:
1. Start purchase flow
2. Cancel at Apple Pay/password screen
3. **Expected:** Returns to paywall
4. **Expected:** No error shows (silent cancellation)
5. **Expected:** Can try again

### Already Purchased:
1. Purchase product
2. Try to purchase same product again
3. **Expected:** "Already purchased" message
4. **Expected:** Features remain unlocked

### Network Timeout:
1. Enable airplane mode right after tapping purchase
2. **Expected:** Shows timeout error
3. **Expected:** Can retry purchase

---

## 7️⃣ UI/UX Test

### Paywall Display:
- ✅ All text readable (no truncation)
- ✅ Prices formatted correctly for region
- ✅ Feature comparison table clear
- ✅ Easy to dismiss (X button works)
- ✅ "Restore Purchases" button visible
- ✅ No layout issues on different screen sizes

### Premium Status Page:
- ✅ Shows correct status (Free/Premium)
- ✅ Feature list accurate
- ✅ Manage Subscription button works (if subscribed)
- ✅ Restore Purchases button works
- ✅ Support links open correctly

### Feature Gates:
- ✅ Locked features show premium badge
- ✅ Lock icon displays clearly
- ✅ "Upgrade" button easy to find
- ✅ Upgrade prompts appear at natural points

---

## 8️⃣ Edge Cases Test

### Multiple Purchases:
1. Purchase lifetime Pro
2. Try to purchase subscription
3. **Expected:** Both show as purchased (system handles correctly)

### Family Sharing (if enabled):
1. Enable Family Sharing on purchase
2. Sign in on family member device
3. **Expected:** Premium features available
4. **Expected:** Shows as "Family Shared" in status

### App Update After Purchase:
1. Make purchase in v1.0
2. Update app to v1.1
3. **Expected:** Premium status persists
4. **Expected:** All features still unlocked

### Account Change:
1. Sign out of Apple ID
2. Sign in with different Apple ID
3. **Expected:** Premium removed (different account)
4. **Expected:** Can restore with original account

---

## 9️⃣ Sandbox Testing

### Create Sandbox Tester Account

**In App Store Connect:**
1. Users and Access → Sandbox Testers
2. Add tester (use + icon)
3. Use format: `test+cocktail@example.com`
4. Set region (US recommended for testing)
5. Note password

**On Device:**
1. Settings → App Store → Sign Out
2. Launch app
3. Attempt purchase
4. Sign in with sandbox account when prompted
5. Complete test purchase (no charge)

### Sandbox Benefits:
- ✅ No real charges
- ✅ Instant receipts
- ✅ Fast subscription renewal (minutes instead of months)
- ✅ Can test multiple scenarios

### Sandbox Time Acceleration:
```
Real Duration → Sandbox Duration
1 week → 3 minutes
1 month → 5 minutes
2 months → 10 minutes
3 months → 15 minutes
6 months → 30 minutes
1 year → 1 hour
```

Use this to test:
- Subscription renewal
- Expiration
- Billing retry
- Grace period

---

## 🔟 Performance Test

### Memory Usage:
1. Monitor memory while browsing products
2. **Expected:** No significant leaks
3. **Expected:** Smooth scrolling in paywall

### App Launch:
1. Cold launch app
2. **Expected:** Products load in background
3. **Expected:** App usable before products load
4. **Expected:** No blocking UI

### Network Efficiency:
1. Check product loading on slow connection
2. **Expected:** Shows loading indicator
3. **Expected:** Timeout handled gracefully
4. **Expected:** Retry option available

---

## 📊 Test Results Template

Use this to track your testing:

```
Date: ___________
Tester: ___________
Device: ___________
iOS Version: ___________

✅ Products load correctly
✅ One-time purchase works
✅ Monthly subscription works
✅ Annual subscription works
✅ Free trial activates
✅ Features unlock after purchase
✅ Restore purchases works
✅ Cabinet limit enforced (free)
✅ Favorites limit enforced (free)
✅ Collections limit enforced (free)
✅ Premium features accessible (paid)
✅ Subscription management accessible
✅ Cancel subscription works
✅ Expired subscription locks features
✅ Paywall displays correctly
✅ Premium Status page accurate
✅ Error messages clear
✅ Purchase cancellation handled
✅ Network error handled
✅ Already purchased detected
✅ Multiple devices work
✅ Delete/reinstall preserves purchase

Issues Found:
_________________________________
_________________________________

Notes:
_________________________________
_________________________________
```

---

## 🚨 Critical Issues to Watch For

### Show Stoppers (Must Fix):
- ❌ Products never load
- ❌ Purchase completes but features don't unlock
- ❌ Restore purchases doesn't work
- ❌ App crashes during purchase
- ❌ Can't cancel subscription
- ❌ Charged twice for same purchase

### Important Issues:
- ⚠️ Slow product loading (>5 seconds)
- ⚠️ Confusing error messages
- ⚠️ Paywall hard to dismiss
- ⚠️ Subscription status unclear
- ⚠️ Feature limits not obvious

### Nice to Fix:
- 💡 Loading animations could be smoother
- 💡 Better upsell messaging
- 💡 More prominent restore button
- 💡 Feature comparison could be clearer

---

## 🎯 Pre-Submission Final Check

**24 Hours Before Submission:**

- [ ] All products created in App Store Connect
- [ ] Tested on iPhone (multiple sizes)
- [ ] Tested on iPad
- [ ] Tested on iOS minimum version
- [ ] Tested with sandbox accounts (3+ scenarios)
- [ ] Restore purchases tested on 2+ devices
- [ ] All error cases handled gracefully
- [ ] Screenshots uploaded to App Store Connect
- [ ] Subscription terms page ready
- [ ] Privacy policy mentions in-app purchases
- [ ] App description mentions premium features
- [ ] Support email working
- [ ] Demo account created (if needed)
- [ ] Review notes prepared

**Ready to Submit:** ✅

---

## 💬 Test Account Credentials

**For App Review:**
```
Test Account: Not required
(All features testable with sandbox)

Sandbox Account (for testing):
Email: test+cocktail@yourdomain.com
Password: [Your sandbox password]
Region: United States

Subscription Test Instructions:
1. Use sandbox account
2. Make test purchase (no charge)
3. Verify premium features unlock
4. Test restore purchases
5. All scenarios covered
```

---

## 📞 Support Responses

**Common Questions During Testing:**

**Q: "Why do products show $0.00?"**
A: Sandbox environment. Real prices show in production.

**Q: "Subscription renewed immediately?"**
A: Sandbox accelerates time. Real renewals monthly/yearly.

**Q: "Can I test without sandbox?"**
A: Yes, but use real purchases (you'll be charged).

**Q: "Products not showing?"**
A: Check:
1. App Store Connect products published
2. Wait 2-4 hours after creation
3. Bundle ID matches exactly
4. Tax/banking complete

---

## ✨ Success Criteria

### Your monetization is ready when:

✅ **All purchases work** on first try
✅ **Features unlock** immediately after purchase
✅ **Restore purchases** works on all devices
✅ **Free tier limits** properly enforced
✅ **Premium tier** grants full access
✅ **Error handling** is smooth and clear
✅ **UI/UX** is polished and intuitive
✅ **Subscription management** is accessible
✅ **No crashes** during any flow
✅ **Performance** is excellent

### When to submit:
✅ All tests pass
✅ No critical issues
✅ App Store Connect products ready
✅ Screenshots uploaded
✅ Metadata complete
✅ Confident in user experience

---

**You're ready to make money! 🎉**

*Last Updated: January 2, 2026*
