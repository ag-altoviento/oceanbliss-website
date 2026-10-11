# Product Requirements Document (PRD)
## Ocean Bliss Website

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 1 Core Document (never archive, rarely updated)  
> **Purpose**: Single source of truth for product requirements and business goals  
> **Update Frequency**: Rarely - only when actual product requirements change
>
> **When editing this document**:
> - ✅ Update only when business requirements or product scope changes
> - ✅ Keep high-level and product-focused (features, user needs, success metrics)
> - ✅ Document the "WHAT" and "WHY", not the "HOW"
> - ✅ State what and why as current truth; link the product spec and the decision log once, in the Status line, not throughout the body
> - ✅ Keep "Concepts" to the few nouns the product is built on; the spec and the code use the same words
> - ❌ Don't add implementation details (use 02_ARCHITECTURE.md or design docs)
> - ❌ Don't specify behaviour - how the product behaves is the product spec's job (`design/PRODUCT-DESIGN.md`)
> - ❌ Don't add task tracking or progress updates (use 03_TODO.md)
> - ❌ Don't bloat with session notes or temporary decisions (archive those)
> - ❌ Don't duplicate technical architecture info (lives in 02_ARCHITECTURE.md)
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](00_ONBOARDING.md)

**Status:** 🟢 baseline for building, set 2026-10-10. The key decisions behind it are in [05_DESIGN-DECISIONS.md](05_DESIGN-DECISIONS.md).

---

## 1. Executive Summary

### Problem
Ocean Bliss is rented through 360 Blue, whose [listing page](https://www.360blue.com/destinations/the-forgotten-coast/gulf-county/properties/north-cape-san-blas-ocean-bliss-189-westwind-dr-631) is one of hundreds on their site. The owner can't run their own promotions or Google Ads for the house without a page of their own to send the traffic to.

### Solution
A marketing website for Ocean Bliss that the owner controls. It sells the house, and every booking call to action sends the guest to the 360 Blue listing, where 360 Blue takes the booking and runs the rental.

### Target Users
- **Primary:** Prospective guests arriving from the owner's Google Ads, social posts and promotions
- **Secondary:** Past guests the owner invites back

---

## 2. Concepts

- **The house:** Ocean Bliss, 189 Westwind Dr, North Cape San Blas, Port St. Joe, FL - 6 bedrooms, 6.5 baths, sleeps 16.
- **The site:** https://oceanbliss.life
- **Lead:** A visitor who clicks through to the listing to check dates or book.
- **Listing:** The house's page on 360 Blue, where every booking happens.

---

## 3. Product Objectives

### Business Goals
1. More bookings for Ocean Bliss from traffic the owner brings in
2. Measure what each ad or promotion brings - clicks through to the listing, by campaign
3. Cost nothing to host and almost nothing to maintain

### User Goals
1. **For prospective guests:** see the house, the pool, the views and the beach, and get to dates and prices in one tap
2. **For past guests:** find the house again and book their next stay

---

## 4. Key Features

1. **Home:** A hero photo, the house's name and a one-line pitch, with a "Check availability" button above the fold.
2. **The house:** Bedrooms and beds, the pool and outdoor living, amenities, pet policy, and a photo gallery.
3. **Location:** North Cape San Blas and the Forgotten Coast, the beach boardwalk across the street, a map link and what's nearby.
4. **Booking calls to action:** Every booking button links to the listing, tagged with the campaign it came from.
5. **Ad measurement:** Google Ads and Analytics tags, with a click through to the listing counted as a conversion.

---

## 5. Scope

### In version 1
- Everything in Key Features, on a site that works well on phones

### Later
- Landing pages per campaign or season, when ads run more than one message
- A second language, if guests come from another-language market

### What We're Not Building
- Booking, payments, availability or pricing on the site - 360 Blue owns all of that
- A content management system or user accounts

---

## 7. Success Criteria

- The site is live, loads fast on a phone, and ranks for "Ocean Bliss Cape San Blas"
- A visitor reaches the listing within one tap of landing
- Google Ads reports clicks through to the listing as conversions, per campaign

---

## 8. Dependencies & Risks

### External Dependencies
- 360 Blue - the listing page, and its photos, used with permission
- GitHub Pages for hosting
- Google Ads and Google Analytics

### Key Risks
| Risk | Impact | Mitigation |
|------|--------|-----------|
| The listing photos are copyrighted - "© Natural Retreats" | A takedown, or trouble with the management company | 360 Blue gave the owner permission to use them on this site, 2026-10-10 |
| 360 Blue changes the listing URL | Every booking button breaks | The listing URL is set in one place in each page; a link check in CI catches a dead link |
| Bookings can't be tied to ads | Ad spend is judged on clicks, not stays | Tag links with UTM parameters, and ask 360 Blue to report bookings from them |
| The site reads as 360 Blue's own | Confuses guests, and may break the management agreement | The site presents the house as the owner's, and names 360 Blue as the booking partner |

---

## Open Questions

- **Q1:** Can 360 Blue report bookings that came from the owner's links - a referral code, UTM reporting, or an owner-direct rate?
- **Q2:** Does the site show a way to contact the owner directly, or only the listing?

---

**Document Last Updated:** 2026-10-10
**Owner:** Andres Garcia
**Related Documents:** [02_ARCHITECTURE.md](02_ARCHITECTURE.md), [03_TODO.md](03_TODO.md)
