# Mapping Library for Visualization

## Metadata

- **Driver:** Jon Psaila
- **Approver(s):** Jon Psaila (Hehe)
- **Contributors:**
- **Informed:**
- **Decision:** Leaflet.js is the decision. This choice acheives all current objectives. Additionally, if requirements change, swapping out this library is not a herculean effort. Flexible designs for the win!
- **Date Decided:** [2025-04-25]

---

## 1. Define the Problem

- To provide a fantastic user experience, I want to add map visualizations for truck routes, shipment destinations, and other trucking related use cases
- This need was spurred by a desire to help users better plan their trucking routes through the app. Current experience is cumbersome.
- Currently, the experience is solely text based. It's difficult for users to visualize routes since they sometimes do not know where a particular dropoff/pickup point is for a shipment.

---

## 2. Specify the Objectives

- A library/gem/package is chosen that allows for map rendering within the browser
- Solution should ideally be free
- Solution should not impose a significant hit to performance.

---

## 3. Develop Alternatives

- Leaflet.js
- Mapbox.js
- Google Maps API
- OpenLayers
- HERE Maps
- Bing Maps

---

## 4. Identify the Consequences

| Objective                                                                 | Leaflet.js                                       | Mapbox.js                                          | Google Maps API                                       | OpenLayers                           | HERE Maps                        | Bing Maps                             |
| ------------------------------------------------------------------------- | ------------------------------------------------ | -------------------------------------------------- | ----------------------------------------------------- | ------------------------------------ | -------------------------------- | ------------------------------------- |
| Allows me to render maps within the browser                               | 5/5 - Excellent support for interactive maps     | 5/5 - Excellent rendering with customizable styles | 5/5 - Industry standard rendering                     | 5/5 - Full-featured map rendering    | 4/5 - Good rendering options     | 4/5 - Good rendering capabilities     |
| Allows me to overlay shipment destination data on top of the rendered map | 5/5 - Strong marker and overlay support          | 5/5 - Excellent data visualization tools           | 5/5 - Comprehensive overlay options                   | 5/5 - Extensive overlay capabilities | 4/5 - Good overlay functionality | 4/5 - Good marker and overlay support |
| Is free                                                                   | 5/5 - Completely open-source and free            | 3/5 - Free tier with limits (50,000 views/month)   | 2/5 - Limited free tier ($200 credit/month, then pay) | 5/5 - Open-source and free           | 3/5 - Free tier with limits      | 2/5 - Limited free tier               |
| Is performant and does not degrade the responsiveness of the application  | 4/5 - Lightweight but can slow with many markers | 4/5 - Well-optimized but heavier than Leaflet      | 3/5 - Powerful but can be resource-intensive          | 3/5 - Comprehensive but heavier      | 4/5 - Well-optimized             | 3/5 - Moderately performant           |

---

## 5. Clarify the Tradeoffs

- From the above, Leaflet acheives all that we need.
- Google Maps API would work as well, and has a significant trust component. However, the echos of an age old mantra ring through my ears... "It's always better to design for today, rather than optimize for potential future needs"
- Thankfully, there are no deal-breakers or unacceptable risks with any option.

- Leaflet.js was chosen due to it's applicability to the current requirements. It's totally free and performant to boot. While it doesn't have as rich a feature set as Google Maps, it suits our current needs.

---

## 6. Additional Considerations (Optional)

NA

---

> This template follows the PrOACT framework for structured decision-making. Adapt as necessary to fit the context and scale of your project.
